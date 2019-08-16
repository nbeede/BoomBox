![GitHub Release Date](https://img.shields.io/github/release-date/nbeede/BoomBox)
![Latest GitHub release](https://img.shields.io/github/release/nbeede/BoomBox)
# BoomBox

BoomBox is designed for malware analysts and incident responders. It allows for the rapid deployment of a dynamic malware analysis environment using Cuckoo Sandbox and a Windows 10 detonation chamber. Cuckoo is configured to use the physical machinery so that both Cuckoo and the Windows sandbox can be virtual machines on a single host.

## Features

*   Inetsim network simulation
*   Cuckoo community modules
*   Clean base snapshot of the Windows environment is taken as part of the build process
*   Chocolatey package manager for Windows used to install Adobe Reader, Flash, Chrome, and Firefox.
    *   **NOTE:** Microsoft Office has not been included due to licensing. If you have a license key, you can install Office and take a new clean base snapshot.


## Requirements
*   20GB+ of free disk space
*   6GB+ of RAM
*   [Packer](https://www.packer.io/downloads.html)
*   [Vagrant](https://www.vagrantup.com/downloads.html)
*   [VirtualBox](https://www.virtualbox.org/wiki/Downloads)

## Quickstart

BoomBox includes a single build script for Linux, macOS, and Windows. This script will build and configure the Windows 10 and Cuckoo virtual machines from the ground up using Packer and Vagrant. The entire build process for BoomBox takes around 30-60 minutes.

### Linux/macOS
-   `./build.sh virtualbox` - Build BoomBox from scratch.
-   `./build.sh virtualbox --vagrant-only` - Build BoomBox using pre-built Packer boxes hosted on Vagrant Cloud. This option is faster than building BoomBox from scratch.
-   `./build.sh virtualbox --packer-only` - This will only build the .Box files and will not build the VMs using Vagrant.

### Windows
-   `./build.ps1 -ProviderName virtualbox` - Build BoomBox from scratch.
-   `./build.ps1 -ProviderName virtualbox -VagrantOnly` - Build BoomBox using pre-built Packer boxes hosted on Vagrant Cloud. This option is faster than building BoomBox from scratch.
-   `/.build.ps1 -ProviderName virtualbox -PackerOnly` - This will only build the .Box files and will not build the VMs using Vagrant.

## Manually Building BoomBox
1.  Build the Windows sandbox using Packer

```
$ cd BoomBox/Packer
$ packer build --only=virtualbox-iso sandbox.json
```

2.  Move the resulting .box file into the Boxes directory

    `mv sandbox_virtualbox.box ../Boxes`

3.  `cd ../Vagrant` and inside the Vagrantfile change `cfg.vm.box = "boomboxes/sandbox"` to `cfg.vm.box = ../Boxes/sandbox_virtualbox.box`

4.  Install the Vagrant-Reload plugin

    `vagrant plugin install vagrant-reload`

5.  Run the `./build.sh` for Linux/macOS or `./build.ps1` for Windows from the project root directory

6.  Logs from the build process are located in the `Vagrant` directory as `vagrant_up_<host>.log`

## Basic Vagrant Usage
Vagrant commands must be run from the "Vagrant" folder.

*   Bring up all BoomBox hosts: `vagrant up`
*   Bring up a specific host: `vagrant up <hostname>`
*   Restart a specific host: `vagrant reload <hostname>`
*   Restart a specific host and re-run the provision process: `vagrant reload <hostname> --provision`
*   Destroy a specific host `vagrant destroy <hostname>`
*   Destroy the entire BoomBox environment: `vagrant destroy` (Adding `-f` forces it without a prompt)
*   SSH into a host: `vagrant ssh cuckoo`
*   Check the status of each host: `vagrant status`
*   Suspend the environment: `vagrant suspend`
*   Resume the environment: `vagrant resume`

## Lab Information
*   Cuckoo Web Server: http://192.168.30.100:8080 - vagrant:vagrant
    *   NIC1 attached to NAT
    *   NIC2 attached to Host-only Adapter
*   Windows Sandbox: 192.168.30.101
    *   NIC1 attached to Host-only Adapter

## Snapshots
There are `revert.ps1` and `revert.sh` scripts that are to be used to restore a clean version of the Windows sandbox. This script will need to be run after each submission to Cuckoo to ensure a consistent detonation environment. This is a temporarily solution until there is a good way to have this done automatically after each detonation.

## Todo
- [ ]  Sandbox anti-evasion techniques
- [ ]  Improve revert scripts to not rely on sleep
- [ ]  Revert sandbox to clean snapshot on reboot
- [ ]  Support additional Vagrant providers

## Contributing
Check out [CONTRIBUTING.md](./CONTRIBUTING.md) for details on submitting a pull request.

## Credits
The majority of this project was directly borrowed from Chris Long's [DetectionLab](https://github.com/clong/DetectionLab), which is an incredible resource for defenders looking to build a Windows lab.
