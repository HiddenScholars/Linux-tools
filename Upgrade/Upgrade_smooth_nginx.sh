#!/bin/bash

read -rp "回车后即确认升(降)级："
source /etc/profile
config_path=/tools/
config_file=/tools/config.xml
con_branch=$(awk -v RS="</parameters>" '/<parameters>/{gsub(/.*<parameters>[\r\n\t ]*|[\r\n\t ]*$/,"");print}' $config_file | awk -F'[><]' '/<con_branch>/{print $3}')
url_address=$(awk -v RS="</parameters>" '/<parameters>/{gsub(/.*<parameters>[\r\n\t ]*|[\r\n\t ]*$/,"");print}' $config_file | awk -F'[><]' '/<url_address>/{print $3}')
download_path=$(awk -v RS="</paths>" '/<paths>/{gsub(/.*<paths>[\r\n\t ]*|[\r\n\t ]*$/,"");print}' $config_file | awk -F'[><]' '/<download_path>/{print $3}')
red=$(curl -sl https://"$url_address"/HiddenScholars/Linux-tools/"$con_branch"/Check/Check.sh | bash -s -- COLOR red)
plain=$(curl -sl https://"$url_address"/HiddenScholars/Linux-tools/"$con_branch"/Check/Check.sh | bash -s -- COLOR plain)
select=''
sbin_nginx=''
getNginxProcessNumber=$(pgrep nginx | wc -l)
if [ "$getNginxProcessNumber" -ne 0 ]; then
  #检测Nginx路径
  nginx_path=$(pgrep -a nginx | awk '{print $5}' | awk "NR==1")
  if [ -n "$nginx_path" ] && [ -f "$nginx_path" ];then
    sbin_nginx=$nginx_path
  else
    read -rp  "自动识别Nginx路径失败，手动输入nginx程序所在路径，例如：/usr/local/soft/nginx/sbin/nginx ：" select
    for (( i = 0; i < 2; i++ )); do
        if [ -n "$select" ] && [ -f "$select"  ]; then
            sbin_nginx=$select
            let i++
        fi
        select=''
        read -rp "nginx程序不存在重新输入：" select
    done
     [ -z "$select" ] || [ ! -f "$select" ] && echo -e "${red}文件不存在${plain}" && exit 0
  fi
echo -e "${green}=================升级前检测====================${plain}"
$sbin_nginx -v
$sbin_nginx -V
$sbin_nginx -t
if [ $? -eq 0 ];then
  echo "开始备份"
cd "$(dirname "${sbin_nginx}")" && mv nginx nginx"$(time)"
  echo "备份完成"
else
  echo "升级前检测不通过" && exit 0
fi
echo -e "${green}=================升级前检测====================${plain}"
[ ! -f "$download_path"/nginx/"$1" ] && echo -e "${red}服务包不存在${plain}" && exit 0
echo "解压中...."
tar xf "$download_path"/nginx/"$1" -C /tools/unpack_file/"$2" --strip-components 1
echo "解压完成，开始编译"
read -rp "是否增加编译参数，增加编译参数直接将编译模块写到后面，无编译参数直接回车：" select_cofigure
cd /tools/unpack_file/"$2" && ./configure "$(${sbin_nginx} -V > /tools/1.txt 2>&1
cat /tools/1.txt | grep prefix | awk '{print substr($0, index($0,$3))}')"  "$select_cofigure" && make && rm -rf /tools/1.txt
 [ $? -ne 0 ] && echo -e "${red}编译失败${plain}" && exit 0
if [ -f /tools/unpack_file/"$2"/objs/nginx ]; then
 cp -r /tools/unpack_file/"$2"/objs/nginx "$(dirname "$sbin_nginx")"
 sleep 10
 set -
 kill -USR2  "$("$(dirname "$sbin_nginx")"/../logs/nginx.pid)"
 kill -WINCH "$("$(dirname "$sbin_nginx")"/../logs/nginx.pid.oldbin)"
 kill -QUIT  "$("$(dirname "$sbin_nginx")"/../logs/nginx.pid.oldbin)"
 set +x
 $sbin_nginx -v
 $sbin_nginx -V
 $sbin_nginx -t
 getNginxProcessNumber_gt=$(pgrep nginx | wc -l )
 if [ $? -eq 0 ] && [ "$getNginxProcessNumber_gt" -gt 1 ];then
   echo -e "${green}升级成功${plain}"
 else
   echo -e "${red}升级失败${plain}"
 fi
 echo -e "${green}=================升级后检测====================${plain}"
fi

else
  echo "${red} Nginx进程不存在无法进行平滑升（降）级，检测Nginx状态后再试${plain}" && exit 0
fi

