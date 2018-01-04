#cloud-config

apt_update: true
apt_upgrade: true

packages:

$Password = 'qweasd'

install_magento:
 - &install_magento |
   curl -s https://raw.githubusercontent.com/ysirawit/image_solution/master/script_install_magento\(noCron\).sh |bash $Password

runcmd:
 - [ sh, -c, *install_magento ]
 - touch /tmp/done