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
		rm -rf /stone*
		stonedb_note "tar -zxvf /tmp/stone*.tar.gz -C /"
		tar -zxvf /tmp/stone*.tar.gz -C $tar_dir > /dev/null
		ln -s $stonedb_dir/bin/* /usr/local/bin/
	fi
}

#检查是否存在配置文件
stonedb_check_config(){
	if [  ! -f $stonedb_cnf ];then
		stonedb_error "cant find stonedb.cnf"
	fi
	stonedb_note "StoneDB Config:$stonedb_cnf"
}

stonedb_get_config(){
	ehco "1"
	# $stonedb_dir/bin/mysqld --
}

#检查数据文件夹路径是否存在
stonedb_check_datadir(){
	declare -g DATABASE_ALREADY_EXISTS
	if [ -d "$stonedb_dir/mysql" ]; then
		DATABASE_ALREADY_EXISTS='true'
	fi
}

#获取datadir等配置信息
stonedb_get_database_dir(){
	declare -g DATADIR LOGBIN LOG TMP 
	# DATADIR=`sed '/datadir/!d;s/.*= //' /stonedb*/install/stonedb.cnf`
	# LOGBIN=`sed '/log-bin/!d;s/.*=//' /stonedb*/install/stonedb.cnf`
	#sed '/logbin.*=/' /stonedb*/install/stonedb.cnf
	DATADIR="$stonedb_dir/data/innodb"
	LOGBIN="$stonedb_dir/binlog"
	LOG=" $stonedb_dir/log"
	TMP="$stonedb_dir/tmp"
}

#创建stonedb 目录
stonedb_create_db_directories(){
	stonedb_note "创建数据路径 `echo $stonedb_dir`"
	# mkdir -p $stonedb/{data/innodb,binlog,log,tmp}
	stonedb_note "mkdir -p $DATADIR $LOGBIN $LOG $TMP"
	mkdir -p $DATADIR $LOGBIN $LOG $TMP
	chown -R mysql:mysql $(dirname "$stonedb_dir")
	stonedb_note "Create stonedb database dir successfully!"
}

#数据初始化
# Initializes database
stonedb_init_database(){
	#./scripts/${mysql_install_db_script} --defaults-file=./stonedb.cnf --user=mysql --basedir=/stonedb56/install --datadir=/stonedb56/install/data
	pushd $stonedb_dir
	$stonedb_dir/scripts/mysql_install_db --defaults-file=$stonedb_dir/stonedb.cnf --user=mysql --basedir=$stonedb_dir --datadir=$stonedb_dir/data
	popd
}


#执行入口
_main(){
	stonedb_note "weclone to stonedb!'"
	stonedb_check_datadir
	echo ${#DATABASE_ALREADY_EXISTS}
	if [ -z "$DATABASE_ALREADY_EXISTS" ];then
		
		#解压
		stonedb_decompress 
		#检查配置文件
		stonedb_check_config
		#获取stonedb配置信息
		stonedb_get_database_dir
		#配置stonedb 环境
		stonedb_create_db_directories
		# stonedb_note "$DATADIR,$LOGBIN"
		#初始化stonedb
		stonedb_init_database
	fi
	$stonedb_dir/support-files/mysql.server start
	tail -f $stonedb_dir/log/mysqld.log

}

_main "$@"

