param(
  [Parameter(Position = 0)][string]$OrderName,
  [Parameter(Position = 1)][string]$SiteName = 'Default Web Site'
)

Import-Module Posh-ACME
Import-Module Posh-ACME.Deploy
Import-Module "C:\Windows\System32\WindowsPowerShell\v1.0\Modules\WebAdministration"

Set-PAServer LE_PROD
Set-PAOrder $OrderName
if ($cert = Submit-Renewal) {
  $cert | Set-IISCertificate -SiteName $SiteName
  Write-Output "Certificate updated"
} else {
  [Console]::Error.WriteLine("Certificate renewal failed.")
  exit 1
}