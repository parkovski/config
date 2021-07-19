param([Alias('v')][Nullable[boolean]]$Value)

$key = 'HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\System'
$prop = 'VerboseStatus'
if ($Value -eq $null) {
  Write-Host $(try { (Get-ItemProperty $key $prop -ErrorAction Stop).$prop } catch { 0 })
} else {
  Set-ItemProperty $key $prop ([int]$Value) -Type DWord
}
