FROM centos:7
EXPOSE 3306
ENV ROLE "standalone"
ENV MASTER_IP ""
ENV MASTER_PORT "3306"

#------- resource -------
COPY resource /opt/resource/
#------- install -------
RUN rpm -ivh --force /opt/resource/rpm/*.rpm
ENV PATH="${PATH}:/opt/stonedb57/install/bin:/opt/stonedb57/install"
ENV LD_LIBRARY_PATH="${LD_LIBRARY_PATH}:/opt/stonedb57/install/lib/extra/"
ENTRYPOINT [ "/opt/resource/scripts/docker-entrypoint.sh" ]
