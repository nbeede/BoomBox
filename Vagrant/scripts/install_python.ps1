# Purpose: Downloads all prequisite software required by cuckoo guest
# This is intended to be executed before installing the agent and taking a snapshot

Write-Host "$('[{0:HH:mm}]' -f (Get-Date)) Installing Python2"
choco install python2

Write-Host "$('[{0:HH:mm}]' -f (Get-Date)) Installing pip"
choco install pip 