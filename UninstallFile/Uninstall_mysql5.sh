#!/bin/bash

read -rp "回车后确认卸载："
source /etc/profile
source /tools/config
function KILL_MYSQL5_PROCESS() {
getMysqlProcess_number_1=($(pgrep mysql))
if [ "${#getMysqlProcess_number_1[@]}" != 0 ]; then
    echo "检测到Mysql进程，进程ID："
    for i in "${getMysqlProcess_number_1[@]}"
    do
      echo "$i"
    done
        for y in "${getMysqlProcess_number_1[@]}"
            do
              echo "开始kill Mysql进程 $y"
              kill -9 "$y"
            done
        sleep 2
    getMysqlProcess_number2=($(pgrep mysql))
    [ "${#getMysqlProcess_number2[@]}" != 0 ] && echo "Mysql进程杀死失败，退出..." && return 1
fi
}
function DELETE_MYSQL5_FILE() {
GET_PACKAGE_MASTER=$(curl -sl https://"$url_address"/HiddenScholars/Linux-tools/"$con_branch"/Check/Check.sh | bash -s -- PACKAGE_MASTER)
GET_MYSQL5_SERVICE_PATH=($(find / -name "mysqld.service"))
if which mysql &>/dev/null; then
"$GET_PACKAGE_MASTER" remove -y mysql* mariadb* &>/dev/null
systemctl daemon-reload
fi
if [ -f /etc/init.d/mysqld ]; then
    rm -rf /etc/init.d/mysqld
fi
GET_PATH="$install_path/mysql5/"
if [ -d "$GET_PATH" ]; then
    rm -rf "$GET_PATH"
    for i in "${GET_MYSQL5_SERVICE_PATH[@]}"
    do
          rm -rf "$i"
    done
    echo  "卸载完成"
else
   if [ "${#getMysqlProcess_number_1[@]}" -ne 0 ]; then
       read -rp "未获取到mysql路径，手动输入：" temp
       if [ -n "$temp" ] && [ "$temp" != "/" ] && [ -d "$temp" ]; then
           rm -rf "$temp"
           echo  "卸载完成"
       fi
   else
     echo  "卸载完成"
   fi
fi

}

KILL_MYSQL5_PROCESS
DELETE_MYSQL5_FILE