#cloud-config

apt_update: true
apt_upgrade: true

install_magento:
 - &install_magento |
   curl -s https://raw.githubusercontent.com/ysirawit/image_solution/master/script_install_magento.sh |bash

setup_crontab:
 - &setup_crontab |
   curl -s https://raw.githubusercontent.com/ysirawit/image_solution/master/run_cron_magento.sh |bash

access_web:
 - &access_web |
   public_ipv4=$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4)
   curl $public_ipv4

runcmd:
 - [ sh, -c, *install_magento ]
 - [ sh, -c, *access_web ]
 - [ sh, -c, *setup_crontab ]
 - touch /tmp/done