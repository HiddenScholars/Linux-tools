#!/bin/bash

config_path=/tools/
config_file=/tools/config.xml
con_branch=$(awk -v RS="</parameters>" '/<parameters>/{gsub(/.*<parameters>[\r\n\t ]*|[\r\n\t ]*$/,"");print}' $config_file | awk -F'[><]' '/<con_branch>/{print $3}')
url_address=$(awk -v RS="</parameters>" '/<parameters>/{gsub(/.*<parameters>[\r\n\t ]*|[\r\n\t ]*$/,"");print}' $config_file | awk -F'[><]' '/<url_address>/{print $3}')
download_path=$(awk -v RS="</paths>" '/<paths>/{gsub(/.*<paths>[\r\n\t ]*|[\r\n\t ]*$/,"");print}' $config_file | awk -F'[><]' '/<download_path>/{print $3}')
docker_compose_download_urls=($(awk '/<download_urls>/,/<\/download_urls>/' $config_file | awk '/<docker_compose_download_urls>/,/<\/docker_compose_download_urls>/' | awk -F '[<>]' '/<url>/{print $3}'))

if [ -f /usr/local/bin/docker-compose ];then
   mv /usr/local/bin/docker-compose /usr/local/bin/"$time"_bak
fi
bash <(curl -sl https://"$url_address"/HiddenScholars/Linux-tools/"$con_branch"/Check/Check.sh) PACKAGE_DOWNLOAD  docker-compose  $(for i in "${docker_compose_download_urls[@]}";do printf "%s " "$i";done)
  if $(cp -rf "$download_path"/docker-compose/docker-compose /usr/local/bin/);then
    echo "复制完成"
    sudo chmod +x /usr/local/bin/docker-compose && echo "增加执行权限完成"
  else
    printf "复制失败\n安装失败\n"
  fi


