#!/bin/bash

read -rp "回车后确认卸载："
source /etc/profile
source /tools/config
function KILL_NGINX_PROCESS() {
getNginxProcess_number1=($(pgrep nginx))
if [ "${#getNginxProcess_number1[@]}" != 0 ]; then
    echo "检测到Nginx进程，进程ID："
    for i in "${getNginxProcess_number1[@]}"
    do
      printf "%s" "$i"
    done
    printf "\n"
        for y in "${getNginxProcess_number1[@]}"
            do
              echo "开始kill Nginx进程 $y"
              kill -9 "$y"
            done
        sleep 2
    getNginxProcess_number2=($(pgrep nginx))
    [ "${#getNginxProcess_number2[@]}" != 0 ] && echo "Nginx进程杀死失败，退出..." && return 1
fi
}
function DELETE_NGINX_FILE() {
GET_PACKAGE_MASTER=$(curl -sl https://"$url_address"/HiddenScholars/Linux-tools/"$con_branch"/Check/Check.sh | bash -s -- PACKAGE_MASTER)
GET_NGINX_SERVICE_PATH=($(find / -name "nginx.service"))
if which nginx &>/dev/null; then
"$GET_PACKAGE_MASTER" remove -y nginx
systemctl daemon-reload
fi
GET_PATH="$install_path/nginx/"
if [ -d "$GET_PATH" ]; then
    rm -rf "$GET_PATH"
    for i in "${GET_NGINX_SERVICE_PATH[@]}"
    do
          rm -rf "$i"
    done
    echo  "卸载完成"
else
   if [ "${#getNginxProcess_number1[@]}" != 0 ]; then
       read -rp "未获取到nginx路径，手动输入：" temp
       if [ -n "$temp" ] && [ "$temp" != "/" ] && [ -d "$temp" ]; then
           rm -rf "$temp"
           echo  "卸载完成"
       fi
  else
    echo  "卸载完成"
   fi
fi

}

KILL_NGINX_PROCESS
DELETE_NGINX_FILE