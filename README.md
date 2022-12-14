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

### How to use

1. replace the rpm sofeware file and edit scripts for yourself
2. edit Dockerfile and make docker images
```
docker build -t your-docker-repository/you-images-name:5.7v1.0.1_centos .
```
3. push docker images
```
docker push your-docker-repository/you-images-name:5.7v1.0.1_centos 
```