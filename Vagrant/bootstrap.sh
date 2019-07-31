#! /bin/bash

export DEBIAN_FRONTEND=noninteractive
echo "apt-fast apt-fast/maxdownloads string 10" | debconf-set-selections;
echo "apt-fast apt-fast/dlflag boolean true" | debconf-set-selections;
sed -i "2ideb mirror://mirrors.ubuntu.com/mirrors.txt xenial main restricted universe multiverse\ndeb mirror://mirrors.ubuntu.com/mirrors.txt xenial-updates main restricted universe multiverse\ndeb mirror://mirrors.ubuntu.com/mirrors.txt xenial-backports main restricted universe multiverse\ndeb mirror://mirrors.ubuntu.com/mirrors.txt xenial-security main restricted universe multiverse" /etc/apt/sources.list

fix_eth1_static_ip() {
  echo -e 'interface "eth1" {
    send host-name = gethostname();
    send dhcp-requested-address 192.168.30.100;
  }' >> /etc/dhcp/dhclient.conf
service networking restart
}

apt_install_prerequisites() {
  # Add repository for apt-fast
  add-apt-repository -y ppa:apt-fast/stable
  # Install prerequisites and useful tools
  echo "[$(date +%H:%M:%S)]: Running apt-get update..."
  apt-get -qq update
  apt-get -qq install -y apt-fast
  echo "[$(date +%H:%M:%S)]: Running apt-fast install..."
  apt-fast -qq install -y crudini python python-pip python-dev libffi-dev libssl-dev python-virtualenv python-setuptools libjpeg-dev zlib1g-dev swig mongodb postgresql libpq-dev tcpdump apparmor-utils libcap2-bin libguac-client-rdp0 libguac-client-vnc0 libguac-client-ssh0 guacd samba-common-bin
  echo "[$(date +%H:%M:%S)]: Installing and configuring inetsim..."
  echo "deb http://www.inetsim.org/debian/ binary/" > /etc/apt/sources.list.d/inetsim.list
  wget -O - http://www.inetsim.org/inetsim-archive-signing-key.asc | apt-key add -
  apt-get -qq update
  apt-get -qq install -y inetsim
  echo "service_bind_address    192.168.30.100" >> /etc/inetsim/inetsim.conf
  echo "dns_default_ip          192.168.30.100" >> /etc/inetsim/inetsim.conf
  sed -i 's/ENABLED=0/ENABLED=1/' /etc/default/inetsim
  service inetsim restart
  echo "[$(date +%H:%M:%S)]: Installing Supervisor..."
  pip install -U supervisor
}

configure_prerequisites() {
  # Disable app armor
  aa-disable /usr/sbin/tcpdump
  # Adjust permissions
  groupadd pcap
  chgrp pcap /usr/sbin/tcpdump
  setcap cap_net_raw,cap_net_admin=eip /usr/sbin/tcpdump
}

install_cuckoo() {
  pip install -U cuckoo
}

configure_cuckoo() {
  CUCKOO_CONF=/root/.cuckoo/conf/cuckoo.conf
  CUCKOO_REPORTING=/root/.cuckoo/conf/reporting.conf
  CUCKOO_PHYSICAL=/root/.cuckoo/conf/physical.conf

  # Init cuckoo
  # TODO: check if cuckoo init files already exist and skip if they are
  # if test -f "$FILE"; then
  echo "[$(date +%H:%M:%S)]: Initializing Cuckoo Config..."
  cuckoo init 2>&1

  # Configure all the things
  crudini --set $CUCKOO_CONF cuckoo version_check no
  crudini --set $CUCKOO_CONF cuckoo ignore_vulnerabilities yes
  crudini --set $CUCKOO_CONF cuckoo process_results no
  crudini --set $CUCKOO_CONF timeouts vm_state 300
  crudini --set $CUCKOO_CONF cuckoo machinery physical
  crudini --set $CUCKOO_CONF resultserver ip 192.168.30.100
  crudini --set $CUCKOO_REPORTING mongodb enabled yes
  crudini --set $CUCKOO_PHYSICAL physical machines physical1
  crudini --set $CUCKOO_PHYSICAL physical user vagrant
  crudini --set $CUCKOO_PHYSICAL physical password vagrant
  crudini --set $CUCKOO_PHYSICAL physical interface eth1
  crudini --set $CUCKOO_PHYSICAL physical1 label sandbox
  crudini --set $CUCKOO_PHYSICAL physical1 ip 192.168.30.101

  echo "[$(date +%H:%M:%S)]: Installing community packages"
  cuckoo community 2>&1

  echo "[$(date +%H:%M:%S)]: Installing supervisord configuration"
  SUPERVISORD_CONF=/root/.cuckoo/supervisord.conf
  cp /vagrant/resources/supervisord.conf $SUPERVISORD_CONF

  echo "[$(date +%H:%M:%S)]: Enable supervisord in systemctl"
  cp /vagrant/resources/supervisord.service /lib/systemd/system/
  systemctl enable supervisord

  echo "[$(date +%H:%M:%S)]: Starting Supervisord"
  systemctl start supervisord

  echo "[$(date +%H:%M:%S)]: Starting Cuckoo services"
  supervisorctl start cuckoo:
}

main() {
  apt_install_prerequisites
  fix_eth1_static_ip
  configure_prerequisites
  install_cuckoo
  configure_cuckoo

  echo "[$(date +%H:%M:%S)]: Everything has been setup correctly!"
}

main
exit 0
