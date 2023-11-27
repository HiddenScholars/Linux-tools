#!/bin/bash

source /tools/config.sh

if [ -f /usr/local/bin/docker-compose ];then
    docker-compose -v &>/dev/null
    if [ $? -ne 0 ];then
      mv /usr/local/bin/docker-compose /usr/local/bin/$time
    else
    read -p "docker-compose已存在回车后继续安装,(原文件将会被备份)："
      mv /usr/local/bin/docker-compose /usr/local/bin/$time
    fi

fi


case $(uname -m) in
x86_64)
  case $1 in
  2.23.3)
  wget -P /usr/local/bin/ $docker_compose_downlaod_url_1
  cd /usr/local/bin/  && mv docker-compose-linux-x86_64 docker-compose && chmod +x docker-compose
  command -v docker-compose &>/dev/null
  [ $? -ne 0 ] && echo "export PATH=$PATH:/usr/local/bin/" >>/etc/profile
  ;;
  *)
    echo "暂时不支持的版本"
  ;;
  esac
;;
*)
  echo "暂时不支持`uname -m`架构"
  ;;
esac
read -p "回车后返回主菜单："
