# Purpose: Downloads Python Pillow and installs from binary
# This is to allow Cuckoo to take screenshots of the desktop during analysis

Write-Host "$('[{0:HH:mm}]' -f (Get-Date)) Downloading and installing Python Pillow"

$pillowDownloadLocation = 'C:\Users\vagrant\AppData\Local\Temp\Pillow.tar.gz'
if (-not (Test-Path $pillowDownloadLocation))
{
  [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
  Invoke-WebRequest -Uri "https://files.pythonhosted.org/packages/81/1a/6b2971adc1bca55b9a53ed1efa372acff7e8b9913982a396f3fa046efaf8/Pillow-6.0.0.tar.gz" -OutFile $pillowDownloadLocation
}
else
{
  Write-Host "$pillowDownloadLocation already exists. Moving on"
}
Write-Host "$('[{0:HH:mm}]' -f (Get-Date)) Pillow download complete"

Write-Host "$('[{0:HH:mm}]' -f (Get-Date)) Installing Python Pillow"
c:\python27\python.exe -m pip install Pillow 2>$null
Write-Host "$('[{0:HH:mm}]' -f (Get-Date)) Python Pillow has been installed"
