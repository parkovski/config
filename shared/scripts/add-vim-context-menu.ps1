if ($args[0] -eq 'vim') {
  $name = 'Vim'
  $vim = "$HOME\scoop\apps\vim\current\gvim.exe"
} elseif ($args[0] -eq 'nvim') {
  $name = 'Neovim'
  $vim = "$HOME\scoop\apps\neovim\current\Neovim\bin\nvim-qt.exe"
} else {
  echo "Specify vim or nvim!"
  exit 1
}

if (-not ($vim)) {
  echo "Vim not found!"
  exit 1
}

echo "$name -> $vim"

pushd -LiteralPath "HKCU:\Software\Classes\*\shell"
New-Item -Name $name -ItemType Key
Set-ItemProperty .\$name\ "(Default)" -Type ExpandString -Value "Open with $name"
Set-ItemProperty .\$name\ Icon $vim
New-Item .\$name\ -Name command -ItemType Key
Set-ItemProperty .\$name\command\ "(Default)" "`"$vim`" `"%1`"" -Type ExpandString
popd

