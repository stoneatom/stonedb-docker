#!/bin/bash
set -ex

stonedb_note() {
  echo "$(date '+%Y-%m-%d %H:%M:%S') [Note] $@"
}
stonedb_warn() {
  echo "$(date '+%Y-%m-%d %H:%M:%S') [Warn] $@"
}
stonedb_error() {
  echo "$(date '+%Y-%m-%d %H:%M:%S') [Error] $@"
  exit 1
}

docker_verify_minimum_env() {
  if [ -z "$MYSQL_ROOT_PASSWORD" -a -z "$MYSQL_ALLOW_EMPTY_PASSWORD" -a -z "$MYSQL_RANDOM_ROOT_PASSWORD" ]; then
    stonedb_error <<-'EOF'
			Database is uninitialized and password option is not specified
			    You need to specify one of the following as an environment variable:
			    - MYSQL_ROOT_PASSWORD
			    - MYSQL_ALLOW_EMPTY_PASSWORD
			    - MYSQL_RANDOM_ROOT_PASSWORD
		EOF
  fi

  # This will prevent the CREATE USER from failing (and thus exiting with a half-initialized database)
  if [ "$MYSQL_USER" = 'root' ]; then
    stonedb_error <<-'EOF'
			MYSQL_USER="root", MYSQL_USER and MYSQL_PASSWORD are for configuring a regular user and cannot be used for the root user
			    Remove MYSQL_USER="root" and use one of the following to control the root user password:
			    - MYSQL_ROOT_PASSWORD
			    - MYSQL_ALLOW_EMPTY_PASSWORD
			    - MYSQL_RANDOM_ROOT_PASSWORD
		EOF
  fi

  # warn when missing one of MYSQL_USER or MYSQL_PASSWORD
  if [ -n "$MYSQL_USER" ] && [ -z "$MYSQL_PASSWORD" ]; then
    stonedb_warn 'MYSQL_USER specified, but missing MYSQL_PASSWORD; MYSQL_USER will not be created'
  elif [ -z "$MYSQL_USER" ] && [ -n "$MYSQL_PASSWORD" ]; then
    stonedb_warn 'MYSQL_PASSWORD specified, but missing MYSQL_USER; MYSQL_PASSWORD will be ignored'
  fi
}

stonedb_set_root_passwd() {
  stonedb_note "set passwd"

  echo passwd
  grep "temporary password" /opt/stonedb57/install/log/mysqld.log

  grep "temporary password" /opt/stonedb57/install/log/tianmu.log

  sdb_passwd=$(grep "temporary password" /opt/stonedb57/install/log/mysqld.log | awk -F " " '{print $11}')

  mysql -h127.0.0.1 -uroot -p"$sdb_passwd" --connect-expired-password -e "alter user 'root'@'localhost'  identified by '$MYSQL_ROOT_PASSWORD';"

  #create user
  if [ -n "$MYSQL_USER" ]; then
    stonedb_note "grant all on *.* to $MYSQL_USER@%"
    mysql -h127.0.0.1 -uroot -p"$MYSQL_ROOT_PASSWORD" -e "grant all on *.* to $MYSQL_USER@'%' identified by '$MYSQL_PASSWORD' with grant option"
  else
    stonedb_note "grant all on *.* to root@%"
    mysql -h127.0.0.1 -uroot -p"$MYSQL_ROOT_PASSWORD" -e "grant all on *.* to root@'%' identified by '$MYSQL_ROOT_PASSWORD' with grant option"
  fi

  if [ $? -ne 0 ]; then
    stonedb_error "StoneDB install faild!"
  else
    stonedb_note "StoneDB install successfuly!"
  fi

}

stonedb_init() {
  mysqld --defaults-file=/opt/stonedb57/install/my.cnf --initialize --user=mysql
}

stonedb_start() {
  /etc/init.d/stonedb start >/dev/null 2>&1
}

master_slave() {
  if [ $ROLE = "master" ]; then
    stonedb_note "run master"
    bash /opt/resource/scripts/stonedb-master.sh
  fi

  if [ $ROLE = "slave" ]; then
    stonedb_note "run slave"
    bash /opt/resource/scripts/stonedb-slave.sh
  fi
}

_main() {
  # _check_env
  if [ -f /opt/stonedb*/install/bin/mysqld -a -d /opt/stonedb*/install/data/mysql ]; then
    stonedb_note "StoneDB already exists,we will restart it......"
    /etc/init.d/stonedb start >/dev/null 2>&1
  else
    stonedb_note "StoneDB not install,we will install StoneDB......"

    stonedb_note "docker_verify_minimum_env"
    docker_verify_minimum_env

    stonedb_note "stonedb_init"
    stonedb_init

    stonedb_note "stonedb start"
    /etc/init.d/stonedb start >/dev/null 2>&1

    stonedb_note "stonedb set passwd"
    stonedb_set_root_passwd


    master_slave
  fi

  tail -f /opt/stonedb57/install/log/tianmu.log

}

_main
