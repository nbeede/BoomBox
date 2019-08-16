
<#
.Synopsis
  This script is used to build, deploy, and configure BoomBox

.DESCRIPTION
  This script will check that prerequisite software is installed before executing the BoomBox deployment.

  * Packer and Vagrant
  * Virtualbox
  * Necessary Vagrant plugins

.PARAMETER PackerPath
  The full path to the packer executable. Default is
  C:\Hashicorp\packer.exe

.PARAMETER PackerOnly
  This switch skips deploying boxes with vagrant after being built by packer

.PARAMETER VagrantOnly
  This switch skips building packer boxes and instead builds from an existing box file.

.EXAMPLE
  build.ps1 -ProviderName virtualbox

  This builds BoomBox using virtualbox and the default path for Packer (C:\Hashicorp\packer.exe)

.EXAMPLE
  build.ps1 -ProviderName virtualbox -PackerPath 'C:\packer.exe'

  This builds BoomBox using virtuaLbox and a custom path for Packer.
#>

[cmdletbinding()]
Param(
  [ValidateSet('virtualbox')]
  [string]$ProviderName,
  [string]$PackerPath = 'C:\Hashicorp\packer.exe',
  [switch]$PackerOnly,
  [switch]$VagrantOnly
)

$DL_DIR = Split-Path -Parent -Path $MyInvocation.MyCommand.Definition
$HOSTS = ('sandbox', 'cuckoo')

function check_packer {
  if (!(Test-Path $PackerPath)) {
    Write-Error "Packer not found at $PackerPath"
    Write-Output 'Re-run the script setting the PackerPath parameter to the location of packer'
    Write-Output "Example: build.ps1 -PackerPath 'C:\packer.exe'"
    Write-Output 'Exiting..'
    break
  }
}

function check_vagrant {
  try {
    Get-Command vagrant.exe -ErrorAction Stop | Out-Null
  }
  catch  {
    Write-Error 'Vagrant was not found. Please install vagrant and re-run this script.'
    break
  }
}

function check_virtualbox {
  Write-Host '[check_virtualbox] Checking that Virtualbox is installed...'
  if (install_checker -Name "VirtualBox") {
    Write-Host '[check_virtualbox] Virtualbox found.'
    check_vboxmanage
    return $true
  }
  else {
    Write-Host '[check_virtualbox] Virtualbox not found.'
    return $false
  }
}

function check_vboxmanage {
  $VBoxManage = "C:\Program Files\Oracle\VirtualBox\VBoxManage.exe"
  Write-Host '[check_vboxmanage] Checking for vboxmanage...'
  if (![bool](Get-Command -Name $VBoxManage -ErrorAction SilentlyContinue)) {
    Write-Output "VBoxManage.exe was not found at $VBoxManage. Please correct the path to VBoxManage.exe in this build script if you installed VirtualBox in another location."
    break
  }
}

function install_checker {
  param(
    [string]$Name
  )
  $results = Get-ItemProperty 'HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*' | Select-Object DisplayName
  $results += Get-ItemProperty 'HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*' | Select-Object DisplayName

  forEach ($result in $results) {
    if ($result -like "*$Name*") {
      return $true
    }
  }
  return $false
}

function list_providers {
  [cmdletbinding()]
  param()

  if (-Not (check_virtualbox)) {
    Write-Error 'You need to install Virtualbox to continue.'
    break
  }
  else {
    Write-Host 'Available Providers: '
    Write-Host '[*] virtualbox'
  }
  while (-Not ($ProviderName -eq 'virtualbox')) {
    $ProviderName = Read-Host 'Which provider would you like to use?'
    Write-Debug "ProviderName = $ProviderName"
    if (-Not ($ProviderName -eq 'virtualbox')) {
      Write-Error "Please choose a valid provider. $ProviderName is not a valid option"
    }
  }
  return $ProviderName
}

