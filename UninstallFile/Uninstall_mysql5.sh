#!/bin/bash

source /etc/profile
config_path=/tools/
config_file=/tools/config.xml
controls=$(awk -v RS="</system>" '/<system>/{gsub(/.*<system>[\r\n\t ]*|[\r\n\t ]*$/,"");print}' $config_file | awk -F'[><]' '/<controls>/{print $3}')
install_path=$(awk -v RS="</paths>" '/<paths>/{gsub(/.*<paths>[\r\n\t ]*|[\r\n\t ]*$/,"");print}' $config_file | awk -F'[><]' '/<install_path>/{print $3}')

function KILL_MYSQL5_PROCESS() {
getMysqlProcess_number_1=($(pgrep mysql))
if [ "${#getMysqlProcess_number_1[@]}" != 0 ]; then
    printf "检测到Mysql进程，进程ID："
    for i in "${getMysqlProcess_number_1[@]}"
    do
      printf "%s\t" "$i"
    done
    printf "\n"
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
mysql5_install_path=$(echo "/$install_path"/mysql5/ | tr -s '/')
if [ -n "$mysql5_install_path" ]; then
  sed -i "\|$mysql5_install_path|d" /etc/profile
fi

if which mysql &>/dev/null; then
"$controls" remove -y mysql* mariadb* &>/dev/null
fi
if [ -f /etc/init.d/mysqld ]; then
   /etc/init.d/mysqld stop &>/dev/null
   sudo  rm -rf /etc/init.d/mysqld
   systemctl stop mysqld &>/dev/null
   systemctl daemon-reload
fi
GET_PATH="$install_path/mysql5/"
if [ -d "$GET_PATH" ]; then
    sudo rm -rf "$GET_PATH"
    echo  "卸载完成"
else
   if [ "${#getMysqlProcess_number_1[@]}" -ne 0 ]; then
       read -rp "未获取到mysql路径，手动输入：" temp
       if [ -n "$temp" ] && [ "$temp" != "/" ] && [ -d "$temp" ]; then
          sudo rm -rf "$temp"
           echo  "卸载完成"
       fi
   else
     echo  "卸载完成"
   fi
fi

}

KILL_MYSQL5_PROCESS
DELETE_MYSQL5_FILE