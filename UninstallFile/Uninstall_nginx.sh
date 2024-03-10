#!/bin/bash

read -rp "回车后确认卸载："
set -x
source /etc/profile
source /tools/config
getNginxProcess_number1=$(ps aux | grep -v grep | grep -v  "$0" | grep nginx | wc -l)
if [ "$getNginxProcess_number1" != 0 ]; then
    echo "检测到Nginx进程，进程ID："
    ps aux | grep -v grep | grep -v "$0" | grep nginx
    killall_select=1
    while [ $killall_select -lt 4 ]; do
      echo "开始kill Nginx进程 $killall_select"
      getNginxProcess_number2=$(ps aux | grep -v grep | grep -v "$0" | grep nginx | wc -l)
        if [ "$getNginxProcess_number2" != 0 ]; then
        for i in $(ps aux | grep -v grep | grep -v "$0" | grep nginx)
            do
              kill -9 "$i"
            done
        fi
        sleep 2
        let killall_select++
    done
    getNginxProcess_number3=$(ps aux | grep -v grep | grep -v "$0" | grep nginx | wc -l)
    [ "$getNginxProcess_number3" != 0 ] && echo "Nginx进程杀死失败，退出..." && exit 0
printf "获取Nginx安装路径："
        if [ -z "$NGINX_HOME" ]; then
          source /etc/profile
            command -v nginx
           if [ "$(command -v nginx)" == "/usr/sbin/nginx" ];then
            $controls remove -y nginx
            $controls autoremove -y nginx
            source /etc/profile
          elif [ -h "$(command -v nginx)" ]; then
              temp_command=$(command -v nginx)
             if [ -n  "$temp_command" ];then
                link_path=$(readlink -f "$temp_command")
              echo "$(command -v nginx)为软连接"
              echo "获取源路径为：$link_path"
              rm -rf "$link_path"
              rm -rf "$(command -v nginx)"
              source /etc/profile
             fi
          fi
        [ -f /etc/init.d/nginx ] &&  rm -f /etc/init.d/nginx
        systemctl disable nginx.service &>/dev/null
        [ -f /usr/lib/systemd/system/nginx.service ] &&  rm -rf /usr/lib/systemd/system/nginx.service
        [ -f /etc/systemd/system/nginx.service ] &&  rm -rf /etc/systemd/system/nginx.service
        systemctl daemon-reload
        echo
        echo "卸载Nginx完成"

        elif [ -n "$NGINX_HOME" ];then
        source /etc/profile
        echo "$NGINX_HOME"
        rm -rf "$NGINX_HOME"
        sed -i "/NGINX/d" /etc/profile
        sed -i "/nginx/d" /etc/profile
        source /etc/profile
        if [ "$(command -v nginx)" == "/usr/sbin/nginx" ]; then
            $controls remove -y nginx
            $controls autoremove -y nginx
            source /etc/profile
        elif [ -h "$(command -v nginx)" ]; then
            temp_command=$(command -v nginx)
            if [ -n  "$temp_command" ];then
            link_path=$(readlink -f "$temp_command")
            echo "$(command -v nginx)为软连接"
            echo "获取源路径为：$link_path"
            rm -rf "$link_path"
            rm -rf "$(command -v nginx)"
            source /etc/profile
            fi
        fi
        [ -f /etc/init.d/nginx ] &&  rm -f /etc/init.d/nginx
        systemctl disable nginx.service &>/dev/null
        [ -f /usr/lib/systemd/system/nginx.service ] &&  rm -rf /usr/lib/systemd/system/nginx.service
        [ -f /etc/systemd/system/nginx.service ] &&  rm -rf /etc/systemd/system/nginx.service
        systemctl daemon-reload
        echo
        echo "卸载Nginx完成"
        fi
elif [ -n "$NGINX_HOME" ] || [  "$(command -v nginx)" != " " ]; then
    printf "获取Nginx安装路径："
        if [ -z "$NGINX_HOME" ]; then
          source /etc/profile
            command -v nginx
           if [ "$(command -v nginx)" == "/usr/sbin/nginx" ];then
            $controls remove -y nginx
            $controls autoremove -y nginx
            source /etc/profile
          elif [ -h "$(command -v nginx)" ]; then
              temp_command=$(command -v nginx)
             if [ -n "$temp_command" ];then
                link_path=$(readlink -f "$temp_command")
              echo "$(command -v nginx)为软连接"
              echo "获取源路径为：$link_path"
              rm -rf "$link_path"
              rm -rf "$(command -v nginx)"
              source /etc/profile
             fi
          fi
        [ -f /etc/init.d/nginx ] && rm -f /etc/init.d/nginx
        systemctl disable nginx.service &>/dev/null
        [ -f /usr/lib/systemd/system/nginx.service ] &&  rm -rf /usr/lib/systemd/system/nginx.service
        [ -f /etc/systemd/system/nginx.service ] && rm -rf /etc/systemd/system/nginx.service
        systemctl daemon-reload
        echo
        echo "卸载Nginx完成"

        elif [ -n "$NGINX_HOME" ];then
        source /etc/profile
        echo "$NGINX_HOME"
        rm -rf "$NGINX_HOME"
        sed -i "/NGINX/d" /etc/profile
        sed -i "/nginx/d" /etc/profile
        source /etc/profile
        if [ "$(command -v nginx)" == "/usr/sbin/nginx" ]; then
            $controls remove -y nginx
            $controls autoremove -y nginx
            source /etc/profile
        elif [ -h "$(command -v nginx)" ]; then
            temp_command=$(command -v nginx)
            if [ -n "$temp_command" ];then
            link_path=$(readlink -f "$temp_command")
            echo "$(command -v nginx)为软连接"
            echo "获取源路径为：$link_path"
            rm -rf "$link_path"
            rm -rf "$(command -v nginx)"
            source /etc/profile
            fi
        fi
        [ -f /etc/init.d/nginx ] && rm -f /etc/init.d/nginx
        systemctl disable nginx.service &>/dev/null
        [ -f /usr/lib/systemd/system/nginx.service ] && rm -rf /usr/lib/systemd/system/nginx.service
        [ -f /etc/systemd/system/nginx.service ] &&  rm -rf /etc/systemd/system/nginx.service
        systemctl daemon-reload
        echo
        echo "卸载Nginx完成"
        fi
else
  echo "未检测到Nginx安装信息"
fi
