FROM karethio/dst-docker-base:latest

ADD scripts/ /scripts
#GAME ID and Game root configs
ENV APP_ID 343050
ENV INSTALL_DIR /root/dst
ENV MOD_ROOT /root/dst/mods

#Server save stuff
ENV PERSISTENT_STORAGE_ROOT /root/dst/saves
ENV CONF_DIR dstserver
ENV SHARD Master
ENV CLUSTER_DIR ${PERSISTENT_STORAGE_ROOT}/${CONF_DIR}/Cluster_1

RUN apt-get update -yqq
RUN apt-get -yqq install libcurl4-gnutls-dev:i386 gettext-base python3-pip
RUN pip3 install requests

ENV PATH="${PATH}:/scripts"
WORKDIR /root/dst/bin

