#!/bin/bash

config_path=/tools/
config_file=/tools/config.xml
if [ -f /usr/local/bin/docker-compose ];then
   mv /usr/local/bin/docker-compose /usr/local/bin/"$time"_bak
fi
bash <(curl -sl https://"$url_address"/HiddenScholars/Linux-tools/"$con_branch"/Check/Check.sh) PACKAGE_DOWNLOAD  docker-compose  $(for i in "${docker_compose_download_urls[@]}";do printf "%s " "$i";done)
download_path=$(awk -v RS="</paths>" '/<paths>/{gsub(/.*<paths>[\r\n\t ]*|[\r\n\t ]*$/,"");print}' $config_file | awk -F'[><]' '/<download_path>/{print $3}')
  if $(cp -rf "$download_path"/docker-compose/docker-compose /usr/local/bin/);then
    echo "复制完成"
    sudo chmod +x /usr/local/bin/docker-compose && echo "增加执行权限完成"
  else
    printf "复制失败\n安装失败\n"
  fi


