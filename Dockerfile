# base
FROM ubuntu:22.04
LABEL maintainer="Pablo A. Vargas <pablo@pampa.cloud>"

# Environment
ENV DEBIAN_FRONTEND noninteractive

# update & upgrade & install base
RUN apt-get update && apt-get -y dist-upgrade && \
    apt-get -y install libapache2-mod-php php-cli php-mysql php-mysqli php-gd php-json php-curl\
    php-pear php-apcu php-ldap snmp fping mysql-client python3-mysqldb rrdtool subversion whois mtr-tiny \
    ipmitool graphviz imagemagick apache2 python3-pymysql python-is-python3 \
    libvirt-clients wget supervisor cron unzip && \
    apt-get clean autoclean && apt-get autoremove -y && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /var/lib/cache/* /var/lib/log/* /var/lib/apt/lists/*

COPY files/apache-observium.conf /etc/apache2/sites-enabled/000-default.conf
COPY files/cron-observium /etc/cron.d/observium
COPY files/supervisord.conf /etc/supervisord.conf
COPY files/docker-entrypoint.sh /usr/local/bin/

# base config
RUN a2dismod mpm_event && \
    a2enmod mpm_prefork && \
    a2enmod php8.1 && \
    a2enmod rewrite && \
    echo "TLS_REQCERT\tnever" >> /etc/ldap/ldap.conf && \
    chmod 0644 /etc/cron.d/observium && \
    chmod +x /usr/local/bin/docker-entrypoint.sh

#
RUN cd /opt && wget -c http://www.observium.org/observium-community-latest.tar.gz &&\
    tar zxvf observium-community-latest.tar.gz && \
    rm -rf observium-community-latest.tar.gz

#Puertos y Volumenes
VOLUME ["/config" ]
EXPOSE 80 

ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]

