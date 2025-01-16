#Requires -RunAsAdministrator

$License = Get-CimInstance SoftwareLicensingProduct -Filter "Name like 'Windows%'" | Where-Object { $_.PartialProductKey }

if ($License.LicenseStatus -eq 1)
{
    Write-Output "Windows license is already activated"
}
else
{
    Write-Output "Initializing activation. Please proceed in the new window."
    Invoke-RestMethod https://get.activated.win | Invoke-Expression
    Write-Output "Completed"
}
