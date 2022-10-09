# Docker-Moodle-IOMAD-develop-env
# 
# Forked from . https://github.com/smezei/docker-moodle-iomad
FROM ubuntu:22.04
LABEL maintainer="Oscar Ruesga <oscar.ruesga@gmail.com>"



# Let the container know that there is no tty
ENV DEBIAN_FRONTEND noninteractive

# Database info and other connection information derrived from env variables. See readme.
# Set ENV Variables externally Moodle_URL should be overridden.
ENV MOODLE_URL http://127.0.0.1

ENV IOMAD_VERSION 39

# Enable when using external SSL reverse proxy
# Default: false
ENV SSL_PROXY false

#Force use of bin/bash in Docker shell
RUN rm /bin/sh && ln -s /bin/bash /bin/sh

RUN apt-get update && apt-get upgrade && \ 
	apt-get install -y software-properties-common apt-transport-https apache2 mysql-client pwgen python-setuptools nano \
		git unzip libcurl3-dev postfix wget supervisor libcurl4 git-core
RUN add-apt-repository ppa:ondrej/php -y && apt-get update && apt-get upgrade -y && \
	apt-get -y install  php7.4 php7.4-gd php7.4-pgsql php7.4-curl php7.4-xmlrpc php7.4-intl \
		php7.4-mysql php7.4-xml php7.4-mbstring php7.4-zip php7.4-soap cron php7.4-ldap php7.4-xdebug libapache2-mod-php curl

# Cleanup, this is ran to reduce the resulting size of the image.
RUN apt-get clean autoclean && apt-get autoremove -y && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /var/lib/dpkg/* /var/lib/cache/* /var/lib/log/*

RUN mkdir -p /tmp/iomad && \
	cd /tmp/iomad && \
	git clone https://github.com/iomad/iomad.git --branch IOMAD_${IOMAD_VERSION}_STABLE --depth=1 . && \
	mv /tmp/iomad/* /var/www/html/ && \
	rm /var/www/html/index.html && \
	chown -R www-data:www-data /var/www/html
	
#cron
ADD moodlecron /etc/cron.d/moodlecron
RUN chmod 0644 /etc/cron.d/moodlecron

# Enable SSL, moodle requires it
RUN a2enmod ssl && a2ensite default-ssl  #if using proxy dont need actually secure connection
# Downgrade php 8.1 to php 7.4
RUN a2dismod php8.1 && a2enmod php7.4

#Prevent waring no ServerName FQDN not qualified
RUN echo 'ServerName 127.0.0.1' >> /etc/apache2/apache2.conf

#ENABLE XDEBUG DEV
ENV XdebugFile /etc/php/7.4/mods-available/xdebug.ini
RUN echo "[xdebug]" >> ${XdebugFile} &&\
	echo "xdebug.mode=debug" >> ${XdebugFile} &&\
	echo "xdebug.discover_client_host=1" >> ${XdebugFile} &&\
	echo "xdebug.start_with_request=yes" >> ${XdebugFile}

ADD ./foreground.sh /etc/apache2/foreground.sh
RUN chmod +x /etc/apache2/foreground.sh

VOLUME ["/var/moodledata"]
EXPOSE 80 443
ADD moodle-config.php /var/www/html/config.php

ENTRYPOINT ["/etc/apache2/foreground.sh"]
