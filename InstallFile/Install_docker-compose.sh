#!/bin/bash

source /tools/config.sh

case $(uname -m) in
x86_64)
  case $1 in
  2.23.3)
  wget -P /usr/local/bin/ $docker_compose_downlaod_url_1
  cd /usr/local/bin/  && mv docker-compose-linux-x86_64 docker-compose && chmod +x docker-compose
  ;;
  *)
    echo "暂时不支持的版本"
  esac
;;
*)
  echo "暂时不支持`uname -m`架构"
  ;;
esac
read -p "回车后返回主菜单："
