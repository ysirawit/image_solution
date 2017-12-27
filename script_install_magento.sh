#!/bin/bash

#install php
apt-get install php7.0-common php7.0-gd php7.0-mcrypt php7.0-curl php7.0-intl \
php7.0-xsl php7.0-mbstring php7.0-zip php7.0-iconv mysql-client php7.0-soap -y

#config apache
a2enmod rewrite
sed -i 's/DocumentRoot \/var\/www/DocumentRoot \/var\/www\/magento\//g' /etc/apache2/sites-available/000-default.conf
sed -i "166s/AllowOverride None/AllowOverride All/g" /etc/apache2/apache2.conf
systemctl restart apache2.service

#prepare install magento
mkdir /var/www/magento
cd /var/www/magento/
wget https://github.com/ysirawit/magento/raw/master/Magento-CE.tar.gz
tar -xvzf Magento-CE.tar.gz
cd /var/www/
chown www-data:www-data -R /var/www/magento/

#gen DB password
MATRIX="0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz"
LENGTH="8"
    while [ "${n:=1}" -le "$LENGTH" ]
    do
        DB_PASSWORD="$DB_PASSWORD${MATRIX:$(($RANDOM%${#MATRIX})):1}"
        let n+=1
    done

#create database
mysql -u root  << EOF
CREATE DATABASE magento;
CREATE USER 'magento' IDENTIFIED BY '$DB_PASSWORD' ;
GRANT ALL PRIVILEGES ON magento.* TO 'magento';
quit
EOF

#write file DB config
echo 'Database Server Host : localhost ' >> ~/install_config
echo 'Database Server Username : magento ' >> ~/install_config
echo 'Database Server Password : '$DB_PASSWORD' ' >> ~/install_config
echo 'Database Name : magento ' >> ~/install_config
echo 'Table prefix : (none) ' >> ~/install_config

#write out current crontab
crontab -l > mycron
#echo new cron into cron file
echo "* * * * * /usr/bin/php /var/www/magento/bin/magento cron:run | grep -v "Ran jobs by schedule" >> /var/www/magento/var/log/magento.cron.log" >> mycron
echo "* * * * * /usr/bin/php /var/www/magento/update/cron.php >> /var/www/magento/var/log/update.cron.log" >> mycron
echo "* * * * * /usr/bin/php /var/www/magento/bin/magento setup:cron:run >> /var/www/magento/var/log/setup.cron.log" >> mycron
#install new cron file
crontab mycron
rm mycron

#finish
echo 'DONE!!!!!!!!!!! :)'