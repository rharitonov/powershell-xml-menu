Clear-Host
$ImportFilename = $null
if (!$ImportFilename) {
    Write-Host "=== 1730 Tester: Select the file ====" -BackgroundColor Yellow -ForegroundColor Black
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
        $ImportFilename = $MenuFile[0]    
    } else {
        $SelectedMenuItem = Read-Host "Your choose"
        if ($SelectedMenuItem -eq 0){
            Write-Host "OOK"
        }
        $ImportFilename = $Menu[$SelectedMenuItem]
        if (!$ImportFilename){
            Write-Host "No File. Bye!"-BackgroundColor Black -ForegroundColor Red
            exit
        }    
    }
}


$ImportFilename