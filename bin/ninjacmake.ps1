$root = $env:VCPKG_ROOT -replace '\\','/'
if (-not $root) {
  Write-Output "Error: VCPKG_ROOT not set"
  exit 1
}

cmake `
  "-DCMAKE_TOOLCHAIN_FILE=$root/scripts/buildsystems/vcpkg.cmake" `
  -G Ninja `
  @args
