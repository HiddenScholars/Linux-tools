#!/bin/bash

red='\033[31m'
green='\033[32m'
yellow='\033[33m'
plain='\033[0m'

function Version(){
serverVersion=`awk -F= '/^NAME/{print $2}' /etc/os-release`
if [  "$serverVersion" == '"CentOS Linux"' ];then
echo "CentOS"
elif [ "$serverVersion" == '"Ubuntu"' ];then
echo "Ubuntu"
else
echo $serverVersion
fi
}

function Controls() {
controls=
if [ $Version == "CentOS" ];then
  echo $Version
  controls='yum'
elif [ $Version == "Ubuntu" ];then
  echo $Version
  controls='apt'
else
  controls='apt'
  read -p  "$Version,无法识别默认使用apt进行安装是否继续（y/n）:" select1
  [ $select == "n" ] && exit 0
fi 
}


echo -e "${green}0. 软件安装.${plain}"

read -p "输入序号【0】：" select2
case $select2 in
0)
echo -e "check system..."
Controls
  ;;
esac