function Invoke-HistoryRecent {
  [CmdletBinding()]
  param()
  dynamicparam {
    $hist = Get-History
    $hc = $hist.Count

    # FIXME
    if ($hc -ge 10) {
      $hist = $hist[-10 .. -1]
    }
    #$values = [System.Linq.Enumerable]::Count(1, $hist.Count)
    $hint = [System.Text.StringBuilder]::new("History count: $hc")
    for ($i = 0; $i -lt $hist.Count; $i += 1) {
      $hint.Append("`n").
        Append($i + 1).
        Append(": ").
        Append($hist[$hc - $i - 1].CommandLine)
    }
    # hint = $values | Select-Object { "${_}: " + $hist[-$_] + "\n" }
    $p = New-DynamicParams `
      | Add-DynamicParam -Name:'Index' `
        -Type:([int]) -Position:0 `
        -helpmessage:'hi' #-HelpMessage:($hint.ToString()) -Values:$values
    return $p
  }
  begin {
    $i = $PSBoundParameters.Index
    if ($i -eq 0) { $i = 1 }
    elseif ($i -lt 0) { $i = -$i }
  }
  process {
    $hist = Get-History
    $hc = $hist.Count

    Invoke-History -Id:($hc-$i)
  }
}
