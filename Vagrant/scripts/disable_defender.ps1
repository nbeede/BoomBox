# Disable Windows Defender
Write-host Disable Windows Defender
reg add "HKLM\Software\Policies\Microsoft\Windows Defender" /v DisableAntiSpyware /t REG_DWORD /f /d 1
