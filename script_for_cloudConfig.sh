#!/bin/bash

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

