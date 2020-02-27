param([switch]$HiMin, [switch]$LoMin, [switch]$DisableTurboBoost, [switch]$EnableTurboBoost)
# GUIDs:
# - High performance power plan
# - Processor power management
# - PROCTHROTTLEMAX
# Set to 99 for max without turbo boost.
# powercfg /setdcvalueindex 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c 54533251-82be-4824-96c1-47b60b740d00 893dee8e-2bef-41e0-89c6-b55d0929964c 99
if ($HiMin -and $LoMin) {
  Write-Host "HiMin + LoMin combination invalid!"
  exit 1
}
if ($DisableTurboBoost -and $EnableTurboBoost) {
  Write-Host "DisableTurboBoost + EnableTurboBoost combination invalid!"
  exit 1
}

$DidAction = $false

if ($HiMin -or $LoMin) {
  if ($HiMin) {
    $MinValue = 99
  } else {
    $MinValue = 5 # Default min from powercfg.
  }
  powercfg /setdcvalueindex 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c 54533251-82be-4824-96c1-47b60b740d00 PROCTHROTTLEMIN $MinValue
  $DidAction = $true
  if ($LASTEXITCODE -eq 0) {
    echo "Set PROCTHROTTLEMIN=$MinValue"
  } else {
    echo "Error!"
    exit $LASTEXITCODE
  }
}

if ($DisableTurboBoost -or $EnableTurboBoost) {
  if ($DisableTurboBoost) {
    $MaxValue = 99
  } else {
    $MaxValue = 100
  }
powercfg /setdcvalueindex 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c 54533251-82be-4824-96c1-47b60b740d00 PROCTHROTTLEMAX 99
  $DidAction = $true
  if ($LASTEXITCODE -eq 0) {
    echo "Set PROCTHROTTLEMAX=$MaxValue"
  } else {
    echo "Error!"
    exit $LASTEXITCODE
  }
}

if (-not $DidAction) {
  echo "No action specified: use -[Hi|Lo]Min, -[Disable|Enable]TurboBoost"
}
