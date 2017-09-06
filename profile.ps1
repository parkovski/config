function download {
  param($from, $to)
  (curl $from).Content > $to
}

function escape_for_bash {
  param($str)
  $out = ""
  foreach ($c in $str.ToCharArray()) {
    if ($c -eq "\") {
      $out += "\\"
    } elseif ($c -eq "`"") {
      $out += "\`""
    } else {
      $out += $c
    }
  }
  return $out
}

function escape_for_zsh {
  param($str)
  $out = ""
  foreach ($c in $str.ToCharArray()) {
    if ($c -eq "\") {
      $out += "\\\\"
    } elseif ($c -eq "`"") {
      $out += "\\\`""
    } else {
      $out += $c
    }
  }
  return $out
}

function concat_args {
  $s = ""
  foreach ($arg in $args) {
    $s += $arg + " "
  }
  return $s
}

function c { cmd /c @args }
function b {
  $s = escape_for_bash(concat_args($args))
  echo $s
  bash -c "$s"
}
function z {
  $s = escape_for_zsh(concat_args($args))
  echo $s
  bash -c "zsh -c \`"$s\`""
}

function zsh {
  bash -c zsh
}

function in {
  param($dir, $cmd)
  pushd $dir
  & $cmd $args[-2..-1]
  popd
}

if (test-path Alias:cd) {
  rm -force Alias:cd
}
function cd {
  if ($args.Length -eq 0) {
    Set-Location ~
  } else {
    Set-Location @args
  }
}

$GH = "$home\Documents\GitHub"
function gh {
  [CmdletBinding()]
  param()
  dynamicparam {
    $projects = $(ls "$home\Documents\GitHub" | %{$_.name})
    return $(&"$HOME\bin\lib\mktabcomplete.ps1" -name "project" -mandatory $false -help "Project name" -values $projects)
  }
  process {
    cd $home\Documents\GitHub\$project
  }
}

$env:EDITOR='vim'
$env:PATH=$env:PATH+";$HOME\Downloads\OpenSSH-Win64"
Set-PSReadlineOption -EditMode vi
Set-PSReadlineOption -BellStyle None
Set-PSReadlineKeyHandler -Key Tab -Function Complete
Set-PSReadlineKeyHandler -Key Ctrl+[ -Function ViCommandMode

