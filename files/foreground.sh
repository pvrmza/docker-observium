#!/bin/bash

# turn on bash's job control
set -m

#######
mkdir -p /config/logs && mkdir -p /config/rrd 
rm -rf /opt/observium/logs /opt/observium/rrd 
ln -s /config/logs /opt/observium/logs 
ln -s /config/rrd /opt/observium/rrd 
chown www-data:www-data /config/logs 
chown www-data:www-data /config/rrd 

#######
rm -rf /opt/observium/config.php 
echo "<?php" > /config/config.php
# ENVIROMET to CONFIG
for line in `printenv | egrep ^OBSERVIUM | sort -u `
do
	var=`echo $line | cut -d = -f 1 |sed 's/OBSERVIUM_/\$config[/g' | sed 's/__/][/g' | sed 's/$/]/g' ` 
	value=`echo $line | cut -d = -f 2- ` 
	echo "$var=\"$value\";" >> /config/config.php
done 
echo "?>" >> /config/config.php
ln -s /config/config.php /opt/observium/config.php 

#######
while ! mysqladmin ping -h"$OBSERVIUM_db_host" --silent; do
	echo "$OBSERVIUM_db_host not is alive... "
    sleep 5
done

# Initial Setup
cd /opt/observium 
# Setup the MySQL database and insert the default schema
./discovery.php -u
# add user
./adduser.php $OBSERVIUM_ADMIN_USER $OBSERVIUM_ADMIN_PASS 10
#####
# import devices
if [ -e /config/hosts  ]; then 
	cat /config/hosts >> /etc/hosts
	while read -r line; do
		device=`echo $line | awk '{ print $2 }'`
		./add_device.php $device
	done < /config/hosts
fi	

if [ -e /config/devices  ]; then
 	./add_device.php /config/devices
fi	

# Perform Initial Discovery ... in backgound
./discovery.php -h all & 

####################################3
# cron
# export env 
# printenv | egrep ^OBSERVIUM | sort -u | sed 's/^\(.*\)$/export \1/g' > /etc/cron.env
# chmod 500 /etc/cron.env
#
supervisord -c /etc/supervisord.conf