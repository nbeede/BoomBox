Write-Host "$('[{0:HH:mm}]' -f (Get-Date)) Disabling Windows Updates"

# set the Windows Update service to "disabled"
sc.exe config wuauserv start=disabled

# display the status of the service
sc.exe query wuauserv

# stop the service, in case it is running
sc.exe stop wuauserv

# display the status again, because we're paranoid
sc.exe query wuauserv

# double check it's REALLY disabled - Start value should be 0x4
REG.exe QUERY HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\wuauserv /v Start 