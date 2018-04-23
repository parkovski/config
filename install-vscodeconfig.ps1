param([switch]$SyncUpdates)

if ($OS -eq "Windows") {
  if ($SyncUpdates) {
    cp $HOME\AppData\Roaming\Code\User\*.json .\vscode
  } else {
    cp vscode\* $HOME\AppData\Roaming\Code\User
  }
} else {
  $sync = ''
  if ($SyncUpdates) { $sync = '--sync' }
  #$GH\config\install-vscodeconfig.sh $sync
}
