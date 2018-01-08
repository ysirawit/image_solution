#!/bin/bash

#run Cron
#echo new cron into cron files
echo "* * * * * /usr/bin/php /var/www/magento/bin/magento cron:run | grep -v "Ran jobs by schedule" >> /var/www/magento/var/log/magento.cron.log" >> mycron
echo "* * * * * /usr/bin/php /var/www/magento/update/cron.php >> /var/www/magento/var/log/update.cron.log" >> mycron
echo "* * * * * /usr/bin/php /var/www/magento/bin/magento setup:cron:run >> /var/www/magento/var/log/setup.cron.log" >> mycron
crontab -u magento mycron
rm mycron

#disable x-frame
sed -i 's/SAMEORIGIN/DENY/g' /var/www/magento/app/etc/env.php

cd /var/www/magento/
find app/etc -type f -exec chmod g-w {} \;
find app/etc -type d -exec chmod g-ws {} \;