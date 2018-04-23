if (-not $env:CMAKE_INSTALL_PREFIX) {
  Write-Output "Error: CMAKE_INSTALL_PREFIX not set"
  exit 1
}

$dir = $pwd
if ($args[0] -and (test-path -PathType Container $args[0])) {
  $dir = $args[0]
}

if (test-path $dir/cmake_install.cmake) {
  $file = "$dir/cmake_install.cmake"
} elseif ($args[0] -and (test-path -PathType Leaf $args[0])) {
  $file = $args[0]
} else {
  Write-Output 'No cmake_install.cmake found in pwd and no valid directory or file given.'
  exit 1
}

cmake `
  "-DCMAKE_INSTALL_PREFIX=$($env:CMAKE_INSTALL_PREFIX -replace '\\','/')" `
  -P $file
