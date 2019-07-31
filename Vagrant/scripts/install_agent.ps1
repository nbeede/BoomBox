Write-Host "$('[{0:HH:mm}]' -f (Get-Date)) Installing legacy cuckoo agent.py to sandbox"
$agentStartupFolder = "C:\Users\vagrant\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Startup"
$cuckooAgent = 'C:\Users\vagrant\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Startup\spy.pyw'
Invoke-WebRequest https://raw.githubusercontent.com/cuckoosandbox/cuckoo/2.0-rc2/agent/agent.py -o "C:\Users\vagrant\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Startup\spy.pyw"
&$cuckooAgent
