#cloud-config

apt_update: true
apt_upgrade: true

packages: 
 - mysql-client 
 - mysql-server

configmysql:
 - &restart_mysql |
   /etc/init.d/mysql restart

runcmd:
 - touch /tmp/start
 - [ sh, -c, *restart_mysql ]
 - touch /tmp/done

 