function prereq_checks {
  Write-Host 'Checking that required software is installed...'
  if (!($VagrantOnly)) {
    Write-Host 'Checking if Packer is installed'
    check_packer
  }
  if (!($PackerOnly)) {
    Write-Host 'Checking if Vagrant is installed...'
    check_vagrant

    Write-Host "Checking for pre-existing boxes..."
    if ((Get-ChildItem "$DL_DIR\Boxes\*.box").Count -gt 0) {
      Write-Host 'You seem to have at least one .box file present in the Boxes directory already. If you would like fresh boxes download, please remove all files from the Boxes directory and re-run this script.'
    }
  }

  Write-Host 'Checking for vagrant instances...'
  $CurrentDir = Get-Location
  Set-Location "$DL_DIR\Vagrant"
  if (($(vagrant status) | Select-String -Pattern "not[ _]created").Count -ne 2) {
    Write-Error 'There is already at least one vagrant instance. This script does not support already created instanced. Please destroy existing instance.'
    break
  }
  Set-Location $CurrentDir

  # Check disk space. Recommended 40GB free, warn if less.
  Write-Host 'Checking disk space...'
  $drives = Get-PSDrive | Where-Object {$_.Provider -like '*FileSystem*'}
  $drivesList = @()

  forEach ($drive in $drives) {
    if ($drive.free -lt 40GB) {
      $drivesList = $drivesList + $drive
    }
  }

  if ($drivesList.Count -gt 0) {
    Write-Output "The following drives have less than 20GB of free space and should not be used for deploying BoomBox"
    forEach ($drive in $drivesList) {
      Write-Output "[*] $($drive.Name)"
    }
    Write-Output "You can ignore this warning if you are deploying BoomBox on another drive."
  }

  # Ensure that vagrant-reload is installed
  Write-Host "Checking if the vagrant-reload plugin is installed"
  if (-Not (vagrant plugin list | Select-String 'vagrant-reload')) {
    Write-Output "The vagrant-reload plugin is required but is not currently installed. This script will attempt to install it now."
    (vagrant plugin install 'vagrant-reload')
    if ($LASTEXITCODE -ne 0) {
      Write-Error "Unable to install the vagrant-reload plugin. Please try to do so manually and re-run this script."
      break
    }
  }
  Write-Host "Prerequisite checks have finished."
}

# run packer
function packer_build_box {
  param(
    [string]$Box
  )

  Write-Host "Running Packer for $Box"
  $CurrentDir = Get-Location
  Set-Location "$DL_DIR\Packer"
  Write-Output "Using Packer to build the $Box Box. This can take 90-180 minutes depending on bandwidth and hardware."
  $env:PACKER_LOG=1
  $env:PACKER_LOG_PATH="$DL_DIR\Packer\packer.log"
  &$PackerPath @('build', "--only=$PackerProvider-iso", "$box.json")
  Write-Host "Finished for $Box. Got exit code: $LASTEXITCODE"

  if ($LASTEXITCODE -ne 0) {
    Write-Error "Something went wrong while attempting to build the $Box box."
    break
  }
  Set-Location $CurrentDir
}

function move_boxes {
  Write-Host "[move_boxes] Running..."
  Move-Item -Path $DL_DIR\Packer\*.box -Destination $DL_DIR\Boxes
  if (-Not (Test-Path "$DL_DIR\Boxes\sandbox_$PackerProvider.box")) {
    Write-Error "sandbox box is missing from the Boxes directory. Quitting."
    break
  }
  Write-Host "[move_boxes] Finished."
}

function vagrant_up_host {
  param(
    [string]$VagrantHost
  )
  Write-Host "[vagrant_up_host] Running for $VagrantHost"
  Write-Host "Attempting to bring up the $VagrantHost host using Vagrant..."
  Write-Host "Verbose output can be found in Vagrant\vagrant_up_$VagrantHost.log"
  $CurrentDir = Get-Location
  Set-Location "$DL_DIR\Vagrant"
  set VAGRANT_LOG=info
  &vagrant.exe @('up', $VagrantHost, '--provider', "$ProviderName") 2>&1 | Out-File -FilePath ".\vagrant_up_$VagrantHost.log"
  Set-Location $CurrentDir
  Write-Host "[vagrant_up_host] Finished for $VagrantHost. Got exit code: $LASTEXITCODE"
  return $LASTEXITCODE
}

