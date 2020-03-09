Write-Host "$('[{0:HH:mm}]' -f (Get-Date)) Installing legacy cuckoo agent.py to sandbox"
$agentStartupFolder = "C:\Users\vagrant\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Startup"
$cuckooAgent = 'C:\Users\vagrant\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Startup\spy.pyw'
add-type @"
    using System.Net;
    using System.Security.Cryptography.X509Certificates;
    public class TrustAllCertsPolicy : ICertificatePolicy {
        public bool CheckValidationResult(
            ServicePoint srvPoint, X509Certificate certificate,
            WebRequest request, int certificateProblem) {
            return true;
        }
    }
"@
[System.Net.ServicePointManager]::CertificatePolicy = New-Object TrustAllCertsPolicy



Invoke-WebRequest https://raw.githubusercontent.com/cuckoosandbox/cuckoo/2.0-rc2/agent/agent.py -o "C:\Users\vagrant\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Startup\spy.pyw"
&$cuckooAgent
