param(
  [switch][Alias('f')]$Force,
  [switch][Alias('v')]$Verbose
)

$DidFail = $false

function fail {
  param([string]$Text)
  if ($Force) {
    Write-Output "Warning: Ignoring $Text."
  } else {
    Write-Output "Error: $Text. Use -f to force."
    $DidFail = $true
  }
}

function printargs {
  Write-Output $args
}

if (-not $env:CMAKE_INSTALL_PREFIX) {
  fail "Warning: CMAKE_INSTALL_PREFIX not set."
} else {
  $args += "-DCMAKE_INSTALL_PREFIX=$env:CMAKE_INSTALL_PREFIX"
}

$root = $env:VCPKG_ROOT -replace '\\','/'
if (-not $root) {
  fail "Warning: VCPKG_ROOT not set"
} else {
  $args += "-DCMAKE_TOOLCHAIN_FILE=$root/scripts/buildsystems/vcpkg.cmake"
}

if (-not $env:VSINSTALLDIR) {
  vcvars
}

if (-not $env:VCPKG_DEFAULT_TRIPLET) {
  fail "Warning: VCPKG_DEFAULT_TRIPLET not set."
}

if ($DidFail) {
  exit 1
}

if ($Verbose) {
  Write-Output 'CMake args:'
  Write-Output '  -GNinja'
  foreach ($arg in $args) {
    Write-Output ('  ' + $arg)
  }
  Write-Output ''
}

cmake -GNinja @args

