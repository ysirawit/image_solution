#cloud-config

apt_update: true
apt_upgrade: true

install_magento:
 - &install_magento |
   curl -s https://raw.githubusercontent.com/ysirawit/image_solution/master/script_install_magento.sh |bash

setup_crontab:
 - &setup_crontab |
   curl -s https://raw.githubusercontent.com/ysirawit/image_solution/master/run_cron_magento.sh |bash

runcmd:
 - [ sh, -c, *install_magento ]
 - [ sh, -c, *setup_crontab ]
 - touch /tmp/done

 