#!/bin/bash

source /tools/config
# 获取包管理器
GET_PACKAGE_MASTER=$(curl -sl https://"$url_address"/HiddenScholars/Linux-tools/"$con_branch"/Check/Check.sh | bash -s -- PACKAGE_MASTER)
# 进程检测
GET_PROCESS_CHECK=($(curl -sl https://"$url_address"/HiddenScholars/Linux-tools/"$con_branch"/Check/Check.sh | bash -s -- PROCESS_CHECK mysql))
# 端口检测
GET_PORT_CHECK=($(curl -sl https://"$url_address"/HiddenScholars/Linux-tools/"$con_branch"/Check/Check.sh | bash -s -- PORT_CHECK 3306))
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
"$GET_PACKAGE_MASTER" -y remove mysql* mariadb* &>/dev/null

mysql5_install_path=$(echo "/$install_path"/mysql5/ | tr -s '/')
mysql5_install_path_bin=$(echo "/$mysql5_install_path"/bin/ | tr -s '/')
mysql5_socket_path=$(echo "/$install_path"/mysql5/mysql.sock | tr -s '/')
mysql5_data_path=$(echo "/$install_path"/mysql5/data/ | tr -s '/')
mysql5_download_path=$(echo "/$download_path"/mysql5/mysql5 | tr -s '/' )
mysql5_log_error_path=$(echo "/$install_path"/mysql5/logs/error.log | tr -s '/')
mysql5_my_cnf_path=$(echo "/$mysql5_install_path"/etc/my.cnf | tr -s '/')

bash <(curl -sl https://"$url_address"/HiddenScholars/Linux-tools/"$con_branch"/Check/Check.sh) PACKAGE_DOWNLOAD  mysql5  $(for i in "${mysql5_download_urls[@]}";do printf "%s " "$i";done)
GET_missing_dirs_mysql5=$(curl -sl https://"$url_address"/HiddenScholars/Linux-tools/"$con_branch"/Check/Check.sh | bash -s -- check_unpack_file_path)
    echo "Start unzipping."
    tar xvf "$mysql5_download_path" -C /tools/unpack_file/"$GET_missing_dirs_mysql5" --strip-components 1 &>/dev/null
    echo "The decompression is complete."
    if [ -d "$mysql5_install_path" ];then
      rm -rf "$mysql5_install_path"
      mkdir -p "$mysql5_install_path"
      mkdir -p "$mysql5_install_path"/etc/
      mkdir -p "$mysql5_install_path"/logs/
    elif [ ! -d  "$mysql5_install_path" ]; then
      mkdir -p "$mysql5_install_path"
      mkdir -p "$mysql5_install_path"/logs/
    fi
if $(cp -rf /tools/unpack_file/"$GET_missing_dirs_mysql5"/*  "$mysql5_install_path");then
echo "复制完成"
cat << EOF > "$mysql5_my_cnf_path"
[mysql]
socket=$mysql5_socket_path
[mysqld]
socket=$mysql5_socket_path
port=3306
basedir=$mysql5_install_path
datadir=$mysql5_data_path
max_connections=200
character-set-server=utf8
lower_case_table_names=1
max_allowed_packet=16M
explicit_defaults_for_timestamp=true
log-error=$mysql5_log_error_path
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
     sudo chmod 644 "$mysql5_my_cnf_path"
  fi
sed -i "\|$mysql5_install_path|d" /etc/profile
echo "export MYSQL_HOME=$mysql5_install_path">>/etc/profile
echo "export PATH=$PATH:$mysql5_install_path_bin" >>/etc/profile
source /etc/profile
  "$mysql5_install_path_bin"/mysqld --initialize --user="$mysql5_user" --basedir="$mysql5_install_path" --datadir="$mysql5_data_path" --socket="$mysql5_socket_path" &>/dev/null
  if [ $? -eq 0 ];then
    cp -rf "$mysql5_install_path"/support-files/mysql.server /etc/init.d/mysqld
     if [ $? -eq 0 ];then
         sed -i "s#/usr/local/mysql#$mysql5_install_path#g" /etc/init.d/mysqld
         sudo chmod 777 /etc/init.d/mysqld
         mysqld_safe --skip-grant-tables &
         sleep 5
mysql -u root << EOF
alter user user() identified by "1qaz2wsx#EDC";
FLUSH PRIVILEGES;
EOF
         /etc/init.d/mysqld start
         systemctl daemon-reload
         systemctl enable mysqld.service
     fi
     echo "安装成功."
     echo "root登陆密码：1qaz2wsx#EDC"
  else
    echo "安装失败"
  fi
else
  printf "复制失败\n安装失败\n"
fi