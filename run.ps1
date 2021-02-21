param ($ImportFilename = $null)

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
    Write-Host "=== 1730 Tester: Select the file ============================================================" -BackgroundColor Yellow -ForegroundColor Black
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
    $SelectedMenuItem = Read-Host "Your choose"
    $ImportFilename = $Menu[$SelectedMenuItem]
    if (!$ImportFilename){
        Write-Host "No File. Bye!"-BackgroundColor Black -ForegroundColor Red
        exit
    }
}


$ws = New-WebServiceProxy "http://smsk02ap64u:7127/DynamicsNAV_DEV3/WS/VTB Business Finance_IFRS/Codeunit/ConsolidationAPI"  -UseDefaultCredential 
$ws.Timeout = [System.Int32]::MaxValue
$responseXML = ""
$ws.ImportFile($ImportFilename, ([ref]$responseXML)) 

##

#[xml]$xml = Get-Content .\ImportFile-reponse1.xml
[xml]$xml = Get-Content $responseXML
$MenuCompany = [System.Collections.Generic.List[string]]::new()
$xml.root."root_element".companies.company | Select-Object name | ForEach-Object {
    $val = $_."name"
    $MenuCompany.Add($val)
}

if ($MenuCompany.Count -eq 0) {
    Write-Host "No Company. Bye!" -BackgroundColor Black -ForegroundColor Red
    exit
}
if ($MenuCompany.Count -eq 1){
    $SelectedCompany = $Menu2[0]
} else {
    $SelectedMenuItem = 0
    Write-Host "=== 1730 Tester: Select the Company ===========================================================" -BackgroundColor Yellow -ForegroundColor Black
    $MenuCompany | ForEach-Object {
        Write-Host "$SelectedMenuItem - $_"
        $SelectedMenuItem += 1
    }
    $SelectedMenuItem = Read-Host "Your choose"
    $SelectedCompany = $MenuCompany[$SelectedMenuItem]
    if (!$SelectedCompany){
        Write-Host "No Company. Bye!" -BackgroundColor Black -ForegroundColor Red
        exit
    }    
}


$ws = New-WebServiceProxy "http://smsk02ap64u:7127/DynamicsNAV_DEV3/WS/$SelectedCompany/ConsolidationAPI"  -UseDefaultCredential 
$ws.Timeout = [System.Int32]::MaxValue
$responseXML = ""     
$ws.StartConsolidationFromBuffer([ref]$responseXML) 

$responseXML
