#! /bin/bash

# Run this script on a fresh clone of BoomBox. It will fail to run if boxes
# have already been created or any of the steps from the README have already
# been executed. Only MacOS and Linux are supported. Use build.ps1 for Windows.

print_usage() {
  echo "Usage: ./build.sh virtualbox [--vagrant-only | --packer-only]"
  exit 0
}

install_deps() {
  apt-get update ; apt-get -y install vagrant packer ruby
  gem install winrm ; gem install winrm-elevated
}

parse_cli_arguments() {
  # If no argument was supplied, list available providers
  if [ "$#" -eq 0 ]; then
    PROVIDER=$(list_providers)
  fi
  # If more than two arguments were supplied, print usage message
  if [ "$#" -gt 2 ]; then
    print_usage
    exit 1
  fi
  if [ "$#" -ge 1 ]; then
    # If the user speicifies the provider as an argument, set the variable.
    case "$1" in
      virtualbox)
      PROVIDER="$1"
      PACKER_PROVIDER="$1"
      ;;
      *)
      echo "\"$1\" is not a valid provider. Listing available providers:"
      PROVIDER=$(list_providers)
      ;;
    esac
  fi
  if [ $# -eq 2 ]; then
    case "$2" in
      --packer-only)
      PACKER_ONLY=1
      ;;
      --vagrant-only)
      VAGRANT_ONLY=1
      ;;
      *)
      echo -e "\"$2\" is not recognized as an option. Available options are:\\n--packer-only\\n--vagrant-only"
      exit 1
      ;;
    esac
  fi
}

list_providers() {
  VBOX_PRESENT=0

  if [ "$(uname)" == "Darwin" ]; then
    # Detect Providers on OSX
    # Place holding for future Vagrant providers
    VBOX_PRESENT=$(check_virtualbox_installed)
  else
    VBOX_PRESENT=$(check_virtualbox_installed)
  fi

  (echo >&2 "Available Providers:")
  if [ "$VBOX_PRESENT" == "1" ]; then
    (echo >&2 "virtualbox")
  fi
  (echo >&2 -e "\\nWhich provider would you like to use?")
  read -r PROVIDER
  # Sanity check
  if [[ "$PROVIDER" != "virtualbox" ]]; then
    (echo >&2 "Please choose a valid provider. \"$PROVIDER\" is not a valid option.")
    exit 1
  fi
  echo "$PROVIDER"
}

check_virtualbox_installed() {
  if which VBoxManage >/dev/null; then
    echo "1"
  else
    echo "0"
  fi
}

check_packer_path() {
  # Check for existence of Packer in PATH
  if ! which packer >/dev/null; then
    (echo >&2 "Packer was not found in your PATH.")
    (echo >&2 "Please correct this before continuing. Quitting.")
    (echo >&2 "You can download it here: https://www.packer.io/downloads.html")
    (echo >&2 "Hint: sudo cp ./packer /usr/local/bin/packer; sudo chmod +x /usr/local/bin/packer")
    exit 1
  fi
}

check_vagrant_path() {
  # Check for existence of Vagrant in PATH
  if ! which vagrant >/dev/null; then
    (echo >&2 "Vagrant was not found in your PATH.")
    (echo >&2 "Please correct this before continuing. Quitting.")
    (echo >&2 "You can download it here: https://www.vagrantup.com/downloads.html")
    (echo >&2 "Hint: sudo cp ./vagrant /usr/local/bin/vagrant; sudo chmod +x /usr/local/bin/vagrant")
    exit 1
  fi
}

check_vagrant_instances_exist() {
  # Check to see if any Vagrant instances exist already
  cd "$DL_DIR"/Vagrant || exit 1
  # Vagrant status has the potential to return a non-zero error code, so we work around it with "|| true"
  VAGRANT_BUILT=$(vagrant status | grep -c 'not created') || true
  if [ "$VAGRANT_BUILT" -ne 2 ]; then
    (echo >&2 "You appear to have already created at least one Vagrant instance of BoomBox. This script does not support pre-created instances. Please either destroy the existing instances or follow the build steps in the README to continue.")
    exit 1
  fi
}

