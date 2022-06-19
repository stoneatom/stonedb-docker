# FROM centos:7
FROM debian:buster-slim

MAINTAINER @zsp zhangshaopeng@stoneatom.com

# backup sources.list
RUN groupadd -r mysql && useradd -r -g mysql mysql
RUN cp /etc/apt/sources.list /etc/apt/sources.list.bak
# Change apt source to the source of University of Science and Technology of China
# RUN sed -i 's/deb.debian.org/mirrors.ustc.edu.cn/g' /etc/apt/sources.list
# RUN sed -i 's|security.debian.org/debian-security|mirrors.ustc.edu.cn/debian-security|g' /etc/apt/sources.list
RUN apt clean && apt update -y
# 
RUN apt-get install wget libsnappy-dev autoconf libncurses5 -y
RUN wget http://192.168.30.30/stonedb/56/stone56.tar.gz -O /tmp/stone56.tar.gz
#COPY stone56.tar.gz /tmp/stone56.tar.gz

COPY docker-entrypoint.sh /usr/local/bin/
RUN ln -s usr/local/bin/docker-entrypoint.sh /entrypoint.sh # backwards compat


#centos 7
# RUN yum install wget -y
# RUN wget http://192.168.30.30/stonedb/56/stone56.tar.gz -O /tmp/stone56.tar.gz
# RUN tar -zxvf /tmp/stone56.tar.gz -C /
# RUN ln -s /stonedb56/install/bin/mysqld /usr/bin/mysqld
# RUN ls -l /stonedb56/install/
# RUN cd /stonedb56/install && ./reinstall.sh

ENTRYPOINT [ "./entrypoint.sh" ]
CMD ["/bin/bash"]
