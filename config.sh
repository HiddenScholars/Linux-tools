#!/bin/bash


#统一配置变量，不清楚原理保持默认
#安装包下载路径，例如下载nginx，nginx安装包路径：$download_path/nginx/
download_path=/tools/soft
#注：这里为所有安装软件的统一路径，任何软件都会以软件名在这个路径下创建路径安装，路径重复根据软件情况通过date +%Y%m%d进行备份
install_path=/usr/local/soft
time=`date +%Y%m%d`

#服务安装配置
nginx_download_url_1=https://nginx.org/download/nginx-1.24.0.tar.gz
nginx_user=nginx
docker_download_url_1=https://download.docker.com/linux/static/stable/x86_64/docker-23.0.6.tgz



#输出颜色
red='\033[31m'
green='\033[32m'
yellow='\033[33m'
plain='\033[0m'


# 检测操作系统类型和版本信息
os_type=$(uname -s)
serverVersion=
serverVersion=`awk -F= '/^NAME/{print $2}' /etc/os-release`
if [  "$serverVersion" == '"CentOS Linux"' ];then
release="centos"
elif [ "$serverVersion" == '"Ubuntu"' ];then
release="ubuntu"
else
echo -e  "${red}警告：暂时未适配$serverVersion，自行决定是否安装！！！\n${plain}"
read -p "回车后继续安装："
fi
# 输出系统信息
echo "操作系统类型: $os_type"
echo "操作系统发行版本: $serverVersion"
# 检测常用软件包管理器
if command -v apt-get &> /dev/null; then
    echo "已安装：apt-get (Debian/Ubuntu)"
    controls='apt'
elif command -v yum &> /dev/null; then
    echo "已安装：yum (CentOS/RHEL)"
    controls='yum'
elif command -v dnf &> /dev/null; then
    echo "已安装：dnf (Fedora) && echo "未适配的软件管理器" && exit 0"
elif command -v zypper &> /dev/null; then
    echo "已安装：zypper (openSUSE) && echo "未适配的软件管理器" && exit 0"
elif command -v pacman &> /dev/null; then
    echo "已安装：pacman (Arch Linux) && echo "未适配的软件管理器" && exit 0"
else
    echo "未知的软件包管理器"
    exit 0
fi

