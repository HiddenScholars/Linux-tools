#!/bin/bash


read -p "回车后确认卸载："


source /etc/profile
source /tools/config.sh
if [ `ps -ef | grep nginx | grep -v grep | awk '{print $2}' | wc -l ` != 0 ]; then
    echo "检测到Nginx进程，进程ID：`ps -ef | grep nginx | grep -v grep | awk '{print $2}'`"
    killall_select=1
    while [ $killall_select -lt 4 ]; do
      echo "开始kill Nginx进程 $killall_select"
        if [ `ps -ef | grep nginx | grep -v grep | awk '{print $2}' | wc -l ` != 0 ]; then
        for i in `ps -ef | grep nginx | grep -v grep | awk '{print $2}'`
            do
              kill -9 $i
            done
        fi
        sleep 2
        let killall_select++
    done
    [ `ps -ef | grep nginx | grep -v grep | awk '{print $2}' | wc -l ` != 0 ] && echo "Nginx进程杀死失败，退出..." && exit 0
printf "获取Nginx安装路径："
    echo $NGINX_HOME
    if [ -z $NGINX_HOME ]; then
        command -v nginx
    if [ "$(command -v nginx)" == " "  ]; then
       if [ "$(command -v nginx)" == "/usr/sbin/nginx" ];then
        $controls remove -y nginx
        $controls autoremove -y nginx
        source /etc/profile
       fi
    [ -f /etc/init.d/nginx ] && sudo rm -f /etc/init.d/nginx
    systemctl disable nginx.service &>/dev/null
    [ -f /usr/lib/systemd/system/nginx.service ] && sudo rm -rf /usr/lib/systemd/system/nginx.service
    systemctl daemon-reload
    echo "卸载nginx完成"
    elif [ ! -z $NGINX_HOME ];then
    rm -rf $NGINX_HOME
    sed -i "/NGINX/d" /etc/profile
    sed -i "/nginx/d" /etc/profile
    source /etc/profile
    if [ "$(command -v nginx)" == "/usr/sbin/nginx" ]; then
        $controls remove -y nginx
        $controls autoremove -y nginx
        source /etc/profile
    fi
    [ -f /etc/init.d/nginx ] && sudo rm -f /etc/init.d/nginx
    systemctl disable nginx.service &>/dev/null
    [ -f /usr/lib/systemd/system/nginx.service ] && sudo rm -rf /usr/lib/systemd/system/nginx.service
    systemctl daemon-reload
    echo "卸载nginx完成"
    else
        echo "未获取到Nginx路径"
    fi
    fi
elif [ ! -z $NGINX_HOME ] || [ ! -z $(command -v nginx) ]; then
    printf "获取Nginx安装路径："
    echo $NGINX_HOME
    if [ -z $NGINX_HOME ]; then
        command -v nginx
    if [ "$(command -v nginx)" == " "  ]; then
       if [ "$(command -v nginx)" == "/usr/sbin/nginx" ];then
        $controls remove -y nginx
        $controls autoremove -y nginx
        source /etc/profile
       fi
    [ -f /etc/init.d/nginx ] && sudo rm -f /etc/init.d/nginx
    systemctl disable nginx.service &>/dev/null
    [ -f /usr/lib/systemd/system/nginx.service ] && sudo rm -rf /usr/lib/systemd/system/nginx.service
    systemctl daemon-reload
    echo "卸载nginx完成"
    elif [ ! -z $NGINX_HOME ];then
    rm -rf $NGINX_HOME
    sed -i "/NGINX/d" /etc/profile
    sed -i "/nginx/d" /etc/profile
    source /etc/profile
    if [ "$(command -v nginx)" == "/usr/sbin/nginx" ]; then
        $controls remove -y nginx
        $controls autoremove -y nginx
        source /etc/profile
    fi
    [ -f /etc/init.d/nginx ] && sudo rm -f /etc/init.d/nginx
    systemctl disable nginx.service &>/dev/null
    [ -f /usr/lib/systemd/system/nginx.service ] && sudo rm -rf /usr/lib/systemd/system/nginx.service
    systemctl daemon-reload
    echo "卸载nginx完成"
    else
        echo "未获取到Nginx路径"
    fi
    fi
else
  echo "未检测到Nginx安装信息"
fi
