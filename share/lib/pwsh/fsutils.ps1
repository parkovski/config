function New-SymLink {
  param([string]$Target, [string]$Link, [switch]$Relative)

  if (-not $Relative) {
    $Target = $(Resolve-Path $Target).Path
  }
  if ($OS -eq "Windows") {
    $Link = $Link -Replace '/','\'
    $Target = $Target -Replace '/','\'
    if (Test-Path $Target -PathType Container) {
      cmd /c mklink /D $Link $Target
    } else {
      cmd /c mklink $Link $Target
    }
  } else {
    ln -s $Target $Link
  }
}

function Remove-SymLink {
  param([Parameter(Mandatory=$true, Position=0)][string]$Path)
  $item = Get-Item $Path
  if ($item.Attributes -band 'ReparsePoint' -and $item.LinkType -eq 'SymbolicLink') {
    $item.Delete()
  }
}

function Enter-NewDirectory {
  param(
    [Parameter(Mandatory=$true, Position=0)][string]$Path,
    [Alias('p')][switch]$Push
  )
  if (-not (Test-Path $Path -PathType Container)) {
    New-Item $Path -ItemType Directory
  }
  if ($Push) {
    Push-Location $Path
  } else {
    Set-Location $Path
  }
}

function Enter-ParentDirectory {
  param([int]$Levels = 1, [Alias('p')][switch]$Push)
  if ($Push) {
    Push-Location ("../" * $Levels)
  } else {
    Set-Location ("../" * $Levels)
  }
}

function Enter-AlternateDirectory {
  $prevd = Get-Location
  Pop-Location
  $curdir = Get-Location
  Set-Location $prevd
  Push-Location $curdir
}

function Invoke-InDirectory {
  $curdir = Get-Location
  Set-Location $args[0]
  try {
    if ($args.Length -gt 2) {
      $pargs = $args[2..($args.Length - 1)]
      $result = &$args[1] @pargs
    } else {
      $result = &$args[1]
    }
  } finally {
    Set-Location $curdir
  }
  $result
}
