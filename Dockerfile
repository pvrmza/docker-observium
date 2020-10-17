# base
FROM ubuntu:20.04
LABEL maintainer="Pablo A. Vargas <pablo@pampa.cloud>"

# Environment
ENV DEBIAN_FRONTEND noninteractive

# update & upgrade & install base
RUN apt-get update && apt-get -y dist-upgrade && \
    apt-get -y install libapache2-mod-php7.4 php7.4-cli php7.4-mysql php7.4-mysqli php7.4-gd php7.4-json \
    php-pear snmp fping mysql-client python3-mysqldb rrdtool subversion whois mtr-tiny \
    ipmitool graphviz imagemagick apache2 python3-pymysql python-is-python3 \
    libvirt-clients wget supervisor cron && \
    apt-get clean autoclean && apt-get autoremove -y && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /var/lib/cache/* /var/lib/log/* /var/lib/apt/lists/*

COPY files/apache-observium.conf /etc/apache2/sites-enabled/000-default.conf
COPY files/cron-observium /etc/cron.d/observium
COPY files/supervisord.conf /etc/supervisord.conf
COPY files/foreground.sh /etc/foreground.sh

# base config
RUN a2dismod mpm_event && \
    a2enmod mpm_prefork && \
    a2enmod php7.4 && \
    a2enmod rewrite && \
    echo -e "TLS_REQCERT\tnever" >> /etc/ldap/ldap.conf && \
    chmod 0644 /etc/cron.d/observium && \
    chmod +x /etc/foreground.sh

#
RUN cd /opt && wget -c http://www.observium.org/observium-community-latest.tar.gz &&\
    tar zxvf observium-community-latest.tar.gz && \
    rm -rf observium-community-latest.tar.gz

#Puertos y Volumenes
VOLUME ["/config" ]
EXPOSE 80 

CMD ["/etc/foreground.sh"]

