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
    [Parameter(Mandatory=$true,  Position=0)]
    [string]$Name,

    [Parameter(Mandatory=$true,  Position=1, ValueFromPipeline=$true)]
    [AllowNull()]
    [AllowEmptyString()]
    [string]$Value,

    [Parameter(Mandatory=$false, Position=2)]
    [Alias('s')]
    [System.EnvironmentVariableTarget]$Scope='Process',

    [Parameter(Mandatory=$false,
      HelpMessage='Always on if Scope value is the same as current PS value.')]
    [Alias('p')]
    [switch]$CopyToPS=$false
  )
  $processSameAsScope = $false
  if ($Scope -eq 'Process') {
    $processSameAsScope = $true
  } else {
    $scorig = [System.Environment]::GetEnvironmentVariable($Name, $Scope)
    $psorig = Get-Content -Path Env:\$Name -ErrorAction Ignore
    if ([string]::IsNullOrEmpty($psorig) -or $scorig -eq $psorig) {
      $processSameAsScope = $true
    }
  }
  [System.Environment]::SetEnvironmentVariable($Name, $Value, $Scope)
  if ($processSameAsScope -or $CopyToPS) {
    Set-Content -Path Env:\$Name -Value $Value
  }
}

function Get-EnvironmentVariable {
  param(
    [Parameter(Mandatory=$true,  Position=0)][string]$Name,
    [Parameter(Mandatory=$false, Position=1)][Alias('s')]
    [System.EnvironmentVariableTarget]$Scope='Process'
  )
  [System.Environment]::GetEnvironmentVariable($Name, $Scope)
}

function Get-EnvironmentVariables {
  param(
    [Parameter(Mandatory=$false, Position=0)][Alias('s')]
    [System.EnvironmentVariableTarget]$Scope='Process'
  )
  [System.Environment]::GetEnvironmentVariables($Scope)
}

function Remove-EnvironmentVariable {
  param(
    [Parameter(Mandatory=$true, Position=0)][string]$Name,
    [Parameter(Mandatory=$false)][Alias('s')]
    [System.EnvironmentVariableTarget]$Scope='Process'
  )
  [System.Environment]::SetEnvironmentVariable($Name, $null, $Scope)
}
