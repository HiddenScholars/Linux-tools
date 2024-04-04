#!/bin/bash

source /tools/config
# 进程检测
GET_PROCESS_CHECK=($(curl -sl https://"$url_address"/HiddenScholars/Linux-tools/"$con_branch"/Check/Check.sh | bash -s -- PROCESS_CHECK mysql))
# 端口检测
GET_PORT_CHECK=($(curl -sl https://"$url_address"/HiddenScholars/Linux-tools/"$con_branch"/Check/Check.sh | bash -s -- PORT_CHECK "$mysql5_initial_port"))
if [ -n "$GET_PROCESS_CHECK" ] && [ -n "$GET_PORT_CHECK" ] && [ "${#GET_PROCESS_CHECK[@]}" -ne 0 ]  && [ "${#GET_PORT_CHECK[@]}" -ne 0 ]; then
    read -rp "mysql程序已存在是否继续安装（y/n）：" select
    [ "$select" != "y" ] && exit 0
elif [ -n "$GET_PROCESS_CHECK" ] &&[ "${#GET_PROCESS_CHECK[@]}" -ne 0 ] ; then
    echo "mysql有残留进程，尝试执行卸载脚本后再次执行"
    exit 1
elif [ -n "$GET_PORT_CHECK" ] &&[ "${#GET_PORT_CHECK[@]}" -ne 0 ]; then
    for i in "${GET_PORT_CHECK[@]}"
    do
        printf "%s\t" "$i"
    done
     read -rp "被占用是否继续安装（y/n）：" select
    [ "$select" != "y" ] && exit 0
fi

  if [ "$SystemVersion" == "centos" ] || [ "$SystemVersion" == "Anolis OS" ]; then
      yum_package=(libaio)
      for i in "${yum_package[@]}"
      do
       "$controls" -y install  "$i" &>/dev/null
      done
  elif [ "$SystemVersion" == "ubuntu" ] || [ "$SystemVersion" == "debian" ]; then
       apt_package=(libaio1)
       for y in "${apt_package[@]}"
       do
          "$controls" -y install "$y" &>/dev/null
       done
  else
    echo "未支持的系统版本"
    exit 1
  fi

"$controls" -y remove mysql* mariadb* &>/dev/null

mysql5_install_path=$(echo "/$install_path"/mysql5/ | tr -s '/')
mysql5_install_path_bin=$(echo "/$mysql5_install_path"/bin/ | tr -s '/')
mysql5_socket_path=$(echo "/$install_path"/mysql5/mysql.sock | tr -s '/')
mysql5_data_path=$(echo "/$install_path"/mysql5/data/ | tr -s '/')
mysql5_download_path=$(echo "/$download_path"/mysql5/mysql5 | tr -s '/' )
mysql5_log_error_path=$(echo "/$install_path"/mysql5/logs/mysqld.log | tr -s '/')
mysql5_pid_path=$(echo "$mysql5_install_path_bin"/mysql5.pid | tr -s '/')
bash <(curl -sl https://"$url_address"/HiddenScholars/Linux-tools/"$con_branch"/Check/Check.sh) PACKAGE_DOWNLOAD  mysql5  $(for i in "${mysql5_download_urls[@]}";do printf "%s " "$i";done)
GET_missing_dirs_mysql5=$(curl -sl https://"$url_address"/HiddenScholars/Linux-tools/"$con_branch"/Check/Check.sh | bash -s -- check_unpack_file_path)
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] Start unzipping."
    tar xvf "$mysql5_download_path" -C /tools/unpack_file/"$GET_missing_dirs_mysql5" --strip-components 1 &>/dev/null
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] The decompression is complete."
      if [ -d "$mysql5_install_path" ];then
        if [ -d "$install_path/BackupMysql5$(date '+%Y%m%d')" ]; then
        for (( i = 1; i < 10000; i++ )); do
            if [ ! -d "$install_path/BackupMysql5$(date '+%Y%m%d')$i" ]; then
              cd "$install_path" && mv "BackupMysql5$(date '+%Y%m%d')" "BackupMysql5$(date '+%Y%m%d')$i"
              i=10000
            fi
        done
        fi
        cd "$install_path" && mv mysql5 "BackupMysql5$(date '+%Y%m%d')"
        echo "[$(date '+%Y-%m-%d %H:%M:%S')] 原始路径备份：$install_path/BackupMysql5$(date '+%Y%m%d')"
      fi
      mkdir -p "$mysql5_install_path" "$mysql5_install_path"/etc/ "$mysql5_install_path"/logs/
          mv /tools/unpack_file/"$GET_missing_dirs_mysql5"/* "$mysql5_install_path"
if [ -f "$mysql5_install_path_bin/mysqld" ];then
cat << EOF > /etc/my.cnf
[mysql]
socket=$mysql5_socket_path
[mysqld]
socket=$mysql5_socket_path
port=$mysql5_initial_port
basedir=$mysql5_install_path
datadir=$mysql5_data_path
max_connections=200
character-set-server=utf8
lower_case_table_names=1
max_allowed_packet=16M
explicit_defaults_for_timestamp=true
log-error=$mysql5_log_error_path
pid-file=$mysql5_pid_path
[mysql.server]
user=$mysql5_user
basedir=$mysql5_install_path
EOF
      id "$mysql5_user" &>/dev/null
      if [ $? -ne 0 ]; then
         useradd -s /sbin/nologin "$mysql5_user"
      fi
  chown -R "$mysql5_user":"$mysql5_user"  "$mysql5_install_path"
  if [ $? -eq 0 ];then
     sudo chmod 644 /etc/my.cnf
     sudo chown -R "$mysql5_user":"$mysql5_user" /etc/my.cnf
  fi
sed -i "\|$mysql5_install_path|d" /etc/profile
echo "export MYSQL_HOME=$mysql5_install_path" >>/etc/profile
echo "export PATH=$PATH:$mysql5_install_path_bin" >>/etc/profile
source /etc/profile
echo "数据库开始安装"
"$mysql5_install_path_bin"/mysqld --initialize  --user="$mysql5_user" --basedir="$mysql5_install_path" --datadir="$mysql5_data_path"
	[ -f "$mysql5_log_error_path" ] && cat "$mysql5_log_error_path"
		GET_initial_PASSWD=$(cat "$mysql5_log_error_path"  | grep 'A temporary password is generated for root@localhost:' | awk '{print $11}')
		  if [ -n "$GET_initial_PASSWD" ];then
			echo "安装成功."
			cp -rf "$mysql5_install_path"/support-files/mysql.server /etc/init.d/mysqld
			sed -i "s#/usr/local/mysql#$mysql5_install_path#g" /etc/init.d/mysqld
			chmod 777 /etc/init.d/mysqld
			systemctl daemon-reload
			/etc/init.d/mysqld start && echo "启动成功"
			printf "数据库设置初始化操作... \n1、解决不重新设置密码就不能登陆的问题 \n2、设置root远程登陆权限\n"
			mysql -u root -p"$GET_initial_PASSWD" --connect-expired-password -e "alter user user() identified by '"$GET_initial_PASSWD"';"
			mysql -u root -p"$GET_initial_PASSWD" --connect-expired-password -e "grant all on *.* to root@'%' identified by '"$GET_initial_PASSWD"';"
			mysql -u root -p"$GET_initial_PASSWD" --connect-expired-password -e "flush privileges;"

		  else
			echo "安装失败"
		  fi
else
  printf "复制失败\n安装失败\n"
fi