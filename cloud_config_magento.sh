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

gendbpassword: 
 - &gen_db_pw |
   MATRIX="0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz"
   LENGTH="8"
      while [ "${n:=1}" -le "$LENGTH" ]
      do
        DB_PASSWORD="$DB_PASSWORD${MATRIX:$(($RANDOM%${#MATRIX})):1}"
        let n+=1
      done

showconfigdb:
 - &show_config_db |
 echo 'Database Server Host : localhost ' >> ~/install_config
 echo 'Database Server Username : magento ' >> ~/install_config
 echo 'Database Server Password : '$DB_PASSWORD' ' >> ~/install_config
 echo 'Database Name : magento ' >> ~/install_config
 echo 'Table prefix : (none) ' >> ~/install_config

createdb: 
 - &create_db | 
   mysql -u root  << EOF
    CREATE DATABASE magento;
    CREATE USER 'magento' IDENTIFIED BY '$DB_PASSWORD' ;
    GRANT ALL PRIVILEGES ON magento.* TO 'magento';
    quit
EOF

configmysql:
 - &config_mysql |
   /etc/init.d/mysql restart

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