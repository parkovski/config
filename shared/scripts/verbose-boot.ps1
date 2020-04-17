param([Nullable[boolean]]$Set)

$key = 'HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\System'
$prop = 'VerboseStatus'
if ($Set -eq $null) {
  Write-Host $(try { (Get-ItemProperty $key $prop -ErrorAction Stop).$prop } catch { 0 })
} else {
  Set-ItemProperty $key $prop ([int]$Set) -Type DWord
}
