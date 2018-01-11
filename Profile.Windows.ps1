function Open-AdminWindow {
  Start-Process $PowerShell -Verb Runas
}

$ProVar.vcvars = "C:\Program Files (x86)\Microsoft Visual Studio\2017\Community\VC\Auxiliary\Build\vcvars64.bat"
function vcvars {
  param([bool]$Force = $false)

  if ($ProVar.vcvars_set -and -not $Force) {
    Write-Host "Aw dawg you savin like 3 to 4 seconds cuz its already set!"
    return;
  }
  cmd /c "`"$($ProVar.vcvars)`" & set" | ?{$_ -match "^[A-Za-z_0-9]+="} | %{
    $var = $_
    $eq = $var.IndexOf('=');
    $key = $var.Substring(0, $eq);
    $val = $var.Substring($eq + 1);
    Set-Content "Env:\$key" "$val"
  }
  $ProVar.vcvars_set = $true
  Write-Host "Dawg, vcvars is r-r-r-ready to roll"
}

Set-Alias which where.exe

if (Test-Path "$GH\3rd-party\vcpkg") {
  Import-Module "$GH\3rd-party\vcpkg\scripts\posh-vcpkg"
}
