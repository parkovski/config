function New-DynamicParams {
  New-Object -Type System.Management.Automation.RuntimeDefinedParameterDictionary
}

function Add-DynamicParam {
  param(
    [Parameter(Mandatory=$true, ValueFromPipeline=$true)]
    [ValidateNotNull()]
    [System.Management.Automation.RuntimeDefinedParameterDictionary]
    $Dict,

    [ValidateNotNullOrEmpty()]
    [Parameter(Mandatory=$true, Position=0)]
    [string]
    $Name,

    [ValidateNotNull()]
    [Type]
    $Type = [object],

    [switch]$Mandatory=$false,
    [string]$HelpMessage=$null,
    [int]$Position=-1,
    $Values=$null,
    [switch]$NotNull=$false,
    [switch]$NotNullOrEmpty=$false
  )

  $attrs = New-Object -Type System.Collections.ObjectModel.Collection[System.Attribute]
  $pattr = New-Object -Type System.Management.Automation.ParameterAttribute
  if ($Mandatory) {
    $pattr.Mandatory = $true
  }
  $pattr.HelpMessage = $HelpMessage
  if ($Position -ge 0) {
    $pattr.Position = $Position
  }
  $attrs.Add($pattr)
  if ($Values -ne $null) {
    $vattr = New-Object -Type System.Management.Automation.ValidateSetAttribute($Values)
    $attrs.Add($vattr)
  }
  if ($NotNull) {
    $vattr = New-Object -Type System.Management.Automation.ValidateNotNullAttribute
    $attrs.Add($vattr)
  }
  if ($NotNullOrEmpty) {
    $vattr = New-Object -Type System.Management.Automation.ValidateNotNullOrEmptyAttribute
    $attrs.Add($vattr)
  }
  $rtparam = New-Object -Type System.Management.Automation.RuntimeDefinedParameter($Name, $Type, $attrs)
  $Dict.Add($Name, $rtparam)
  $Dict
}
