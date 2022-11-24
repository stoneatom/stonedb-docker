#!/bin/bash

# logging functions
stonedb_log(){
	local type="$1"; shift
	# accept argument string or stdin
	local text="$*"; if [ "$#" -eq 0 ]; then text="$(cat)"; fi
	local dt; dt="$(date --rfc-3339=seconds)"
	printf '%s [%s] : %s\n' "$dt" "$type" "$text"
}
stonedb_note(){
	stonedb_log Note "$@"
}
stonedb_warn() {
	stonedb_log Warn "$@" >&2
}
stonedb_error() {
	stonedb_log ERROR "$@" >&2
	exit 1
}

_check_deb(){

	if [ ! -f /tmp/stonedb*.deb ] ; then
			stonedb_error "Cant find StoneDB*.deb "
	elif [ `find /tmp/ -name stonedb*.deb | wc -l` -gt 1 ] ; then
		stonedb_error <<-EOF
			More than one stonedb*.deb:
				`find /tmp/ -name stonedb*.deb`
		EOF
	fi

		
}

docker_verify_minimum_env(){
	if [ -z "$MYSQL_ROOT_PASSWORD" -a -z "$MYSQL_ALLOW_EMPTY_PASSWORD" -a -z "$MYSQL_RANDOM_ROOT_PASSWORD" ];then
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

stonedb_set_root_passwd(){
	stonedb_note "set passwd"
	sdb_passwd=`grep "temporary password" /opt/stonedb57/install/log/tianmu.log |awk -F " " '{print $14}'`
	/opt/stonedb57/install/bin/mysqladmin -uroot -p"$sdb_passwd" password "$MYSQL_ROOT_PASSWORD"
	#create user
	if [ -n "$MYSQL_USER" ];then
		/opt/stonedb57/install/bin/mysql -uroot -p"$MYSQL_ROOT_PASSWORD" -e "grant all on *.* to $MYSQL_USER@'%' identified by '$MYSQL_PASSWORD' with grant option"
	else
		/opt/stonedb57/install/bin/mysql -uroot -p"$MYSQL_ROOT_PASSWORD" -e "grant all on *.* to root@'%' identified by '$MYSQL_ROOT_PASSWORD' with grant option"
	fi
}

stonedb_check_logdir(){
	if [ ! -d /opt/stonedb57/install/log ];then
		mkdir -p /opt/stonedb57/install/log
		touch /opt/stonedb57/install//log/{query.log,tianmu.log,trace.log} \
		&& chown -R mysql:mysql /opt/stonedb57/install//log/*
    fi
}

stonedb_install(){
	docker_verify_minimum_env
	_check_deb
	#mkdir pid datadir logdir and baselogdir
	stonedb_check_logdir
    if [ ! -d /opt/stonedb57/install/data/mysql/ ];then
            #mkdir -p /opt/stonedb57/install/{data,binlog,log,tmp,redolog,undolog}
	        mkdir -p /opt/stonedb57/install/data
            chown -R mysql:mysql /opt/stonedb57/install/
            /opt/stonedb57/install/bin/mysqld --defaults-file=/etc/my.cnf --initialize --user=mysql
			/opt/stonedb57/install/support-files/mysql.server start
			stonedb_set_root_passwd
	else
		stonedb_warn "datadir is exists,will create tianmu.log"
		stonedb_check_logdir
	fi
	/opt/stonedb57/install/support-files/mysql.server restart
	if [ $? -ne 0 ] ; then
		stonedb_error <<-EOF
			StoneDB install faild!
		EOF
	else
		stonedb_note <<-EOF
			StoneDB install successfuly!
		EOF
	fi
        
	# echo 'export PATH=$PATH:/opt/stonedb57/install/bin/' >> ~/.bash_profile
	# . ~/.bash_profile


}

_main(){
	# _check_env
	if [ -f /opt/stonedb*/install/bin/mysqld -a -d /opt/stonedb*/install/data/mysql  ];then
		stonedb_note "StoneDB already exists,we will restart it......"
		stonedb_check_logdir
		chown -R mysql:mysql /opt/stonedb57/install/
		/opt/stonedb57/install/support-files/mysql.server restart
		
	else
		stonedb_note "StoneDB not install,we will install StoneDB......"
		stonedb_install
	fi
	
	tail -f /opt/stonedb57/install/log/tianmu.log

	
	
}

_main

