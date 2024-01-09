#!/bin/bash

read -p "回车后即确认升(降)级："
source /etc/profile
source /tools/config.sh
select=''
sbin_nginx=''

if [ `ps -ef | grep nginx | grep -v grep | awk '{print $2}' | wc -l ` != 0 ]; then
  #检测Nginx路径
  nginx_path=$(ps -ef | grep "nginx: master process" | awk '{print $11}' | awk 'NR==1')
  if [ ! -z $nginx_path ] && [ -f $nginx_path ];then
    sbin_nginx=$nginx_path
  else
    read -p  "自动识别Nginx路径失败，手动输入nginx程序所在路径，例如：/usr/local/soft/nginx/sbin/nginx ：" select
    for (( i = 0; i < 2; i++ )); do
        if [ -f $select  ]; then
            sbin_nginx=$select
            let i++
        fi
        select=''
        read -p "nginx程序不存在重新输入：" select
    done
    [ ! -f $select ] && echo "${red}路径不存在${plain}" && exit 0
  fi
echo -e "${green}=================升级前检测====================${plain}"
$sbin_nginx -v
$sbin_nginx -V
$sbin_nginx -t
if [ $? -eq 0 ];then
  echo "开始备份"
cd $(dirname ${sbin_nginx}) && mv nginx nginx$(date +%F-%M)
  echo "备份完成"
else
  echo "升级前检测不通过" && exit 0
fi
echo -e "${green}=================升级前检测====================${plain}"
[ ! -f $download_path/nginx/$1 ] && echo -e "${red}服务包不存在${plain}" && exit 0
echo "解压中...."
tar xf $download_path/nginx/$1 -C /tools/unpack_file/$2 --strip-components 1
echo "解压完成，开始编译"
read -p "是否增加编译参数，增加编译参数直接将编译模块写到后面，无编译参数直接回车：" select_cofigure
cd /tools/unpack_file/$2 && ./configure $(${sbin_nginx} -V > /tmp/1.txt 2>&1  | cat /tmp/1.txt |   grep prefix | awk '{print substr($0, index($0,$3))}')  ${select_cofigure} && make && rm -rf /tmp/1.txt
[ $? -ne 0 ] && echo -e "${red}编译失败${plain}" && exit 0
if [ -f /tools/unpack_file/$2/objs/nginx ]; then
 cp -r /tools/unpack_file/$2/objs/nginx $(dirname ${sbin_nginx})
 kill -USR2 $($(dirname ${sbin_nginx})../logs/nginx.pid)
 kill -WINCH $($(dirname ${sbin_nginx})../logs/nginx.pid.oldbin)
 kill -QUIT $($(dirname ${sbin_nginx})../logs/nginx.pid.oldbin)
 echo -e "${green}=================升级后检测====================${plain}"
 $sbin_nginx -v
 $sbin_nginx -V
 $sbin_nginx -t
 if [ $? -eq 0 ] && [ `ps -ef | grep nginx | wc -l ` -gt 1 ];then
   echo -e "${green}升级成功${plain}"
 else
   echo -e "${red}升级失败${plain}"
 fi
 echo -e "${green}=================升级后检测====================${plain}"
fi

else
  echo "${red} Nginx进程不存在无法进行平滑升（降）级，检测Nginx状态后再试${plain}" && exit 0
fi

