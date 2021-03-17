# base
FROM ubuntu:20.04
LABEL maintainer="Pablo A. Vargas <pablo@pampa.cloud>"

# Environment
ENV DEBIAN_FRONTEND noninteractive

# update & upgrade & install base
RUN apt-get update && apt-get -y dist-upgrade && \
    apt-get -y install libapache2-mod-php7.4 php7.4-cli php7.4-mysql php7.4-mysqli php7.4-gd php7.4-json php7.4-curl\
    php-pear php7.4-ldap snmp fping mysql-client python3-mysqldb rrdtool subversion whois mtr-tiny \
    ipmitool graphviz imagemagick apache2 python3-pymysql python-is-python3 \
    libvirt-clients wget supervisor cron unzip && \
    apt-get clean autoclean && apt-get autoremove -y && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /var/lib/cache/* /var/lib/log/* /var/lib/apt/lists/*

COPY files/apache-observium.conf /etc/apache2/sites-enabled/000-default.conf
COPY files/cron-observium /etc/cron.d/observium
COPY files/cron-o2ipam /etc/cron.d/o2ipam.sh
COPY files/supervisord.conf /etc/supervisord.conf
COPY files/foreground.sh /etc/foreground.sh

# base config
RUN a2dismod mpm_event && \
    a2enmod mpm_prefork && \
    a2enmod php7.4 && \
    a2enmod rewrite && \
    echo "TLS_REQCERT\tnever" >> /etc/ldap/ldap.conf && \
    chmod 0644 /etc/cron.d/observium && \
    chmod +x /etc/foreground.sh

#
RUN cd /opt && wget -c http://www.observium.org/observium-community-latest.tar.gz &&\
    tar zxvf observium-community-latest.tar.gz && \
    rm -rf observium-community-latest.tar.gz

RUN cd /opt/observium && wget -c https://github.com/pvrmza/o2ipam/archive/main.zip &&\
    unzip main.zip && rm -rf main.zip && mv o2ipam-main/ o2ipam

#Puertos y Volumenes
VOLUME ["/config" ]
EXPOSE 80 

ENTRYPOINT ["/etc/foreground.sh"]

