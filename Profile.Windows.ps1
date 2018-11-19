chcp 65001 | Out-Null

function Open-PowerShell {
  param([switch]$Admin)
  if ($Admin) {
    Start-Process $PowerShell -Verb Runas
  } else {
    Start-Process $PowerShell
  }
}

function Restore-ConsoleWindow {
  [Console]::SetWindowSize(100, 50)
}

$global:DDev = "D:\dev"
$global:LocalPrograms = "$HOME\AppData\Local\Programs"

# C:\Program Files (x86)\Microsoft Visual Studio\2017\Community\Common7\Tools\VsDevCmd.bat
# C:\Program Files (x86)\Microsoft Visual Studio\2017\Community\VC\Auxiliary\Build\vcvars64.bat
$ProVar.vcvars = @{
  Base = "C:\Program Files (x86)\Microsoft Visual Studio";
  Version = "2017";
  Edition = "BuildTools";
  SubDir = "VC\Auxiliary\Build";
  Script = "vcvars64.bat";
  IsSet = $false;
}
# TODO: Make this look for more versions/editions
function vcvars {
  param([bool]$Force = $false)

  $dir = [System.IO.Path]::Combine(
    $ProVar.vcvars.Base,
    $ProVar.vcvars.Version,
    $ProVar.vcvars.Edition,
    $ProVar.vcvars.SubDir,
    $ProVar.vcvars.Script
  )

  if (-not (Test-Path $dir -PathType Leaf)) {
    Write-Host "Dawg. `$ProVar.vcvars is wack!"
    return
  }

  if ($ProVar.vcvars.IsSet -and -not $Force) {
    Write-Host "Aw dawg you savin like 3 to 4 seconds cuz its already set!"
    return;
  }
  $output = cmd /c "`"$dir`" & set"
  if ($LASTEXITCODE -ne 0) {
    Write-Host "Aw hell nah dawg stuff didn't work!"
    return
  }
  $output | ?{$_ -match "^[A-Za-z_0-9]+="} | %{
    $var = $_
    $eq = $var.IndexOf('=');
    $key = $var.Substring(0, $eq);
    $val = $var.Substring($eq + 1);
    Set-Content "Env:\$key" "$val"
  }
  $ProVar.vcvars.IsSet = $true
  Write-Host "Dawg, vcvars is r-r-r-ready to roll"
}

Set-Alias which where.exe

$ChocolateyProfile = "$env:ChocolateyInstall\helpers\chocolateyProfile.psm1"
if (Test-Path($ChocolateyProfile)) {
  Import-Module "$ChocolateyProfile"
}
