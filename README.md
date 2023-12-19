
# docker-observium unattended deploy
not another observium in docker... Observium CE 23.9 (20/09/2023)

Observium is network monitoring with intuition. It is a low-maintenance auto-discovering network monitoring platform supporting a wide range of device types, platforms and operating systems including Cisco, Windows, Linux, HP, Juniper, Dell, FreeBSD, Brocade, Netscaler, NetApp and many more. Observium focuses on providing a beautiful and powerful yet simple and intuitive interface to the health and status of your network. For more information, go to http://www.observium.org site.

## Features
* All configurations can be added from environment variables
* Import hosts from /config/hosts to /etc/hosts, then automatically add them to observium
* Automatically import devices from /config/devices
* Added [o2ipam project](https://github.com/pvrmza/o2ipam) to export Observium data to phpIPAM

### Config values
All environment variables starting OBSERVIUM_ will be transformed to $config and added automatically to the config.php file. Double _ separates array. Example:

| Environment | Observium Config | 
| :--- |:--- |
| OBSERVIUM_db_user=observium | $config['db_user']="observium"; | 
| OBSERVIUM_snmp__community__0=public | $config['snmp']['community']['0']="public"; | 
| OBSERVIUM_snmp__community__1=ortherpublic | $config['snmp']['community']['1']="ortherpublic"; | 
| OBSERVIUM_housekeeping__rrd__invalid=TRUE | $config['housekeeping']['rrd']['invalid']=TRUE; |
| OBSERVIUM_enable_syslog=1 |  $config['enable_syslog']=1; |


List of variables and default values: https://github.com/pvrmza/docker-observium/blob/master/files/defaults.inc.php

### Export Change Config in Observium
You can export the configuration values of an instance that is running and save it in the correct format as a file with environment variables.
Download https://github.com/pvrmza/docker-observium/blob/master/files/export_config.php to your observium instance and run it from the command line

```
  $ cd /opt/observium
  $ wget https://raw.githubusercontent.com/pvrmza/docker-observium/master/files/export_config.php -O export_config.php
  $ chmod u+x export_config.php
  $ ./export_config.php > env_observium
```

### Hosts file: /config/hosts
Add host from /config/hosts to /etc/hosts and then add device to Observium

### Devices file: /config/devices
Adding multiple devices at once using a text file containing one line per device (https://docs.observium.org/add_device/)

SNMP v1 or v2c
```
    <hostname> [community] [v1|v2c] [port] [udp|udp6|tcp|tcp6]
```
SNMP v3 
```
  <hostname> [any|nanp|anp|ap] [v3] [user] [password] [enckey] [md5|sha] [aes|des] [port] [udp|udp6|tcp|tcp6]
```

### Integrate to phpIPAM
Configure the following environment variables and this functionality will be activated. More info in [o2ipam homepage](https://github.com/pvrmza/o2ipam) 
 - phpipam_url=https://phpipam.micasa.local
 - observium_url=https://observium.micasa.local
 - phpipam_api=o2ipam
 - phpipam_key=my-api-key
 - phpipam_default_section=1


## Usage
Either follow the choice A. or B. below to run Observium.

### A. Manual Run Containers
- Prepare working directory for docker containers, for example below.
```
  $ sudo mkdir -p /home/docker/observium
  $ cd /home/docker/observium
  $ sudo mkidr data config
```
- Run official MariaDB container
```
  $ docker run --name observium_db -d \
    -v /home/docker/observium/data:/var/lib/mysql \
    -e MYSQL_ROOT_PASSWORD=9459123fdf62cc04 \
    -e MYSQL_USER=observium \
    -e MYSQL_PASSWORD=observiumpwd \
    -e MYSQL_DATABASE=observium \
    -e TZ=America/Argentina/Mendoza \
    mariadb:10.5.2
```

- Run this Observium container
```
  $ docker run --name observium_app --link observium_db:db -d \
    -v /home/docker/observium/config:/config \
    -e OBSERVIUM_ADMIN_USER=admin \
    -e OBSERVIUM_ADMIN_PASS=admin \
    -e OBSERVIUM_db_host=db \
    -e OBSERVIUM_db_user=observium \
    -e OBSERVIUM_db_pass=observiumpwd \
    -e OBSERVIUM_db_name=observium \
    -p 8080:80 \
    pvrmza/docker-observium
```

### B. Use Docker Composer
- Run both database and observium containers.
```
  $ git clone https://github.com/pvrmza/docker-observium.git 
  $ cd docker-observium
  $ cp env_mysql_example .env_mysql
  $ cp env_observium_example .env_observium
  $ docker-compose up -d
```

## Environment 

| Environment | Observium Config | Default value | Contenido | 
| :--- |:--- | :--- | :---| 
| **OBSERVIUM_db_host** | $config['db_host'] | db | 'localhost' or 'db.isp.com' or IP |
| **OBSERVIUM_db_name** | $config['db_name'] | observium | database name, eg observium |  
| **OBSERVIUM_db_user** | $config['db_user'] | observium | your database username |  
| **OBSERVIUM_db_pass** | $config['db_pass'] | observiumpwd | your database password |
| **OBSERVIUM_ADMIN_USER** |  | admin |  |  
| **OBSERVIUM_ADMIN_PASS** |  | admin |  |  

# Volumen
  /config

# Ports
  80 443
