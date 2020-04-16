
# docker-observium
another observium in docker or another docker with observium...

Observium is network monitoring with intuition. It is a low-maintenance auto-discovering network monitoring platform supporting a wide range of device types, platforms and operating systems including Cisco, Windows, Linux, HP, Juniper, Dell, FreeBSD, Brocade, Netscaler, NetApp and many more. Observium focuses on providing a beautiful and powerful yet simple and intuitive interface to the health and status of your network. For more information, go to http://www.observium.org site.

## Features

* Import hosts from /config/hosts to /etc/hosts, then automatically add them to observium
* Automatically import devices from /config/devices

### /config/devices 
SNMP v1 or v2c
```
  <hostname> [community] [v1|v2c] [port] [udp|udp6|tcp|tcp6]
  <hostname> [community] [v1|v2c] [port] [udp|udp6|tcp|tcp6]
```
SNMP v3 
```
  <hostname> [any|nanp|anp|ap] [v3] [user] [password] [enckey] [md5|sha] [aes|des] [port] [udp|udp6|tcp|tcp6]
  <hostname> [any|nanp|anp|ap] [v3] [user] [password] [enckey] [md5|sha] [aes|des] [port] [udp|udp6|tcp|tcp6]
```

## Usage
Either follow the choice A. or B. below to run Observium.

### A. Manual Run Containers
- Prepare working directory for docker containers, for example below.
```
  $ mkdir -p /home/docker/observium
  $ cd /home/docker/observium
  $ mkidr data config
```
- Run official MariaDB container
```
  $ docker run --name observium_db \
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
  $ docker run --name observium_app --link observium_db:db \
    -v /home/docker/observium/config:/config \
    -e OBSERVIUM_ADMIN_USER=admin \
    -e OBSERVIUM_ADMIN_PASS=admin \
    -e OBSERVIUM_DB_HOST=db \
    -e OBSERVIUM_DB_USER=observium \
    -e OBSERVIUM_DB_PASS=observiumpwd \
    -e OBSERVIUM_DB_DB=observium \
    -p 8080:80 \
    pvrmza/docker-observium
```

### B. Use Docker Composer
- Download docker-compose.yml file from https://github.com/pvrmza/docker-observium/ github repository. 

- Run both database and observium containers.
```
  $ docker-compose up
```

## Environment 

| Environment | Observium Config | Default value | Contenido | 
| :--- |:--- | :--- | :---| 
| **OBSERVIUM_DB_HOST** | $config['db_host'] | db | 'localhost' or 'db.isp.com' or IP |
| **OBSERVIUM_DB_DB** | $config['db_name'] | observium | database name, eg observium |  
| **OBSERVIUM_DB_USER** | $config['db_user'] | observium | your database username |  
| **OBSERVIUM_DB_PASS** | $config['db_pass'] | observiumpwd | your database password |
| **OBSERVIUM_ADMIN_USER** |  | admin |  |  
| **OBSERVIUM_ADMIN_PASS** |  | admin |  |  

# Volumen
	/config

# Ports
	80 443
