#cloud-config

apt_update: true
apt_upgrade: true

packages:
 - libzip4 
 - mysql-client 
 - php7.0-intl 
 - php7.0-soap 
 - php7.0-xsl 
 - php7.0-zip
 - mysql-server
 - nginx
 - php7.0-mysql
 - php7.0-common
 - curl
 - postfix

configapache:
 - &config_apache |
   a2enmod rewrite
   sed -i 's/DocumentRoot \/var\/www/DocumentRoot \/var\/www\/magento\//g' /etc/apache2/sites-available/000-default.conf
   sed -i "166s/AllowOverride None/AllowOverride All/g" /etc/apache2/apache2.conf

configmysql:
 - &config_mysql |
   /etc/init.d/mysql restart

setupdatabase:
 - &setup_db | 
   cd ~
   bash ./setup_database

configmagento:
 - &config_magento |
   mkdir /var/www/magento
   mv /tmp/Magento-CE.tar.gz /var/www/magento/
   cd /var/www/magento/
   tar -xvzf Magento-CE.tar.gz
   chown www-data:www-data -R /var/www/magento/
   
restartapache:
 - &restart_apache |
   systemctl restart apache2.service

runcmd:
 - [ sh, -c, *gen_db_pw ]
 - [ sh, -c, *create_db ]
 - [ sh, -c, *config_mysql ]
 - [ sh, -c, *config_apache ]
 - [ sh, -c, *restart_apache ]
 - [ sh, -c, *config_magento ]
 - [ sh, -c, *show_config_db ]
 - touch /tmp/done