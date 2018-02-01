FROM debian:unstable
ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update
RUN apt-get -y install ansible
RUN apt-get -y install rsync
RUN apt-get -y install git python-pip sudo at tmux

RUN pip install -U pip
RUN pip install ansible

RUN echo 'localhost ansible_connection=local' > /etc/ansible/hosts
COPY . /var/www/
RUN cd /var/www/scripts && ./setup_hitchwiki.sh