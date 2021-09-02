# Purpose: Install chocolatey to install various windows packages
# Using TLS1.2
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

Write-Host "$('[{0:HH:mm}]' -f (Get-Date)) Installing Chocolatey"
$chocoInstall = "C:\ProgramData\chocolatey"
if (-not(Test-Path $chocoInstall))
{
  Invoke-Expression ((new-object net.webclient).DownloadString('https://chocolatey.org/install.ps1'))
  Write-Host "Chocolatey is now installed"
}
else
{
  Write-Host "Chocolatey is already installed"
}
choco feature enable -n allowGlobalConfirmation
choco install virtualbox-guest-additions-guest.install
#Write-Host "$('[{0:HH:mm}]' -f (Get-Date)) Installing Adobe Reader"
#choco install adobereader
#Write-Host "$('[{0:HH:mm}]' -f (Get-Date)) Installing Firefox"
#choco install firefox
