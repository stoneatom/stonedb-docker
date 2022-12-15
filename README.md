## Stonedb docker images make repository


###File tree

```
├── Dockerfile
├── README.md
└── resource
    ├── rpm  #sofeware file 
    │   ├── jemalloc-3.6.0-1.el7.x86_64.rpm
    │   ├── jemalloc-devel-3.6.0-1.el7.x86_64.rpm
    │   ├── libzstd-1.5.2-1.el7.x86_64.rpm
    │   ├── libzstd-devel-1.5.2-1.el7.x86_64.rpm
    │   ├── snappy-1.1.0-3.el7.x86_64.rpm
    │   ├── snappy-devel-1.1.0-3.el7.x86_64.rpm
    │   ├── stonedb_5.7-1.0.1-1.el7.x86_64.rpm
    │   └── stonedb_5.7-debuginfo-1.0.1-1.el7.x86_64.rpm
    └── scripts #shell file
        ├── docker-entrypoint.sh
        ├── stonedb-master.sh
        └── stonedb-slave.sh
        
```

### How to build
#### standalone
```shell
docker run -itd \
--cpus={{Cpu}} \
-m={{Memory}}M \
--name {{ClusterName}} \
-p 3306:3306 \
--restart=always \
-e MYSQL_ROOT_PASSWORD={{Password}} \
-v {{DataPath}}/{{ClusterName}}/config/my.cnf:/opt/stonedb57/install/my.cnf:rw \
-v {{DataPath}}/{{ClusterName}}/data:/opt/stonedb57/install/data:rw \
stoneatom/stonedb:5.7v1.0.1_centos
```

#### master-slave
run master
```shell
docker run -itd \
--cpus={{Cpu}} \
-m={{Memory}}M \
--name {{ClusterName}} \
-p 3306:3306 \
--restart=always \
-e MYSQL_ROOT_PASSWORD={{Password}} \
-v {{DataPath}}/{{ClusterName}}/config/my.cnf:/opt/stonedb57/install/my.cnf:rw \
-v {{DataPath}}/{{ClusterName}}/data:/opt/stonedb57/install/data:rw \
-e ROLE=master \
stoneatom/stonedb:5.7v1.0.1_centos
```

run slave
```shell
docker run -itd \
--cpus={{Cpu}} \
-m={{Memory}}M \
--name {{ClusterName}} \
-p 3306:3306 \
--restart=always \
-e MYSQL_ROOT_PASSWORD={{Password}} \
-v {{DataPath}}/{{ClusterName}}/config/my.cnf:/opt/stonedb57/install/my.cnf:rw \
-v {{DataPath}}/{{ClusterName}}/data:/opt/stonedb57/install/data:rw \
-e ROLE=slave \
-e MASTER_IP={{MasterIp}} \
-e MASTER_PORT={{MasterPory}} \
stoneatom/stonedb:5.7v1.0.1_centos
```

### How to build

1. replace the rpm sofeware file and edit scripts for yourself
2. edit Dockerfile and make docker images
```
docker build -t your-docker-repository/you-images-name:5.7v1.0.1_centos .
```
3. push docker images
```
docker push your-docker-repository/you-images-name:5.7v1.0.1_centos 
```