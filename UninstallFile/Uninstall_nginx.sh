#!/bin/bash

uninstall_select=''
read -p "确认卸载（y/n）" $uninstall_select
[ ! "${uninstall_select}" == "y" ] && return

source /etc/profile
source /tools/config.sh
if [ `ps -ef | grep nginx | grep -v grep | awk '{print $2}' | wc -l ` != 0 ]; then
    echo "检测到Nginx进程，进程ID：`ps -ef | grep nginx | grep -v grep | awk '{print $2}'`"
    killall_select=1
    while [ $killall_select -lt 4 ]; do
      echo "开始killNginx进程 $killall_select次尝试"
        for i in `ps -ef | grep nginx | grep -v grep | awk '{print $2}'`
            do
              kill -9 $i
            done
        sleep 2
       if [ `ps -ef | grep nginx | grep -v grep | awk '{print $2}' | wc -l ` != 0 ];then
          let killall_select++
       elf [ `ps -ef | grep nginx | grep -v grep | awk '{print $2}' | wc -l ` == 0 ];then
          killall_select=3
       fi
    done
    [ `ps -ef | grep nginx | grep -v grep | awk '{print $2}' | wc -l ` != 0 ] && echo "Nginx进程杀死失败，退出..." && exit 0
    printf "获取Nginx安装路径："
    echo $NGINX_HOME
    if [ -z $NGINX_HOME ]; then
        command -v nginx
       if [ `command -v nginx` ==  /usr/sbin/nginx ];then
        $controls remove -y nginx
        $controls autoremove -y nginx
       fi
    [ -f /etc/init.d/nginx ] && sudo rm -f /etc/init.d/nginx
    systemctl disable nginx.service &>/dev/null
    [ -f /usr/lib/systemd/system/nginx.service ] && sudo rm -rf /usr/lib/systemd/system/nginx.service
    systemctl daemon-reload
    echo "卸载nginx完成"
    elf [ ! -z $NGINX_HOME ];then
    rm -rf $NGINX_HOME
    sed -i '$NGINX_HOME/d' /etc/profile
    [ -f /etc/init.d/nginx ] && sudo rm -f /etc/init.d/nginx
    systemctl disable nginx.service &>/dev/null
    [ -f /usr/lib/systemd/system/nginx.service ] && sudo rm -rf /usr/lib/systemd/system/nginx.service
    systemctl daemon-reload
    echo "卸载nginx完成"
    fi
else
    printf "获取Nginx安装路径："
        echo $NGINX_HOME
        if [ -z $NGINX_HOME ]; then
            command -v nginx
           if [ `command -v nginx` ==  /usr/sbin/nginx ];then
            $controls remove -y nginx
            $controls autoremove -y nginx
           fi
        [ -f /etc/init.d/nginx ] && sudo rm -f /etc/init.d/nginx
        systemctl disable nginx.service &>/dev/null
        [ -f /usr/lib/systemd/system/nginx.service ] && sudo rm -rf /usr/lib/systemd/system/nginx.service
        systemctl daemon-reload
        echo "卸载nginx完成"
        elf [ ! -z $NGINX_HOME ];then
        rm -rf $NGINX_HOME
        sed -i '$NGINX_HOME/d' /etc/profile
        [ -f /etc/init.d/nginx ] && sudo rm -f /etc/init.d/nginx
        systemctl disable nginx.service &>/dev/null
        [ -f /usr/lib/systemd/system/nginx.service ] && sudo rm -rf /usr/lib/systemd/system/nginx.service
        systemctl daemon-reload
        echo "卸载nginx完成"
        fi
fi
