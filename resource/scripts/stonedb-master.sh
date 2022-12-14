#!/bin/bash
set -ex
# 安装插件
function install_plug() {
  mysql -h127.0.0.1 -uroot -p$MYSQL_ROOT_PASSWORD -e "INSTALL PLUGIN rpl_semi_sync_master SONAME 'semisync_master.so';"
}

# 创建主从同步用户
function create_sync_user() {
  mysql -h127.0.0.1 -uroot -p$MYSQL_ROOT_PASSWORD -e "grant SELECT, REPLICATION SLAVE, REPLICATION CLIENT ON *.* to rpl@'%' identified by '$MYSQL_ROOT_PASSWORD'"
}

function change_my_cnf() {
  cat <<"EOF" >>/tmp/master
# enable GTID
gtid_mode = on
enforce_gtid_consistency = 1
#Enhanced semi-synchronization
loose-plugin-load = "rpl_semi_sync_master=semisync_master.so"
loose-rpl-semi-sync-master-enabled = 1
loose_rpl_semi_sync_master_timeout=1000
loose-rpl_semi_sync_master_wait_point=AFTER_SYNC
#Parallel replication
loose-slave_parallel_workers=8
loose-slave-parallel-type=LOGICAL_CLOCK
master_info_repository=TABLE
relay_log_info_repository=TABLE
sync_binlog=1
innodb_flush_log_at_trx_commit=1
relay_log_recovery = 1
EOF

  # because my.cnf may mount from docker outside, sed may error of ` Device or resource busy`
  cp /opt/stonedb57/install/my.cnf /opt/stonedb57/install/my.cnf2
  sed -i 's/server-id = 1/server-id = 10350/g' /opt/stonedb57/install/my.cnf2
  sed -i "/server-id = 10350/r /tmp/master" /opt/stonedb57/install/my.cnf2
  cat /opt/stonedb57/install/my.cnf2 >/opt/stonedb57/install/my.cnf
  rm -rf /opt/stonedb57/install/my.cnf2

  cat /opt/stonedb57/install/my.cnf

  chown -R mysql:mysql /opt/stonedb57/


}

echo "install_plug"
install_plug

echo "create_sync_user"
create_sync_user

echo "change_my_cnf"
change_my_cnf

echo "restart\n"
/etc/init.d/stonedb restart
