FROM ubuntu:14.04
MAINTAINER Samuel Taylor "samtaylor.uk@gmail.com"

# Couchpotato Version
ENV COUCHPOTATO_VERSION 2.6.3

# To get rid of error messages like "debconf: unable to initialize frontend: Dialog":
RUN echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections

RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-keys FDA5DFFC \
  && apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 4BB9F05F \
  && echo "deb http://archive.ubuntu.com/ubuntu trusty multiverse" | tee -a /etc/apt/sources.list \
  && apt-get update -q \
  && apt-get install -qy python wget unrar crudini \
  ; apt-get clean \
  ; rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Install CouchPotato
RUN mkdir /opt/couchpotato \
  && wget -P /tmp/ https://github.com/RuudBurger/CouchPotatoServer/archive/build/$COUCHPOTATO_VERSION.tar.gz \
  && tar -C /opt/couchpotato -xvf /tmp/$COUCHPOTATO_VERSION.tar.gz --strip-components 1 \
  && chown nobody:users /opt/couchpotato

EXPOSE 5050

VOLUME ["/config", "/data/films", "/data/downloads"]

ADD start.sh /
RUN chmod +x /start.sh

CMD ["/start.sh"]
