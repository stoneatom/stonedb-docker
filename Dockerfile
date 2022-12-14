FROM centos:7
EXPOSE 3306
ENV ROLE ""
ENV MASTER_IP ""
ENV MASTER_PORT "3306"

#------- resource -------
COPY resource /opt/resource/
#------- install -------
RUN rpm -ivh --force /opt/resource/rpm/*.rpm

ENV PATH="${PATH}:/opt/stonedb57/install/bin:/opt/stonedb57/install"

ENTRYPOINT [ "/opt/resource/scripts/docker-entrypoint.sh" ]
