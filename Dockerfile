# base
FROM ubuntu:18.04
LABEL maintainer="Pablo A. Vargas <pablo@pampa.cloud>"

# Environment
ENV DEBIAN_FRONTEND noninteractive
ENV OBSERVIUM_db_extension=mysqli
ENV OBSERVIUM_db_host=db
ENV OBSERVIUM_db_user=observium
ENV OBSERVIUM_db_pass=observiumpwd
ENV OBSERVIUM_db_name=observium
ENV OBSERVIUM_snmp__community__=public
ENV OBSERVIUM_auth_mechanism=mysql

ENV OBSERVIUM_ADMIN_USER=admin
ENV OBSERVIUM_ADMIN_PASS=admin

# update & upgrade & install base
RUN apt-get update && apt-get -y dist-upgrade && \
    apt-get -y install libapache2-mod-php7.2 php7.2-cli php7.2-mysql php7.2-mysqli \
    php7.2-gd php7.2-json php-pear snmp fping mysql-client python-mysqldb \
    rrdtool subversion whois mtr-tiny ipmitool graphviz imagemagick apache2 \
    libvirt-bin wget vim supervisor

# Cleanup, this is ran to reduce the resulting size of the image.
RUN apt-get clean autoclean && \
    apt-get autoremove -y && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /var/lib/cache/* /var/lib/log/* /var/lib/apt/lists/*

# base config
RUN a2dismod mpm_event && \
    a2enmod mpm_prefork && \
    a2enmod php7.2 && \
    a2enmod rewrite
#
COPY files/apache-observium.conf /etc/apache2/sites-available/000-default.conf
COPY files/cron-observium /etc/cron.d/observium
COPY files/supervisord.conf /etc/supervisord.conf
COPY files/foreground.sh /etc/foreground.sh

RUN echo -e "TLS_REQCERT\tnever" >> /etc/ldap/ldap.conf && \
    chmod 0644 /etc/cron.d/observium && \
    chmod +x /etc/foreground.sh

#
RUN cd /opt && wget -c http://www.observium.org/observium-community-latest.tar.gz &&\
    tar zxvf observium-community-latest.tar.gz && \
    rm -rf observium-community-latest.tar.gz


#Puertos y Volumenes
VOLUME ["/config" ]
EXPOSE 80 443 
CMD ["/etc/foreground.sh"]