function vagrant_reload_host {
  param(
    [string]$VagrantHost
  )
  Write-Host "[vagrant_reload_host] Running for $VagrantHost"
  $CurrentDir = Get-Location
  Set-Location "$DL_DIR\Vagrant"
  &vagrant.exe @('reload', $VagrantHost, '--provision') 2>&1 | Out-File -FilePath ".\vagrant_up_$VagrantHost.log" -Append
  Set-Location $CurrentDir
  Write-Host "[vagrant_reload_host] Finished for $VagrantHost. Got exit code: $LASTEXITCODE"
  return $LASTEXITCODE
}

function post_build_checks {
  # check that everything built and installed correctly.
  # cuckoo web server / agent / snapshot / vm running
}

function create_snapshot {
  # stub code to validate that vboxmanage exists
  $VBoxManage = "C:\Program Files\Oracle\VirtualBox\VBoxManage.exe"
  if (![bool](Get-Command -Name $VBoxManage -ErrorAction SilentlyContinue)) {
    Write-Output "VBoxManage.exe was not found at $VBoxManage. Please correct the path to VBoxManage.exe in this build script if you installed VirtualBox in another location."
  }
  Write-Host "Powering off sandbox to remove NAT network adapter..."
  &$VBoxManage @('controlvm', 'sandbox', 'poweroff')
  Start-sleep -Seconds 5
  &$VBoxManage @('modifyvm', 'sandbox', '--nic1', 'null')
  Start-Sleep -Seconds 5
  Write-Host "Starting sandbox and taking a base snapshot..."
  &$VBoxManage @('startvm', 'sandbox')
  Start-Sleep -Seconds 5
  &$VBoxManage @('snapshot', 'sandbox', 'take', 'base', '--pause')
  Start-Sleep -Seconds 5
  Write-Host "Successfully completed sandbox snapshot!"
}

# TODO: support more providers
if ($ProviderName -eq $Null -or $ProviderName -eq "") {
  $ProviderName = list_providers
}

$PackerProvider = $ProviderName

# Check for prerequisite software
prereq_checks

# Build Packer Boxes
if (!($VagrantOnly)) {
  packer_build_box -Box 'sandbox'
  move_boxes
}

if (!($PackerOnly)) {
  # Vagrant up each box and attempt to reload one time if it fails
  forEach ($VAGRANT_HOST in $HOSTS) {
    Write-Host "[main] Running vagrant_up_host for: $VAGRANT_HOST"
    $result = vagrant_up_host -VagrantHost $VAGRANT_HOST
    Write-Host "[main] vagrant_up_host finished. Exitcode: $result"
    if ($result -eq '0') {
      Write-Output "Good news! $VAGRANT_HOST was built successfully!"
    }
    else {
      Write-Warning "Something went wrong while attempting to build the $VAGRANT_HOST box."
      Write-Output "Attempting to reload and reprovision the host..."
      Write-Host "[main] Running vagrant_reload_host for: $VAGRANT_HOST"
      $retryResult = vagrant_reload_host -VagrantHost $VAGRANT_HOST
      if ($retryResult -ne 0) {
        Write-Error "Failed to bring up $VAGRANT_HOST after a reload. Exiting"
        break
      }
    }
    Write-Host "[main] Finished for: $VAGRANT_HOST"
  }

  Write-Host "[main] Running post_build_checks"
  #post_build_checks
  Write-Host "[main] Finished post_build_checks"
  Write-Host "[main] Creating a base snapshot for sandbox"
  create_snapshot
}
