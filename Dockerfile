FROM debian:unstable
ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update
RUN apt-get -y install sudo apache2 mysql-server libapache2-mod-php7.0 git php7.0-mysql 

## if you change this one, it will use the cache
#RUN apt-get -y install curl gnupg

RUN apt-get -y install npm

#RUN curl -sL https://deb.nodesource.com/setup_9.x | sudo bash - \
#    && apt-get install -y nodejs
    
#RUN update-alternatives --install /usr/bin/node nodejs /usr/bin/nodejs 100
RUN curl https://www.npmjs.com/install.sh | sh
#RUN npm -v && node -v
RUN npm install -g npm

# RUN curl -sS https://getcomposer.org/installer | php

#RUN mv composer.phar /usr/local/bin/composer

#somewhere in ur system: git clone https://framagit.org/c1000101/devops.git

#RUN cd /var/www/

#RUN composer install_local

# RUN a2enmod rewrite