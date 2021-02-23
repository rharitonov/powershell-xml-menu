
[xml]$xml = Get-Content .\ImportFile-reponse3.xml
$Menu = [System.Collections.Generic.List[string]]::new()
#$xml.root."root_element".companies.company | Select-Object name | ForEach-Object {
#$xml.root."root_element".companies.company | Where-Object "processing_result" -eq "OK" | ForEach-Object {
$xml.root."root_element".companies.company | ForEach-Object {
    $val = $_."name"
    $Menu.Add($val)
}

if ($Menu.Count -eq 0) {
    Write-Host "No Company. Bye!"
    exit
}
if ($Menu.Count -eq 1){
    $SelectedCompany = $Menu[0]
} else {
    $SelectedMenuItem = 0
    Write-Host "=== 1730 Tester ============================================================" -BackgroundColor White -ForegroundColor Black
    $Menu | ForEach-Object {
        Write-Host "$SelectedMenuItem - $_"
        $SelectedMenuItem += 1
    }
    $SelectedMenuItem = Read-Host "Please make a selection"
    $SelectedCompany = $Menu[$SelectedMenuItem]
    if ($SelectedCompany){
        Write-Host $SelectedCompany
        
    } else {
        Write-Host "No Company. Bye!"
        exit
    }
    
}





