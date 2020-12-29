Connect-AzAccount

$Regions = (Get-AzLocation).Location

$AllSizeData = @()
foreach($Region in $Regions)
{
    $AllSizeData += (Get-AzVMSize -Location $Region -ErrorAction SilentlyContinue).Name
}

$FilteredData = $AllSizeData | Select-Object -Unique | Sort-Object

$FilteredData