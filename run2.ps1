Clear-Host
Write-Host "=== 1730 Tester: Select the file ============================================================"
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
$SelectedFilename = $Menu[$SelectedMenuItem]
if (!$SelectedFilename){
    Write-Host "No File. Bye!" -ForegroundColor Red
    exit
}

