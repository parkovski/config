param([string]$File, [string]$Prefix)

if (-not $Prefix) {
  if (-not $env:CMAKE_INSTALL_PREFIX) {
    Write-Output "Error: -Prefix and `$CMAKE_INSTALL_PREFIX not set"
    exit 1
  }
  $Prefix = $env:CMAKE_INSTALL_PREFIX
}

if (-not $File) {
  $File = "$pwd/cmake_install.cmake"
} elseif (test-path -PathType Container $File) {
  $File = "$File/cmake_install.cmake"
}

if (-not (test-path -PathType Leaf $File)) {
  Write-Output 'No cmake_install.cmake found in pwd and no valid directory or file given.'
  exit 1
}

cmake `
  "-DCMAKE_INSTALL_PREFIX=$($Prefix -replace '\\','/')" `
  -P $file
