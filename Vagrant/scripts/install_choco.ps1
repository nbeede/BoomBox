Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
choco feature enable -n allowGlobalConfirmation
choco install virtualbox-guest-additions-guest.install
#Write-Host "$('[{0:HH:mm}]' -f (Get-Date)) Installing Adobe Reader"
#choco install adobereader
#Write-Host "$('[{0:HH:mm}]' -f (Get-Date)) Installing Firefox"
#choco install firefox
