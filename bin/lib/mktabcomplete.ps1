param([string]$name, [bool]$mandatory, [string]$help, [string[]]$values)

$attrs = new-object -type System.Collections.ObjectModel.Collection[System.Attribute]
$pattr = new-object -type System.Management.Automation.ParameterAttribute
$pattr.Mandatory = $mandatory
$pattr.HelpMessage = $help
$pattr.Position = 0
$attrs.Add($pattr)
$vattr = new-object -type System.Management.Automation.ValidateSetAttribute($values)
$attrs.add($vattr)
$rtparam = new-object -Type System.Management.Automation.RuntimeDefinedParameter($name, [String], $attrs)
$params = new-object -type System.Management.Automation.RuntimeDefinedParameterDictionary
$params.Add($name, $rtparam)
return $params
