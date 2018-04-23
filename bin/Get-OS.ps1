$OS_BASE = [System.Environment]::OSVersion.Platform

if ($OS_BASE -eq "Unix") {
  $OS_BASE = uname -s
  if ($OS_BASE -eq "Darwin") {
    $OS = $OS_BASE = "macOS"
  } elseif ($OS_BASE -eq "Linux") {
    $OS = ((Get-Content /etc/os-release) -split '`n') | ? { $_ -match "^NAME=`".+`"" }
    if ($OS) {
      $OS = $OS.Substring(6, $OS.Length - 6 - 1)
    } else {
      $OS = "Unknown"
    }
  } else {
    $OS = "Unknown"
  }
} elseif ($OS_BASE -eq "Win32NT") {
  $OS = $OS_BASE = "Windows"
} else {
  $OS = $OS_BASE = "Unknown"
}

$env:OS = $OS
$env:OS_BASE = $OS_BASE
