$root = $env:VCPKG_ROOT -replace '\\','/'
if (-not $root) {
  Write-Output "Error: VCPKG_ROOT not set"
  exit 1
}

if (-not $env:VSINSTALLDIR) {
  vcvars
}

if (-not $env:VCPKG_DEFAULT_TRIPLET) {
  Write-Output "Warning: VCPKG_DEFAULT_TRIPLET not set."
}

cmake `
  -G Ninja `
  @args `
  "-DCMAKE_TOOLCHAIN_FILE=$root/scripts/buildsystems/vcpkg.cmake"
