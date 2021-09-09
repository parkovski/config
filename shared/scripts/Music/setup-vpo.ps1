param([string]$Dest, [string]$Src, [switch]$NoWaves, [switch]$NoFix)

if (-not $NoWaves) {
  7z "-o$Dest" x "$Src\Virtual-Playing-Orchestra3-1-wave-files.zip"
}

7z -y "-o$Dest" x "$Src\Virtual-Playing-Orchestra3-2-2-standard-scripts.zip"
mkdir "$Dest\Virtual-Playing-Orchestra3\Standard"
Get-ChildItem "$Dest\Virtual-Playing-Orchestra3" | `
  Where-Object { $_.Name -ne 'Standard' -and $_.Name -ne 'Performance' -and $_.Name -ne 'libs' } | `
  ForEach-Object { Move-Item -Force $_ "$Dest\Virtual-Playing-Orchestra3\Standard" }

7z -y "-o$Dest" x "$Src\Virtual-Playing-Orchestra3-2-2-performance-scripts.zip"
mkdir "$Dest\Virtual-Playing-Orchestra3\Performance"
Get-ChildItem "$Dest\Virtual-Playing-Orchestra3" | `
  Where-Object { $_.Name -ne 'Standard' -and $_.Name -ne 'Performance' -and $_.Name -ne 'libs' } | `
  ForEach-Object { Move-Item -Force $_ "$Dest\Virtual-Playing-Orchestra3\Performance" }

if (-not $NoFix) {
  node "$PSScriptRoot\vpo.js" -CPpi "$Dest\Virtual-Playing-Orchestra3"
}
