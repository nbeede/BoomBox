Write-Host "$('[{0:HH:mm}]' -f (Get-Date)) Installing legacy cuckoo agent.py to sandbox"
$agentStartupFolder = "C:\Users\vagrant\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Startup"
$cuckooAgent = 'C:\Users\vagrant\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Startup\spy.pyw'
# GitHub requires TLS 1.2 as of 2/1/2018
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
Invoke-WebRequest https://raw.githubusercontent.com/cuckoosandbox/cuckoo/2.0-rc2/agent/agent.py -o "C:\Users\vagrant\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Startup\spy.pyw"
&$cuckooAgent
