#!/bin/bash
#create time 2022/4/21
DIR=`cd "$(dirname "$0")" && pwd`
source /etc/profile
a=`dirname $NGINX_HOME`
{
    echo "nginx卸载开始"
    for apid in $(ps -ef|grep nginx|grep -v grep|awk '{print $2}')
    do
        kill -9 $apid
    done
    userdel -r nginx
    [ -d "$a/nginx/" ] && sudo rm -rf $a/nginx*
    [ -f /etc/init.d/nginx ] && sudo rm -f /etc/init.d/nginx
	systemctl disable nginx.service &>/dev/null
	[ -f /usr/lib/systemd/system/nginx.service ] && sudo rm -rf /usr/lib/systemd/system/nginx.service
    sudo rm -rf $a/nginx/*
	sudo rm -rf $DIR/logs/*
    echo "卸载nginx完成"
}
