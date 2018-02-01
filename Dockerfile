FROM debian:unstable
ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update
RUN apt-get -y install ansible
RUN apt-get -y install rsync
RUN apt-get -y install git python-pip sudo at tmux

RUN pip install -U pip
RUN pip install ansible

RUN echo 'localhost ansible_connection=local' > /etc/ansible/hosts



# RUN apt-get -y install sudo apache2 mysql-server libapache2-mod-php7.0 git php7.0-mysql 

## if you change this one, it will use the cache
#RUN apt-get -y install curl gnupg

# RUN apt-get -y install npm
#RUN npm install -g npm


# RUN apt-get -y install composer
# RUN curl -sS https://getcomposer.org/installer | php

#RUN mv composer.phar /usr/local/bin/composer

#somewhere in ur system: git clone https://framagit.org/c1000101/devops.git

# RUN cd /var/www/

#RUN composer install_local

# RUN a2enmod rewrite



#RUN cd /hitchwiki
#RUN scripts/setup_hitchwiki.sh 