function Invoke-WithEnvironment {
  param([string[]]$envvars)

  $oldenv = @{}

  $envvars | ForEach-Object {
    $var = $_
    $eq = $var.IndexOf('=')
    if ($eq -ne -1) {
      $key = $var.Substring(0, $eq)
      $val = $var.Substring($eq + 1)
      if (-not $oldenv.Contains($key)) {
        if (Test-Path Env:\$key) {
          $oldenv[$key] = Get-Content Env:\$key
        } else {
          $oldenv[$key] = $null
        }
      }
      Set-Content -Path Env:\$key -Value $val
    }
  }

  if ($args.Length -le 1) {
    $newargs = @()
  } else {
    $newargs = $args[1..($args.Length - 1)]
  }
  & $args[0] @newargs

  $oldenv.Keys | ForEach-Object {
    $key = $_
    $val = $oldenv[$key]
    if ($val -eq $null) {
      Remove-Item Env:\$key
    } else {
      Set-Content -Path Env:\$key -Value $val
    }
  }
}

function Set-EnvironmentVariable {
  param(
    [Parameter(Mandatory=$true, Position=0)][string]$Name,
    [Parameter(Mandatory=$true, Position=1)][string]$Value,
    [Parameter(Mandatory=$false)][System.EnvironmentVariableTarget]$Scope='Process'
  )
  [System.Environment]::SetEnvironmentVariable($Name, $Value, $Scope)
  Set-Content -Path Env:\$Name -Value $Value
}

function Remove-EnvironmentVariable {
  param(
    [Parameter(Mandatory=$true, Position=0)][string]$Name,
    [Parameter(Mandatory=$false)][System.EnvironmentVariableTarget]$Scope='Process'
  )
  [System.Environment]::SetEnvironmentVariable($Name, '', $Scope)
  Remove-Item -Pat Env:\$Name
}

Set-Alias with Invoke-WithEnvironment
Set-Alias senv Set-EnvironmentVariable
