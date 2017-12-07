$platform = [System.Environment]::OSVersion.Platform

if ($platform -eq "Unix") {
  $os = uname -s
  if ($os -eq "Darwin") {
    $os = "macOS"
  } elseif ($os -eq "Linux") {
    $os = ((Get-Content /etc/os-release) -split '`n') | ? { $_ -match "^NAME=`".+`"" }
    if ($os) {
      $os = $os.Substring(6, $os.Length - 6 - 1)
    } else {
      $os = "Unknown"
    }
  }
} elseif ($platform -eq "Win32NT") {
  $os = "Windows"
} else {
  $os = "Unknown"
}
Write-Output $os
