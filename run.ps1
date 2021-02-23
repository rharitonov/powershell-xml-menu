param ($ImportFilename = $null)

$SystemServiceURL = "http://smsk02ap64u:7127/DynamicsNAV_DEV3/WS/SystemService"
$EndpointRootURL = "http://smsk02ap64u:7127/DynamicsNAV_DEV3/WS"
$DefaultCompanyURL = "VTB Business Finance_IFRS"

if (!(Test-Path -Path .\imports.txt)){
    Write-Host "imports.txt is not found!" -BackgroundColor Black -ForegroundColor Red
}

if ($ImportFilename) {
    if (!(Test-Path -Path $ImportFilename)){
        Write-Host "File $ImportFilename does not exist. Bye!" -BackgroundColor Black -ForegroundColor Red
        exit
    } else {
        Add-Content .\imports.txt "$ImportFilename"
    }
}

Clear-Host
if (!$ImportFilename) {

	Write-Host "Finding previos imports.."
	$SelectedCompany = $null
	$ws = New-WebServiceProxy "$EndpointRootURL/$DefaultCompanyURL/Codeunit/ConsolidationAPI"  -UseDefaultCredential 
	$ws.Timeout = [System.Int32]::MaxValue
	$responseXML = ""         
	$ws.GetImportedCompanies([ref]$responseXML)
	#$responseXML
	[xml]$xml = $responseXML
	$Menu = [System.Collections.Generic.List[string]]::new()
	$Node = $xml.root."root_element".companies.company
	if ($Node){
		$Node | ForEach-Object {
			$val = $_."name"
			$Menu.Add($val)
		}
		if ($Menu.Count -ne 0) {
			$SelectedMenuItem = 0
			Write-Host "=== 1730 Tester: Select Company from previous file import or Start new ===" -BackgroundColor Yellow -ForegroundColor Black
			$Menu | ForEach-Object {
				Write-Host "$SelectedMenuItem - $_"
				$SelectedMenuItem += 1
			}
			$StartNewMenuItem = $SelectedMenuItem + 1
			Write-Host "$StartNewMenuItem - Start new import file and consolidation round"
			$SelectedMenuItem = Read-Host "Your choose"
			if ($SelectedMenuItem -eq $StartNewMenuItem){
				$SelectedCompany = $null
			} else {
				$SelectedCompany = $Menu[$SelectedMenuItem]
				if (!$SelectedCompany){
					Write-Host "Aborted. Bye!" -BackgroundColor Black -ForegroundColor Red
					exit
				}
			}		
		}
	}
	
	if (!$SelectedCompany) {
		###
		Write-Host "=== 1730 Tester: Select the file ===" -BackgroundColor Yellow -ForegroundColor Black
		$Menu = [System.Collections.Generic.List[string]]::new()
		$SelectedMenuItem = 0
		Get-Content .\imports.txt | ForEach-Object {
			if ($_) {
				if (!(Test-Path -Path $_)){
					Write-Host "x - $_" -ForegroundColor Red
				} else {
					Write-Host "$SelectedMenuItem - $_"
					$Menu.Add($_)
					$SelectedMenuItem += 1 
				}   
			}
		}
		if ($Menu.Count -eq 0) {
			Write-Host "No Files in imports.txt. Bye!"-BackgroundColor Black -ForegroundColor Red
			exit
		}
		if ($Menu.Count -eq 1){
			$ImportFilename = $Menu[0]    
		} else {
			$SelectedMenuItem = Read-Host "Your choose"
			$ImportFilename = $Menu[$SelectedMenuItem]
			if (!$ImportFilename){
				Write-Host "No file selected. Bye!"-BackgroundColor Black -ForegroundColor Red
				exit
			}    
		}
	}
}


if (!$SelectedCompany) {
	$ws = New-WebServiceProxy "$EndpointRootURL/$DefaultCompanyURL/Codeunit/ConsolidationAPI"  -UseDefaultCredential 
	$ws.Timeout = [System.Int32]::MaxValue

	$responseXML = ""
	Write-Host "`nImportFile request sent.."         
	$ws.ImportFile($ImportFilename, ([ref]$responseXML))

	Write-Host "ImportFile response:" -BackgroundColor White -ForegroundColor Black 
	$responseXML

	#[xml]$xml = Get-Content .\ImportFile-reponse1.xml
	[xml]$xml = $responseXML
	$Menu = [System.Collections.Generic.List[string]]::new()
	$xml.root."root_element".companies.company | Where-Object "processing_result" -eq "OK" | ForEach-Object {
		$val = $_."name"
		$Menu.Add($val)
	}

	if ($Menu.Count -eq 0) {
		Write-Host "No Company. Bye!" -BackgroundColor Black -ForegroundColor Red
		exit
	}
	if ($Menu.Count -eq 1){
		$SelectedCompany = $Menu[0]
	} else {
		$SelectedMenuItem = 0
		Write-Host "=== 1730 Tester: Select the Company ===" -BackgroundColor Yellow -ForegroundColor Black
		$Menu | ForEach-Object {
			Write-Host "$SelectedMenuItem - $_"
			$SelectedMenuItem += 1
		}
		$SelectedMenuItem = Read-Host "Your choose"
		$SelectedCompany = $Menu[$SelectedMenuItem]
		if (!$SelectedCompany){
			Write-Host "No Company selected. Bye!" -BackgroundColor Black -ForegroundColor Red
			exit
		}    
	}
}

Write-Host "`nStartConsolidationFromBuffer request sent.."         
$ws = New-WebServiceProxy $SystemServiceURL  -UseDefaultCredential 
$ws.Timeout = [System.Int32]::MaxValue
$NavCompanies = $ws.Companies()        
if (!($NavCompanies | where {$_ -eq $SelectedCompany})){
    Write-Host "NAV Company '$SelectedCompany' does not exist. Bye!" -BackgroundColor Black -ForegroundColor Red
	exit
}
$ws = New-WebServiceProxy "$EndpointRootURL/$SelectedCompany/Codeunit/ConsolidationAPI"  -UseDefaultCredential 
$ws.Timeout = [System.Int32]::MaxValue
$responseXML = ""     
$ws.StartConsolidationFromBuffer([ref]$responseXML) 
Write-Host "StartConsolidationFromBuffer response:" -BackgroundColor White -ForegroundColor Black                 
$responseXML