check_vagrant_reload_plugin() {
  # Ensure the vagrant-reload plugin is installed
  VAGRANT_RELOAD_PLUGIN_INSTALLED=$(vagrant plugin list | grep -c 'vagrant-reload')
  if [ "$VAGRANT_RELOAD_PLUGIN_INSTALLED" != "1" ]; then
    (echo >&2 "The vagrant-reload plugin is required and not currently installed. This script will attempt to install it now.")
    if ! $(which vagrant) plugin install "vagrant-reload"; then
      (echo >&2 "Unable to install the vagrant-reload plugin. Please try to do so manually and re-run this script.")
      exit 1
    fi
  fi
}

check_boxes_built() {
  BOXES_BUILT=$(find "$DL_DIR"/Boxes -name "*.box" | wc -l)
  if [ "$BOXES_BUILT" -gt 0 ]; then
    if [ "$VAGRANT_ONLY" -eq 1 ]; then
      (echo >&2 "WARNING: You seem to have at least one .box file present in $DL_DIR/Boxes already. If you would like fresh boxes, please remove all files from the Boxes directory and re-run this script.")
    else
      (echo >&2 "You seem to have at least one .box file in $DL_DIR/Boxes. This script does not support pre-built boxes. Please either delete the existing boxes or follow the build steps in the README to continue.")
      exit 1
    fi
  fi
}

check_disk_free_space() {
  # Check available disk space. Recommend 40GB free, warn if less.
  FREE_DISK_SPACE=$(df -m "$HOME" | tr -s ' ' | grep '/' | cut -d ' ' -f 4)
  if [ "$FREE_DISK_SPACE" -lt 40000 ]; then
    (echo >&2 -e "Warning: You appear to have less than 40GB of HDD space free on your primary partition. If you are using a separate partition, you may ignore this warning.\n")
    (df >&2 -m "$HOME")
    (echo >&2 "")
  fi
}

check_curl() {
  # Check to see if curl is in PATH - needed for post-install checks
  if ! which curl >/dev/null; then
    (echo >&2 "Please install curl and make sure it is in your PATH.")
    exit 1
  fi
}

prereq_checks() {
  # If it's not a Vagrant-only build, then run Packer-related checks
  if [ "$VAGRANT_ONLY" -eq 0 ]; then
    check_packer_path
  fi

  # If it's not a Packer-only build, then run Vagrant-related checks
  if [ "$PACKER_ONLY" -eq 0 ]; then
    check_vagrant_path
    check_vagrant_instances_exist
    check_vagrant_reload_plugin
  fi

  check_boxes_built
  check_disk_free_space
  check_curl
}

# Builds a box using Packer
packer_build_box() {
  # Export the box in $DL_DIR default is /tmp
  export TMP_DIR=$DL_DIR
  BOX="$1"
  cd "$DL_DIR/Packer" || exit 1
  (echo >&2 "Using Packer to build the $BOX Box. This can take 90-180 minutes depending on bandwidth and hardware.")
  PACKER_LOG=1 PACKER_LOG_PATH="$DL_DIR/Packer/packer_build.log"
  $(which packer) build --only="virtualbox-iso" "$BOX".json >&2
  echo "$?"
}

