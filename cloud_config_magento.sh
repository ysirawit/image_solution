#cloud-config

apt_update: true
apt_upgrade: true

install_magento:
 - &install_magento |
   curl -s  |bash

setup_crontab
 - &setup_crontab |
   curl -s  |bash

runcmd:
 - [ sh, -c, *install_magento ]
 - [ sh, -c, *setup_crontab ]
 - touch /tmp/done