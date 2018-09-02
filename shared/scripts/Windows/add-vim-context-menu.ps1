pushd -LiteralPath "HKCU:\Software\Classes\*\shell"
New-Item -Name Vim -ItemType Key
Set-ItemProperty .\Vim\ "(Default)" -Type ExpandString -Value "Open with Vim"
Set-ItemProperty .\Vim\ Icon "$Home\scoop\apps\vim\current\gvim.exe"
New-Item .\Vim\ -Name command -ItemType Key
Set-ItemProperty .\Vim\command\ "(Default)" "`"$Home\scoop\apps\vim\current\gvim.exe`" `"%1`"" -Type ExpandString
popd

