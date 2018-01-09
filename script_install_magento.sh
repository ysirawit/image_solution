#!/bin/bash

#install php
apt-get install php7.0-common php7.0-gd php7.0-mcrypt php7.0-curl php7.0-intl \
php7.0-xsl php7.0-mbstring php7.0-zip php7.0-iconv mysql-client php7.0-soap -y

#config apache
a2enmod rewrite
sed -i 's/DocumentRoot \/var\/www/DocumentRoot \/var\/www\/magento\//g' /etc/apache2/sites-available/000-default.conf
sed -i "166s/AllowOverride None/AllowOverride All/g" /etc/apache2/apache2.conf
systemctl restart apache2.service

#edit php config 
sed -i 's/max_execution_time = 30/max_execution_time = 3600/g' /etc/php/7.0/fpm/php.ini 
sed -i 's/max_execution_time = 30/max_execution_time = 3600/g' /etc/php/7.0/cli/php.ini 

sed -i 's/memory_limit = 128M/memory_limit = 2G/g' /etc/php/7.0/fpm/php.ini
sed -i 's/memory_limit = 128M/memory_limit = 2G/g' /etc/php/7.0/cli/php.ini

sed -i 's/;opcache.save_comments=1/opcache.save_comments=1/g' /etc/php/7.0/fpm/php.ini
sed -i 's/;opcache.save_comments=1/opcache.save_comments=1/g' /etc/php/7.0/cli/php.ini

sed -i 's/zlib.output_compression = Off/zlib.output_compression = On/g' /etc/php/7.0/fpm/php.ini
sed -i 's/zlib.output_compression = Off/zlib.output_compression = On/g' /etc/php/7.0/cli/php.ini

systemctl restart php7.0-fpm

#prepare install magento
mkdir /var/www/magento
cd /var/www/magento/
wget https://github.com/ysirawit/magento/raw/master/Magento-CE.tar.gz && tar -xvzf Magento-CE.tar.gz && rm Magento-CE.tar.gz

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

#create user
useradd magento
usermod -g www-data magento
find var vendor pub/static pub/media app/etc -type f -exec chmod g+w {} \;
find var vendor pub/static pub/media app/etc -type d -exec chmod g+ws {} \;
chown -R magento:www-data .
chmod u+x bin/magento
chmod g+w -R generated/
systemctl restart apache2
echo "restart apache"

#write file DB config
echo 'Database Server Host : localhost ' >> ~/install_configS
echo 'Database Server Username : magento ' >> ~/install_config
echo 'Database Server Password : '$DB_PASSWORD'' >> ~/install_config
echo 'Database Name : magento ' >> ~/install_config
echo 'Table prefix : (none) ' >> ~/install_config
echo "end"

#Install Magento CE
cd /var/www/magento/bin
sudo -u magento bash << EOF
    whoami && ./magento setup:install --backend-frontname="admin" --admin-firstname="kor" --admin-lastname="za" \
    --admin-email="a@n.com" --admin-user="admin" --admin-password="password1" --timezone="Asia/Bangkok" \
    --db-name="magento" --db-host="localhost" --db-user="magento" --db-password="$DB_PASSWORD"
EOF

echo 'Next install Cron)'

