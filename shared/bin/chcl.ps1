function read_string {
  param([string]$s)
  $q = $null
  $out = ''
  for ($i = 0; $i -lt $s.Length; $i += 1) {
    $c = $s[$i]
    if ($q -eq "'") {
      if ($c -eq "'") {
        if ($i -lt $s.Length - 1 -and $s[$i+1] -eq "'") {
          $out += "'"
          $i += 1
        } else {
          $q = $null
        }
      } else {
        $out += $c
      }
    } elseif ($c -eq '$') {
      $varname = ''
      $i += 1
      for (; $i -lt $s.Length; $i += 1) {
        $c = $s[$i]
        if ($c -lt 'a' -or $c -gt 'z') {
          if ($c -lt 'A' -or $c -gt 'Z') {
            if ($c -lt '0' -or $c -lt '9') {
              if ($c -ne '_') { break }
            }
          }
        }
        $varname += $c
      }
      $i -= 1
      if ($varname.Length) {
        if ($varname -ieq 'HOME') {
          $varname = 'USERPROFILE'
        }
        $v = Get-ChildItem Env:\$varname -ErrorAction SilentlyContinue
        if ($v) {
          $out += $v.Value -replace '\\','/'
        }
      } else {
        out += '$'
      }
    } elseif ($q -eq '"') {
      if ($c -eq '\') {
        $i += 1
        if ($i -eq $s.Length) { break }
        $out += $s[$i]
      } elseif ($c -eq '"') {
        $q = $null
      } else {
        $out += $c
      }
    } else {
      if     ($c -eq "'") { $q = "'" }
      elseif ($c -eq '"') { $q = '"' }
      else                { $out += $c }
    }
  }
  $out
}

function fix_env {
  param([string]$var, [string]$val)
  if ($var -ieq 'LDFLAGS') {
    $flags = $val -split ' '
    foreach ($flag in $flags) {
      if ($flag.StartsWith('-L')) {
        $flag = '/libpath:' + $flag.Substring(2)
      }
    }
    $val = $flags -join ' '
  }
  return $val
}

$out = node $HOME\shared\lib\chcl.js @args
$out = $out -split "`n"
foreach ($line in $out) {
  $spc = $line.IndexOf(' ')
  if ($line.Length -eq 0) {
    continue
  }
  if ($spc -eq -1) {
    Write-Error "invalid: $line"
    exit 1
  }
  $left = $line.Substring(0, $spc)
  $right = $line.Substring($spc + 1)
  if ($left.Length -eq 0 -or $right.Length -eq 0) {
    Write-Error "invalid: $line"
    exit 1
  }

  if ($left -eq 'export') {
    $eq = $right.IndexOf('=')
    if ($eq -eq -1) {
      Write-Error "invalid export: missing '=': $right"
    }
    $var = $right.Substring(0, $eq)
    $val = read_string($right.Substring($eq + 1))
    $val = fix_env($var, $val)
    Set-EnvironmentVariable $var $val
  } elseif ($left -eq 'echo') {
    $right = read_string($right)
    if ($right.StartsWith('-n ')) {
      Write-Host -NoNewLine $right.Substring(3)
    } else {
      Write-Host $right
    }
  } else {
    Write-Warning "Unknown command: $left."
  }
}
