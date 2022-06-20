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

tar_dir=/
stonedb_dir=$tar_dir/stonedb56/install
stonedb_cnf="$stonedb_dir/stonedb.cnf"



#Decompress stonedb.tar.gz
stonedb_decompress(){
	if [[ ! -f /tmp/stone56.tar.gz || -f $@ ]];then
		stonedb_error "cant find /tmp/stonedb.tar.gz"
	else
		stonedb_note "tar -zxvf /tmp/stone*.tar.gz -C /"
		tar -zxvf /tmp/stone*.tar.gz -C $tar_dir > /dev/null
		ln -s $stonedb_dir/bin/* /usr/local/bin/
	fi
}

#check stonedb.cnf
stonedb_check_config(){
	if [  ! -f $stonedb_cnf ];then
		stonedb_error "cant find stonedb.cnf"
	fi
	stonedb_note "StoneDB Config:$stonedb_cnf"
}



# stonedb_fix_socket(){
# 	socket=`sed '/socket/!d;s/.*=//' /stonedb*/install/stonedb.cnf |head -n 1`
# 	if [ $socket ];then
# 		rm $socket
# 	fi
# }

#get database dir
stonedb_get_database_dir(){
	declare -g DATADIR LOGBIN LOG TMP
	# DATADIR=`sed '/datadir/!d;s/.*= //' /stonedb*/install/stonedb.cnf`
	# LOGBIN=`sed '/log-bin/!d;s/.*=//' /stonedb*/install/stonedb.cnf`
	#sed '/logbin.*=/' /stonedb*/install/stonedb.cnf
	DATADIR="$stonedb_dir/data"
	LOGBIN="$stonedb_dir/binlog"
	LOG=" $stonedb_dir/log"
	TMP="$stonedb_dir/tmp"
	stonedb_note "$DATADIR/mysql"
}

stonedb_check_datadir(){
	declare -g DATABASE_ALREADY_EXISTS
	
	if [ -d "$DATADIR/mysql" ];then
		DATABASE_ALREADY_EXISTS='true'
	fi
}

#create database dir
stonedb_create_db_directories(){
	stonedb_note "create database dir `echo $stonedb_dir`"
	# mkdir -p $stonedb/{data/innodb,binlog,log,tmp}
	stonedb_note "mkdir -p $DATADIR/innodb $LOGBIN $LOG $TMP"
	mkdir -p $DATADIR/innodb $LOGBIN $LOG $TMP
	chown -R mysql:mysql $(dirname "$stonedb_dir")
	stonedb_note "Create stonedb database dir successfully!"
}


# Initializes database
stonedb_init_database(){
	#./scripts/${mysql_install_db_script} --defaults-file=./stonedb.cnf --user=mysql --basedir=/stonedb56/install --datadir=/stonedb56/install/data
	pushd $stonedb_dir
	$stonedb_dir/scripts/mysql_install_db --defaults-file=$stonedb_dir/stonedb.cnf --user=mysql --basedir=$stonedb_dir --datadir=$stonedb_dir/data
	popd
}

stonedb_SET_ROOT(){
	$stonedb_dir/bin/mysqladmin flush-privileges
	$stonedb_dir/bin/mysqladmin -u root password "stonedb123"
	sed -i 's/^skip-grant-tables/# skip-grant-tables/' $stonedb_dir/stonedb.cnf
	$stonedb_dir/support-files/mysql.server restart
	$stonedb_dir/bin/mysql -uroot -p"stonedb123" -e "GRANT ALL ON *.* to root@'%' identified by 'stonedb123'"

}


_main(){
	if [ "$1"=='mysqld' ];then
		stonedb_note "weclone to StoneDB!'"
		#get stonedb database dir
		stonedb_get_database_dir
		stonedb_check_datadir
		#Decompress
		stonedb_decompress 
		#check stonedb.cnf
		stonedb_check_config
		#create database dir
		stonedb_create_db_directories

		
		echo "${DATABASE_ALREADY_EXISTS}"
		if [ -z "$DATABASE_ALREADY_EXISTS" ];then

			#Initializes database
			stonedb_init_database

			$stonedb_dir/support-files/mysql.server start
			stonedb_SET_ROOT
		fi
		
		$stonedb_dir/support-files/mysql.server restart
		tail -f $stonedb_dir/log/mysqld.log
	fi

}

_main "$@"

