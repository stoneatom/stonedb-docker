## Stonedb docker images make repository


### File tree

```
.
├── Dockerfile
├── README.md
└── resource
    ├── rpm
    │   ├── jemalloc-3.6.0-1.el7.x86_64.rpm
    │   ├── jemalloc-devel-3.6.0-1.el7.x86_64.rpm
    │   ├── libaio-0.3.109-13.el7.x86_64.rpm
    │   ├── libaio-devel-0.3.109-13.el7.x86_64.rpm
    │   ├── libzstd-1.5.2-1.el7.x86_64.rpm
    │   ├── libzstd-devel-1.5.2-1.el7.x86_64.rpm
    │   ├── snappy-1.1.0-3.el7.x86_64.rpm
    │   ├── snappy-devel-1.1.0-3.el7.x86_64.rpm
    │   └── stonedb-ce-5.7-v1.0.3.el7.x86_64.rpm
    └── scripts
        ├── docker-entrypoint.sh
        ├── stonedb-master.sh
        └── stonedb-slave.sh

        
```

### How to run your stonedb database
#### standalone
```shell
docker run -itd \
--cpus={{Cpu}} \
--memory={{Memory}}M \
--name {{ClusterName}} \
-p 3306:3306 \
--restart=always \
-e MYSQL_ROOT_PASSWORD={{Password}} \
-v {{DataPath}}/{{ClusterName}}/config/my.cnf:/opt/stonedb57/install/my.cnf:rw \
-v {{DataPath}}/{{ClusterName}}/data:/opt/stonedb57/install/data:rw \
stoneatom/stonedb:5.7v1.0.2_centos
```

#### master-slave
run master
```shell
docker run -itd \
--cpus={{Cpu}} \
--memory={{Memory}}M \
--name {{ClusterName}} \
-p 3306:3306 \
--restart=always \
-e MYSQL_ROOT_PASSWORD={{Password}} \
-v {{DataPath}}/{{ClusterName}}/config/my.cnf:/opt/stonedb57/install/my.cnf:rw \
-v {{DataPath}}/{{ClusterName}}/data:/opt/stonedb57/install/data:rw \
-e ROLE=master \
stoneatom/stonedb:5.7v1.0.3_centos
```

run slave
```shell
docker run -itd \
--cpus={{Cpu}} \
--memory={{Memory}}M \
--name {{ClusterName}} \
-p 3306:3306 \
--restart=always \
-e MYSQL_ROOT_PASSWORD={{Password}} \
-v {{DataPath}}/{{ClusterName}}/config/my.cnf:/opt/stonedb57/install/my.cnf:rw \
-v {{DataPath}}/{{ClusterName}}/data:/opt/stonedb57/install/data:rw \
-e ROLE=slave \
-e MASTER_IP={{MasterIp}} \
-e MASTER_PORT={{MasterPort}} \
stoneatom/stonedb:5.7v1.0.3_centos
```

### How to build

1. replace the rpm sofeware file and edit scripts for yourself
2. edit Dockerfile and make docker images
```shell
docker build -t your-docker-repository/you-images-name:5.7v1.0.3_centos .
```
3. push docker images
```shell
docker push your-docker-repository/you-images-name:5.7v1.0.3_centos 
```