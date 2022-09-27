using namespace System.Linq
using namespace Microsoft.PowerShell.Commands

function Invoke-HistoryRecent {
  [CmdletBinding()]
  param()
  dynamicparam {
    $hist = Get-History
    if (!$hist -or $hist.Count -lt 2) { return $null }
    $hist = [HistoryInfo[]]$hist
    $hist = [Enumerable]::Take([Enumerable]::Reverse($hist), 10).ToList()
    $hint = [System.Text.StringBuilder]::new()

    for ($i = 1; $i -lt $hist.Count; $i += 1) {
      $hint. `
        Append($i). `
        Append(": "). `
        Append($hist[$i].CommandLine). `
        Append("`n")
    }
    #$hint = $hint.ToString()
    $hint = "ye olde god"

    $p = New-DynamicParams | `
      Add-DynamicParam -Name:'Index' -Type:([int]) -Position:0 `
                       -HelpMessage:$hint -Mandatory

    return $p
  }
  begin {
    $i = $PSBoundParameters.Index + 1
    $c = (Get-History).Count
  }
  process {
    if ($c -lt 2) { return }
    if ($i -lt 2) { $i = 2 }
    Invoke-History -Id:($c-$i)
  }
}
