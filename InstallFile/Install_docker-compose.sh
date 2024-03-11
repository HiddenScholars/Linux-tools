#!/bin/bash
red=$(curl -sl https://"$url_address"/HiddenScholars/Linux-tools/"$con_branch"/Check/Check.sh | bash -s -- COLOR red)
green=$(curl -sl https://"$url_address"/HiddenScholars/Linux-tools/"$con_branch"/Check/Check.sh | bash -s -- COLOR green)
plain=$(curl -sl https://"$url_address"/HiddenScholars/Linux-tools/"$con_branch"/Check/Check.sh | bash -s -- COLOR plain)
source /tools/config

if [ -f /usr/local/bin/docker-compose ];then
   mv /usr/local/bin/docker-compose /usr/local/bin/"$time"_bak
fi
echo -e "${red} 注意：请选择与机型相匹配的架构安装包当前架构：`uname -m`${plain}"
bash <(curl -sl https://"$url_address"/HiddenScholars/Linux-tools/"$con_branch"/Check/Check.sh) PACKAGE_DOWNLOAD  docker-compose  $(for i in "${docker_compose_download_urls[@]}";do printf "$i ";done)

if $(cp -rf "$download_path"/docker-compose/docker-compose /usr/local/bin/);then
  chown +x /usr/local/bin/docker-compose
fi

if $(docker-compose -v) &>/dev/null; then
   echo -e "${green}docker_compose安装完成${plain}"
else
   echo "${green}docker_compose安装失败${plain}'"
fi
