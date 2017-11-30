param([switch]$SyncUpdates)

if ($SyncUpdates) {
  cp $HOME\AppData\Roaming\Code\User\*.json .\vscode
} else {
  cp vscode\* $HOME\AppData\Roaming\Code\User
}
