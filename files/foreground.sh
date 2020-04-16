#!/bin/bash

# turn on bash's job control
set -m

# 
[ -z $OBSERVIUM_DB_HOST ] && OBSERVIUM_DB_HOST=db
[ -z $OBSERVIUM_DB_USER ] && OBSERVIUM_DB_USER=observium
[ -z $OBSERVIUM_DB_PASS ] && OBSERVIUM_DB_PASS=observiumpwd
[ -z $OBSERVIUM_DB_DB ] && OBSERVIUM_DB_DB=observium
[ -z $OBSERVIUM_ADMIN_USER ] && OBSERVIUM_ADMIN_USER=admin
[ -z $OBSERVIUM_ADMIN_PASS ] && OBSERVIUM_ADMIN_PASS=admin

#
mkdir -p /config/logs && mkdir -p /config/rrd 
rm -rf /opt/observium/logs /opt/observium/rrd 
ln -s /config/logs /opt/observium/logs 
ln -s /config/rrd /opt/observium/rrd 
chown www-data:www-data /config/logs 
chown www-data:www-data /config/rrd 

#
if [ ! -e /config/config.php  ]; then 
	cp /opt/observium/config.php.* /config/config.php 
	sed -i "s/'localhost'/getenv\('OBSERVIUM_DB_HOST'\)/g" /config/config.php 
	sed -i "s/'USERNAME'/getenv\('OBSERVIUM_DB_USER'\)/g" /config/config.php 
	sed -i "s/'PASSWORD'/getenv\('OBSERVIUM_DB_PASS'\)/g" /config/config.php 
	sed -i "s/'observium'/getenv\('OBSERVIUM_DB_DB'\)/g" /config/config.php 
fi
rm -rf /opt/observium/config.php
ln -s /config/config.php /opt/observium/config.php 

#
while ! mysqladmin ping -h"$OBSERVIUM_DB_HOST" --silent; do
	echo "$OBSERVIUM_DB_HOST not is alive... "
    sleep 2
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
printenv | egrep OBSERVIUM | sed 's/^\(.*\)$/export \1/g' > /etc/cron.env
chmod 500 /etc/cron.env
#
supervisord -c /etc/supervisord.conf