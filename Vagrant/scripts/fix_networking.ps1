# Purpose: Force internal network gateway and DNS settings for inetsim routing
Remove-NetIPAddress 192.168.30.101 -Confirm:$false
New-NetIPAddress -InterfaceAlias 'Ethernet 2' -IPAddress '192.168.30.101' -PrefixLength 24 -DefaultGateway '192.168.30.100'
Set-DnsClientServerAddress -InterfaceAlias 'Ethernet 2' -ServerAddresses 192.168.30.100
