$global:OS_BASE = [System.Environment]::OSVersion.Platform
$global:OS = "Unknown"

if ($OS_BASE -eq "Unix") {
  $OS_BASE = uname -s
  if ($OS_BASE -eq "Darwin") {
    $OS = $OS_BASE = "macOS"
  } elseif ($OS_BASE -eq "Linux") {
    $MaybeOS = ((Get-Content /etc/os-release) -split '`n') | `
      Where-Object { $_ -match "^NAME=`".+`"" }
    if ($MaybeOS) {
      $OS = $MaybeOS.Substring(6, $OS.Length - 6 - 1)
    }
  }
} elseif ($OS_BASE -eq "Win32NT") {
  $OS = $OS_BASE = "Windows"
}

$env:OS = $OS
$env:OS_BASE = $OS_BASE