move_boxes() {
  mv "$DL_DIR"/Packer/*.box "$DL_DIR"/Boxes
  if [ ! -f "$DL_DIR"/Boxes/sandbox_virtualbox.box ]; then
    (echo >&2 "Sandbox Box is missing from the Boxes directory. Quitting.")
    exit 1
  fi
}

build_vagrant_hosts() {
  HOSTS=("sandbox" "cuckoo")
  # load backwards for testing to not to build win image
  #HOSTS=("cuckoo" "sandbox")

  # Vagrant up each box and attempt to reload one time if it fails
  for HOST in "${HOSTS[@]}"; do
    RET=$(vagrant_up_host "$HOST")
    if [ "$RET" -eq 0 ]; then
      (echo >&2 "Good news! $HOST was build successfully!")
    fi
    # Attempt to recover if the initial "vagrant up" fails
    if [ "$RET" -ne 0 ]; then
      (echo >&2 "Something went wrong while attempting to build the $HOST box.")
      (echo >&2 "Attempting to reload and reprovision the host...")
      RETRY_STATUS=$(vagrant_reload_host "$HOST")
      if [ "$RETRY_STATUS" -eq 0 ]; then
        (echo >&2 "Good news! $HOST was built successfully after a reload. Exiting.")
      else
        (echo >&2 "Failed to bring up $HOST after a reload. Exiting.")
        exit 1
      fi
    fi
  done
}

vagrant_up_host() {
  HOST="$1"
  (echo >&2 "Attempting to bring up the $HOST host using Vagrant")
  cd "$DL_DIR"/Vagrant || exit 1
  $(which vagrant) up "$HOST" --provider=virtualbox &> "$DL_DIR/Vagrant/vagrant_up_$HOST.log"
  echo "$?"
}

vagrant_reload_host() {
  HOST="$1"
  cd "$DL_DIR"/Vagrant || exit 1
  # Attempt to reload the host if the vagrant up command didn't exit cleanly
  $(which vagrant) reload "$HOST" --provision >> "$DL_DIR/Vagrant/vagrant_up_$HOST.log" 2>&1
  echo "$?"
}

create_snapshot() {
  # Poweroff and remove nat nic first
  (echo >&2 "Powering off sandbox to remove NAT network adapter...")
  $(which vboxmanage) controlvm sandbox poweroff &> "$DL_DIR/Vagrant/sandbox_snapshot.log"
  sleep 5s
  $(which vboxmanage) modifyvm sandbox --nic1 null >> "$DL_DIR/Vagrant/sandbox_snapshot.log"
  sleep 5s
  (echo >&2 "Starting sandbox and taking a base snapshot...")
  $(which vboxmanage) startvm sandbox >> "$DL_DIR/Vagrant/sandbox_snapshot.log"
  sleep 5s
  # Take a snapshot of the sandbox once the agent is running and nat nic is removed.
  $(which vboxmanage) snapshot "sandbox" take "base" --pause >> "$DL_DIR/Vagrant/sandbox_snapshot.log"
  sleep 5s
  (echo >&2 "Successfully completed sandbox snapshot!")
}

post_build_checks() {
  # A series of checks to ensure important services are responsive after the build completes.
  # Cuckoo Server
  CUCKOO_CHECK=$(curl -ks -m 2 http://192.168.30.100:8080 | grep -c 'Cuckoo Sandbox' || echo "")
  # Sandbox Agent
  #AGENT_CHECK=$()

  if [ "$CUCKOO_CHECK" -lt 1 ]; then
    (echo >&2 "Warning: Cuckoo Web Server failed post-build tests and may not be functioning correctly.")
  fi
}

main() {
  # Get location of build.sh
  # https://stackoverflow.com/questions/59895/getting-the-source-directory-of-a-bash-script-from-within
  DL_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  PACKER_ONLY=0
  VAGRANT_ONLY=0
  install_deps
  parse_cli_arguments "$@"
  prereq_checks

  # Build Packer boxes if this isn't a Vagrant-only build
  if [ "$VAGRANT_ONLY" -eq 0 ]; then
    RET=$(packer_build_box "sandbox")
    # The only time we will need to move boxes is if we're doing a full build
    if [ "$PACKER_ONLY" -eq 0 ]; then
      move_boxes
    fi
  fi

  # Build and Test Vagrant hosts if this isn't a Packer-only build
  if [ "$PACKER_ONLY" -eq 0 ]; then
    build_vagrant_hosts
    create_snapshot
    post_build_checks
  fi

  (echo >&2 "Everything has completed! Cuckoo should now be available at http://192.168.30.100:8080")
}

main "$@"
exit 0
