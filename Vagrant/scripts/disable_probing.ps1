# Purpose: Disable internet connectivity probe that displays a pop-up window
# Purpose: Removing pop-ups caused by inetsim
reg add "HKLM\System\CurrentControlSet\Services\NlaSvc\Parameters\Internet" /v EnableActiveProbing /t REG_DWORD /f /d 0
taskkill /f /im OneDrive.exe
C:\Windows\SysWOW64\OneDriveSetup.exe /uninstall
