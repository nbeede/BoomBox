#!/bin/bash

(echo >&2 "Powering off virtual machine...")
$(which vboxmanage) controlvm sandbox poweroff
sleep 5s
$(which vboxmanage) snapshot sandbox restorecurrent
sleep 5s
$(which vboxmanage) startvm sandbox --type headless
