param([ValidateSet(32, 64)][int]$Bits=64)

$root = $env:VCPKG_ROOT -replace '\\','/'
if (-not $root) {
  Write-Output "Error: VCPKG_ROOT not set"
  exit 1
}
if ($Bits -eq 64) {
  $arch = 'x64'
} else {
  $arch = 'x86'
}

if (-not $env:VSINSTALLDIR) {
  vcvars
}

if (-not $env:VCPKG_DEFAULT_TRIPLET) {
  Write-Output "Warning: VCPKG_DEFAULT_TRIPLET not set."
}

cmake `
  "-DCMAKE_TOOLCHAIN_FILE=$root/scripts/buildsystems/vcpkg.cmake" `
  -G "Visual Studio 15 2017" `
  -A $arch -T host=x64 `
  @args
