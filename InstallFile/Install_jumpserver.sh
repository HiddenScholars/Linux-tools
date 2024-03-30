#!/bin/bash

source /tools/config
if [ "$country" == "CN" ]; then
   curl -sSL https://resource.fit2cloud.com/jumpserver/jumpserver/releases/latest/download/quick_start.sh | bash
else
   curl -sSL https://github.com/jumpserver/jumpserver/releases/latest/download/quick_start.sh | bash
fi
edit_config_txt=''
read -rp "修改config.txt文件（y/n）：" edit_config_txt
if [ "$edit_config_txt" == "y" ]; then
    edit_config_txt_DOMAIN=''
    edit_config_txt_HTTPS=''
    config_path=/opt/jumpserver/config/config.txt
    read -rp "定义可信任的访问 IP, 请根据实际情况修改, 如果是公网 IP 请改成对应的公网 IP（default: null）：" edit_config_txt_DOMAIN
    [ -n "$edit_config_txt_DOMAIN" ] && sed -i "s/DOMAIN=.*/DOMAIN=$edit_config_txt_DOMAIN/g" $config_path
    read -rp "开启HTTPS访问（default：不设置）：" edit_config_txt_HTTPS
    if [ -n "$edit_config_txt_HTTPS" ];then
      sed -i "s/#HTTPS_PORT=.*/HTTPS_PORT=443/g" $config_path
      sed -i "s/#SERVER_NAME=.*/SERVER_NAME=$edit_config_txt_DOMAIN/g" $config_path
      if [ -f /opt/jumpserver/nginx/cert/server.crt ]; then
          sed -i "s/#SSL_CERTIFICATE=.*/SSL_CERTIFICATE=/opt/jumpserver/nginx/cert/server.crt/g" $config_path
      else
         echo "server.crt not found"
      fi
      if [ -f /opt/jumpserver/nginx/cert/server.key ]; then
         sed -i "s/#SSL_CERTIFICATE_KEY=.*/SSL_CERTIFICATE_KEY=/opt/jumpserver/nginx/cert/server.key/g" $config_path
      else
         echo "server.key not found"
      fi

    fi

fi