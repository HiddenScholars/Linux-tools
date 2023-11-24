#!/bin/bash

#统一配置变量，不清楚原理保持默认
#安装包下载路径，例如下载nginx，nginx安装包路径：$download_path/nginx/
download_path=/tools/soft
#注：这里为所有安装软件的统一路径，任何软件都会以软件名在这个路径下创建路径安装，路径重复根据date +%Y%m%d进行备份
install_path=/usr/local/soft
time=`date +%Y%m%d`
nginx_download_url_1=https://nginx.org/download/nginx-1.24.0.tar.gz
nginx_user=nginx
docker_download_url_1=https://download.docker.com/linux/static/stable/x86_64/docker-23.0.6.tgz

