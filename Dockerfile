# FROM centos:7
FROM debian:buster-slim

MAINTAINER @zsp zhangshaopeng@stoneatom.com
ENV ROLE = ""
ENV MASTER_IP = ""

# backup sources.list
# RUN groupadd -r mysql && useradd -r -g mysql mysql
# RUN cp /etc/apt/sources.list /etc/apt/sources.list.bak
# Change apt source to the source of University of Science and Technology of China
# RUN sed -i 's/deb.debian.org/mirrors.ustc.edu.cn/g' /etc/apt/sources.list
# RUN sed -i 's|security.debian.org/debian-security|mirrors.ustc.edu.cn/debian-security|g' /etc/apt/sources.list
RUN apt clean && apt update -y
# 
RUN apt-get install wget libatomic1 libmarisa0 libsnappy1v5 libssl-dev libjemalloc-dev libncurses6 -y
COPY stonedb57_1.0.1-1_amd64.deb /tmp/stonedb57_1.0.1-1_amd64.deb
RUN dpkg -i /tmp/stonedb*.deb
COPY stonedb-lib.tar.gz /tmp/stonedb-lib.tar.gz 
RUN cd /tmp && tar zxvf stonedb-lib.tar.gz && cp lib/* /lib/x86_64-linux-gnu/
#COPY stone56.tar.gz /tmp/stone56.tar.gz

COPY docker-entrypoint.sh /usr/local/bin/
COPY stonedb-master.sh /usr/local/bin/
COPY stonedb-slave.sh /usr/local/bin/


RUN ln -s /usr/local/bin/docker-entrypoint.sh /entrypoint.sh
RUN chmod u+x usr/local/bin/docker-entrypoint.sh

ENTRYPOINT [ "docker-entrypoint.sh" ]
CMD ["mysqld"]
