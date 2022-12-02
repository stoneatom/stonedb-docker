#!/bin/bash

# 安装插件

function install_plug() {
  /opt/stonedb57/install/bin/mysql -uroot -p$MYSQL_ROOT_PASSWORD -e "INSTALL PLUGIN rpl_semi_sync_slave SONAME 'semisync_slave.so';"
}

function change_my_cnf() {
cat << "EOF" >> /tmp/stonedb-slave-slave

# enable GTID
gtid_mode = on
enforce_gtid_consistency = 1
#增强半同步
loose-plugin-load = "rpl_semi_sync_slave=semisync_slave.so"
loose-rpl-semi-sync-slave-enabled = 1
loose_rpl_semi_sync_master_timeout=1000
loose-rpl_semi_sync_master_wait_point=AFTER_SYNC
binlog-ignore-db=information_schema
binlog-ignore-db=performance_schema
binlog-ignore-db=sys
sync_binlog=1
innodb_flush_log_at_trx_commit=1
slave-parallel-type=LOGICAL_CLOCK
slave_parallel_workers=8
master_info_repository=TABLE
relay_log_info_repository=TABLE
relay_log_recovery=ON
log_slave_updates=ON
read_only = 1
EOF
    sed -i 's/server-id = 1/server-id = 10360/g' /etc/my.cnf
    sed -i "/server-id = 10360/r /tmp/stonedb-slave-slave" /etc/my.cnf
    /etc/init.d/stonedb restart
    sleep 5
}

function export_all_database_to_slave() {
  /opt/stonedb57/install/bin/mysqldump -h$MASTER_IP -uroot -p$MYSQL_ROOT_PASSWORD --master-data=2 --force --all-databases > /tmp/stonedb-slave-db_bak`date '+%Y%m%d'`.sql
}

function import_all_database_to_slave() {
  /opt/stonedb57/install/bin/mysql -uroot -p$MYSQL_ROOT_PASSWORD < /tmp/stonedb-slave-db_bak`date '+%Y%m%d'`.sql
}

function change_sync_master() {
  /opt/stonedb57/install/bin/mysql -uroot -p$MYSQL_ROOT_PASSWORD -e "stop slave;reset slave all;reset master"
  /opt/stonedb57/install/bin/mysql -uroot -p$MYSQL_ROOT_PASSWORD -e "change master to master_host='$MASTER_IP',master_port=3306,master_user='rpl',master_password='$MYSQL_ROOT_PASSWORD',master_auto_position=1;start slave;"
  slave_status=`/opt/stonedb57/install/bin/mysql -uroot -p$MYSQL_ROOT_PASSWORD -e "show slave status\G" |grep -E 'Slave.*Running: Yes'|wc -l`

    if [ $slave_status -lt 2 ];then
        echo "StoneDB Master Replication setting fail"
    else
        echo "StoneDB Master Replication setting successfully"
    fi

  /opt/stonedb57/install/bin/mysql -uroot -p$MYSQL_ROOT_PASSWORD -e "flush privileges"

}

install_plug
change_my_cnf
export_all_database_to_slave
import_all_database_to_slave
change_sync_master