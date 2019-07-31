Write-Host "$('[{0:HH:mm}]' -f (Get-Date)) Disabling Windows Firewall"
Set-NetFirewallProfile -Profile Domain,Public,Private -Enabled False