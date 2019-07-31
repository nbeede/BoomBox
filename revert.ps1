$VBoxManage = "C:\Program Files\Oracle\VirtualBox\VBoxManage.exe"
Write-Host "Powering off virtual machine..."
&$VBoxManage @('controlvm', 'sandbox', 'poweroff')
Start-Sleep -Seconds 5
&$VBoxManage @('snapshot', 'sandbox', 'restorecurrent')
Start-Sleep -Seconds 5
&$VBoxManage @('startvm', 'sandbox')
