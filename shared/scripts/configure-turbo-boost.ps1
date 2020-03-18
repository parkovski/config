param(
  [switch]$AC, [switch]$DC,
  [switch]$ShowGUIDs, [switch]$Query,
  [switch]$Force, [string]$SchemeGUID,
  [ValidateSet('Hi', 'Lo', $null)][string]$Minimum,
  [ValidateSet('On', 'Off', $null)][string]$TurboBoost,
  [ValidateSet('Lo', 'Med', 'Hi', $null)][string]$IntelThermal
)

function Write-Stderr {
  param([Parameter(ValueFromPipeline=$true)][string[]]$Text)
  foreach ($line in $Text) {
    [System.Console]::Error.WriteLine($line)
  }
}

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
  Write-Stderr "High performance GUID not found! Using default: $HighPerformanceGUID"
}
$BalancedGUID = Get-PowerSchemeGUID -Scheme:'Balanced'
# SUB_PROCESSOR
$ProcPowerMgmtGUID = '54533251-82be-4824-96c1-47b60b740d00'
# PROCTHROTTLEMIN
$ProcThrottleMinGUID = '893dee8e-2bef-41e0-89c6-b55d0929964c'
# PROCTHROTTLEMAX
$ProcThrottleMaxGUID = 'bc5038f7-23e0-4960-96da-33abaf5935ec'

# No aliases for these two.
$IntelThermalSubgroupGUID = 'f1e029fb-fdcb-4d31-b5d9-906e13fe3b67'
$IntelThermalSettingGUID = 'a4f06079-f3e9-45e0-8562-8aa45ae221fa'

if ([string]::IsNullOrEmpty($SchemeGUID)) {
  $SchemeGUID = $HighPerformanceGUID
}

if ($ShowGUIDs) {
  Write-Output "PowerCfg GUIDs:"
  if ($BalancedGUID) {
    Write-Output "Balanced (SCHEME_BALANCED): $BalancedGUID"
  }
  Write-Output "High performance (SCHEME_MIN): $HighPerformanceGUID"
  Write-Output "SUB_PROCESSOR: $ProcPowerMgmtGUID"
  Write-Output "PROCTHROTTLEMIN: $ProcThrottleMinGUID"
  Write-Output "PROCTHROTTLEMAX: $ProcThrottleMaxGUID"
  Write-Output "Intel Thermal subgroup: $IntelThermalSubgroupGUID"
  Write-Output "Intel Thermal setting: $IntelThermalSettingGUID"
}

function Set-PowerCfgEx {
  param([string]$Flag, [string]$Subgroup, [string]$Setting, [uint]$Value)

  powercfg $Flag $SchemeGUID $Subgroup $Setting $Value
  if ($LASTEXITCODE -ne 0) {
    Write-Stderr "Failed to set value with powercfg."
    exit $LASTEXITCODE
  }
}

function Set-PowerCfg {
  param([string]$Flag, [string]$SettingGUID, [uint]$Value)

  Set-PowerCfgEx -Flag:$Flag `
                 -Subgroup:$ProcPowerMgmtGUID `
                 -Setting:$SettingGUID `
                 -Value:$Value
}

if ($Minimum) {
  switch ($Minimum) {
    'hi' { $MinThrottleValue = 99 }
    'lo' { $MinThrottleValue = 5 }
  }
  if ($AC) {
    if ($Minimum -ieq 'hi' -or $Force) {
      Set-PowerCfg -Flag:'/setacvalueindex' `
                   -SettingGUID:$ProcThrottleMinGUID `
                   -Value:$MinThrottleValue
    } else {
      Write-Stderr "Use the -Force to set a low AC value."
    }
  }
  if ($DC) {
    Set-PowerCfg -Flag:'/setdcvalueindex' `
                 -SettingGUID:$ProcThrottleMinGUID `
                 -Value:$MinThrottleValue
  }
}

if ($TurboBoost) {
  switch ($TurboBoost) {
    'on' { $MaxThrottleValue = 100 }
    'off' { $MaxThrottleValue = 99 }
  }
  if ($AC) {
    Set-PowerCfg -Flag:'/setacvalueindex' `
                 -SettingGUID:$ProcThrottleMaxGUID `
                 -Value:$MaxThrottleValue
  }
  if ($DC) {
    Set-PowerCfg -Flag:'/setdcvalueindex' `
                 -SettingGUID:$ProcThrottleMaxGUID `
                 -Value:$MaxThrottleValue
  }
}

if ($IntelThermal) {
  switch ($IntelThermal) {
    'hi' { $ThermalValue = 2 }
    'med' { $ThermalValue = 1 }
    'lo' { $ThermalValue = 0 }
  }
  if ($AC) {
    Set-PowerCfgEx -Flag:'/setacvalueindex' `
                   -Subgroup:$IntelThermalSubgroupGUID `
                   -Setting:$IntelThermalSettingGUID `
                   -Value:$ThermalValue
  }
  if ($DC) {
    Set-PowerCfgEx -Flag:'/setdcvalueindex' `
                   -Subgroup:$IntelThermalSubgroupGUID `
                   -Setting:$IntelThermalSettingGUID `
                   -Value:$ThermalValue
  }
}

if ($Query) {
  powercfg /q $SchemeGUID $ProcPowerMgmtGUID
} else {
  if (-not $ShowGUIDs) {
    if ((-not ($AC -or $DC)) -or ($TurboBoost -eq $null -and $Minimum -eq $null)) {
      Write-Stderr "No args specified!"
      Write-Stderr "Use -Query, -ShowGUIDs for info."
      Write-Stderr "Use -Minimum=Hi|Lo, -TurboBoost=On|Off with -AC or -DC to change settings."
      exit 1
    }
  }
}
