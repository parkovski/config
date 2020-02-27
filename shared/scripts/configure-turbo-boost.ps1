param(
  [switch]$AC, [switch]$DC,
  [switch]$ShowGUIDs, [switch]$Query,
  [switch]$Force,
  [ValidateSet('Hi', 'Lo', $null)][string]$Minimum,
  [ValidateSet('On', 'Off', $null)][string]$TurboBoost
)

# GUIDs:
# - High performance power plan (SCHEME_MIN)
# - Processor power management (SUB_PROCESSOR)
# - PROCTHROTTLEMAX
# Set to 99 for max without turbo boost.
# powercfg /setdcvalueindex SCHEME_MIN SUB_PROCESSOR PROCTHROTTLEMAX 99

function Get-PowerSchemeGUID {
  param([string]$Scheme)
  $PowerCfgList = powercfg /l
  $PowerCfgList = $PowerCfgList[2..999]
  for ($i = 0; $i -lt $PowerCfgList.Length; ++$i) {
    if ($PowerCfgList[$i] -match '\(.+\)' -and $Matches[0] -ieq "($Scheme)") {
      if ($PowerCfgList[$i] -imatch ': ([a-z0-9-]+) ') {
        return $Matches[1]
      }
    }
  }

  return $null
}

$HighPerformanceGUID = Get-PowerSchemeGUID -Scheme:'High performance'
if ($HighPerformanceGUID -eq $null) {
  # SCHEME_MIN
  $HighPerformanceGUID = '8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c'
  Write-Host "High performance GUID not found! Using default: $HighPerformanceGUID"
}
$BalancedGUID = Get-PowerSchemeGUID -Scheme:'Balanced'
# SUB_PROCESSOR
$ProcPowerMgmtGUID = '54533251-82be-4824-96c1-47b60b740d00'
# PROCTHROTTLEMIN
$ProcThrottleMinGUID = '893dee8e-2bef-41e0-89c6-b55d0929964c'
# PROCTHROTTLEMAX
$ProcThrottleMaxGUID = 'bc5038f7-23e0-4960-96da-33abaf5935ec'

if ($ShowGUIDs) {
  Write-Host "PowerCfg GUIDs:"
  if ($BalancedGUID) {
    Write-Host "Balanced (SCHEME_BALANCED): $BalancedGUID"
  }
  Write-Host "High performance (SCHEME_MIN): $HighPerformanceGUID"
  Write-Host "SUB_PROCESSOR: $ProcPowerMgmtGUID"
  Write-Host "PROCTHROTTLEMIN: $ProcThrottleMinGUID"
  Write-Host "PROCTHROTTLEMAX: $ProcThrottleMaxGUID"
}

function Set-PowerCfg {
  param([string]$Flag, [string]$SettingGUID, [uint]$Value)

  powercfg $Flag $HighPerformanceGUID $ProcPowerMgmtGUID $SettingGUID $Value
  if ($LASTEXITCODE -ne 0) {
    Write-Host "Failed to set value with powercfg."
    exit $LASTEXITCODE
  }
}

if ($Minimum -ieq 'hi') {
  if ($AC) {
    Set-PowerCfg -Flag:'/setacvalueindex' `
                 -SettingGUID:$ProcThrottleMinGUID `
                 -Value:99
  }
  if ($DC) {
    Set-PowerCfg -Flag:'/setdcvalueindex' `
                 -SettingGUID:$ProcThrottleMinGUID `
                 -Value:99
  }
} elseif ($Minimum -ieq 'lo') {
  if ($AC) {
    if ($Force) {
      Set-PowerCfg -Flag:'/setacvalueindex' `
                   -SettingGUID:$ProcThrottleMinGUID `
                   -Value:5
    } else {
      Write-Host "Use the -Force to set a low AC value."
    }
  }
  if ($DC) {
    Set-PowerCfg -Flag:'/setdcvalueindex' `
                 -SettingGUID:$ProcThrottleMinGUID `
                 -Value:5
  }
}

if ($TurboBoost -ieq 'on') {
  if ($AC) {
    Set-PowerCfg -Flag:'/setacvalueindex' `
                 -SettingGUID:$ProcThrottleMaxGUID `
                 -Value:100
  }
  if ($DC) {
    Set-PowerCfg -Flag:'/setdcvalueindex' `
                 -SettingGUID:$ProcThrottleMaxGUID `
                 -Value:100
  }
} elseif ($TurboBoost -ieq 'off') {
  if ($AC) {
    Set-PowerCfg -Flag:'/setacvalueindex' `
                 -SettingGUID:$ProcThrottleMaxGUID `
                 -Value:99
  }
  if ($DC) {
    Set-PowerCfg -Flag:'/setdcvalueindex' `
                 -SettingGUID:$ProcThrottleMaxGUID `
                 -Value:99
  }
}

if ($Query) {
  powercfg /q $HighPerformanceGUID $ProcPowerMgmtGUID
} else {
  if (-not $ShowGUIDs) {
    if ((-not ($AC -or $DC)) -or ($TurboBoost -eq $null -and $Minimum -eq $null)) {
      Write-Host "No args specified!"
      Write-Host "Use -Query, -ShowGUIDs for info."
      Write-Host "Use -Minimum=Hi|Lo, -TurboBoost=On|Off with -AC or -DC to change settings."
      exit 1
    }
  }
}
