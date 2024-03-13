#!/bin/bash

source /tools/config
# 获取系统版本
GET_SYSTEM_CHECK=$(curl -sl https://"$url_address"/HiddenScholars/Linux-tools/"$con_branch"/Check/Check.sh | bash -s -- SYSTEM_CHECK)
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
mysql5_install_path=$(echo "/$install_path"/mysql5/ | tr -s '/')
mysql5_install_path_bin=$(echo "/$mysql5_install_path"/bin/ | tr -s '/')
mysql5_socket_path=$(echo "/$install_path"/mysql5/mysql.sock | tr -s '/')
mysql5_data_path=$(echo "/$install_path"/mysql5/data/ | tr -s '/')
mysql5_download_path=$(echo "/$download_path"/mysql/mysql | tr -s '/' )
mysql5_log_error_path=$(echo "/$install_path"/mysql/logs/error.log | tr -s '/')
mysql5_my_cnf_path=$(echo "/$mysql5_install_path"/my.cnf | tr -s '/')

bash <(curl -sl https://"$url_address"/HiddenScholars/Linux-tools/"$con_branch"/Check/Check.sh) PACKAGE_DOWNLOAD  mysql5  $(for i in "${mysql5_download_urls[@]}";do printf "%s " "$i";done)
GET_missing_dirs_mysql5=$(curl -sl https://"$url_address"/HiddenScholars/Linux-tools/"$con_branch"/Check/Check.sh | bash -s -- check_unpack_file_path)

    if [ -d "$mysql5_install_path" ];then
      mv "$mysql5_install_path" "$mysql5_install_path"$(date +%Y%m%d)_bak
    fi
    tar xvf "$mysql5_download_path" -C /tools/unpack_file/"$GET_missing_dirs_mysql5" --strip-components 1

if $(cp -rf /tools/unpack_file/"$GET_missing_dirs_mysql5"/*  "$mysql5_install_path");then
echo "复制完成"
mkdir "$mysql5_install_path"/etc/
cat << EOF >> "$mysql5_my_cnf_path"
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
  if $(chown -R  "$mysql5_user":"$mysql5_user"  "$mysql5_my_cnf_path");then
     sudo chmod 644 /etc/my.cnf
  fi
sed -i "\|$mysql5_install_path|d" /etc/profile
echo "export MYSQL_HOME=$mysql5_install_path">>/etc/profile
echo "export PATH=$PATH:$mysql5_install_path_bin" >>/etc/profile
source /etc/profile
  if $("$mysql5_install_path_bin"/mysql_install_db --user="$mysql5_user" --basedir="$mysql5_install_path" --datadir="$mysql5_data_path");then
     sudo cp ./support-files/mysql.server /etc/init.d/mysqld
     sudo chmod 777 /etc/init.d/mysqld
     /etc/init.d/mysqld start
     systemctl daemon-reload
     systemctl restart mysql.service
     echo "初始密码：$(cat /root/.mysql_secret | awk NR==2)"
  else
    echo "安装失败"
  fi
else
  echo "复制失败，安装失败"
fi

