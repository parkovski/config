iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
choco feature enable -n allowGlobalConfirmation

choco install vim
choco install git --params="/GitOnlyOnPath /WindowsTerminal /NoShellIntegration"
choco install conemu
choco install nvm
choco install 7zip
choco install doxygen.install
choco install python2
choco install python3
choco install vcxsrv
choco install cmake

# big/missing apps:
# vscode
# unity
# visual studio
# firefox dev edition
# chrome
# WSL/Ubuntu
# Rust via Rustup
# OpenSSH-Win64
# postgres
# fl studio
