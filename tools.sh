#!/bin/bash

red='\033[31m'
green='\033[32m'
yellow='\033[33m'
plain='\033[0m'

#统一配置变量，不清楚原理保持默认
#安装包下载路径，例如下载nginx，nginx安装包路径：$download_path/nginx/
download_path=/tools/soft
#注：这里为所有安装软件的统一路径，任何软件都会以软件名在这个路径下创建路径安装，路径重复根据date +%Y%m%d进行备份
install_path=/usr/local/soft
time=`date +%Y%m%d`
#获取当前文件所在路径
DIR=`cd "$(dirname "$0")" && pwd`


#服务配置变量
#Nginx start
nginx_download_url=
nginx_download_url_1=https://nginx.org/download/nginx-1.24.0.tar.gz
#程序用户，无法登陆
nginx_user=nginx
#Docker
docker_download_url=
docker_download_url_1=https://download.docker.com/linux/static/stable/x86_64/docker-23.0.6.tgz

#check systemctl version
if [[ -f /etc/redhat-release ]]; then
    release="centos"
elif cat /etc/issue | grep -Eqi "debian"; then
    release="debian"
elif cat /etc/issue | grep -Eqi "ubuntu"; then
    release="ubuntu"
elif cat /etc/issue | grep -Eqi "centos|red hat|redhat"; then
    release="centos"
elif cat /proc/version | grep -Eqi "debian"; then
    release="debian"
elif cat /proc/version | grep -Eqi "ubuntu"; then
    release="ubuntu"
elif cat /proc/version | grep -Eqi "centos|red hat|redhat"; then
    release="centos"
else
    echo -e  "${red}未检测到系统版本，请联系脚本作者！\n${plain}" && exit 1
fi
# select erector
controls=''
if [ "$release" == "centos" ];then
  controls='yum'
elif [ "$release" == "ubuntu" ];then
  controls='apt'
elif [ "$release" == "debian" ]; then
  controls='apt'
else
  controls='apt'
fi


function manage_download() {
  #server_name下载服务名
  #download_url下载链接
  [ -z $server_name ] && echo -e "$red 禁止server_name为空使用 $plain" && exit
  [ -z $download_url ] && echo -e "$red 禁止download_url为使用 $plain" && exit
  [ ! -d $download_path/docker ] &&  mkdir $download_path/docker
          if [ `ls $download_path/$server_name/ | wc -l` -ne 0 ];then
                echo -e "${red}$download_path/$server_name/中存在文件${plain}"
                echo
                echo
               cd $download_path/$server_name/
                    # 定义一个空数组用于存储符合条件的文件
                    files=()

                    # 获取目录下所有文件，并将符合条件的文件添加到数组中
                    for file in *; do
                      # 过滤文件的条件，可以根据需求进行修改
                      if [[ ! "$file" =~ ^\..* ]]; then
                        files+=("$file")
                      fi
                    done

                    # 对数组进行排序，并打印文件名和数字序号
                    IFS=$'\n' sorted_files=($(sort <<<"${files[*]}"))
                    for i in ${!sorted_files[@]}; do
                      echo -e "${green}$((i)):${sorted_files[$i]}${plain}"
                    done
                read -p  "文件夹中存在文件是否继续下载（y/n）(default：n)：" download_select

                if [ "$download_select" == "y" ]; then
                      wget -P $download_path/docker/ $download_url
                      cd $download_path/$server_name/
                      # 定义一个空数组用于存储符合条件的文件
                      files=()

                      # 获取目录下所有文件，并将符合条件的文件添加到数组中
                      for file in *; do
                        # 过滤文件的条件，可以根据您的需求进行修改
                        if [[ ! "$file" =~ ^\..* ]]; then
                          files+=("$file")
                        fi
                      done

                      # 对数组进行排序，并打印文件名和数字序号
                      IFS=$'\n' sorted_files=($(sort <<<"${files[*]}"))
                      for i in ${!sorted_files[@]}; do
                        echo -e "${green}$((i)):${sorted_files[$i]}${plain}"
                      done
                      #标记执行过下载安装包命令
                      if_select=0
                else
                      #标记不执行
                      if_select=1
                fi
              fi
              if [ "$if_select" != 1 ] && [ "$if_select" != 0 ]; then
                wget -P $download_path/$server_name/ $download_url
                cd $download_path/$server_name/
                # 定义一个空数组用于存储符合条件的文件
                files=()

                # 获取目录下所有文件，并将符合条件的文件添加到数组中
                for file in *; do
                  # 过滤文件的条件，可以根据您的需求进行修改
                  if [[ ! "$file" =~ ^\..* ]]; then
                    files+=("$file")
                  fi
                done

                # 对数组进行排序，并打印文件名和数字序号
                IFS=$'\n' sorted_files=($(sort <<<"${files[*]}"))
                for i in ${!sorted_files[@]}; do
                  echo -e "${green}$((i)):${sorted_files[$i]}${plain}"
                done
              fi

              echo ""
              echo ""
              read -p "选择安装包序号：" select
              if [ -z $select ]; then
                  echo -e "${red}未选择安装包，退出脚本${plain}"
                  exit 0
              fi
}

function check_install_system() {
    [ -z $test_server_port ] && [ -z $process ] && echo -e "$red test_server_port与process禁止为空使用 $plain" && exit
    #test_server_port=() 检查此数组中的端口
    netstat -ntpl|grep LISTEN|awk '{print $4}' >/opt/test_sys.txt
    #process=(nginx) 检查此数组中的进程
        num=0
        for line in `cat /opt/test_sys.txt`
        do
            sys_port=${line##*:}
            for i in ${test_server_port[*]}
            do
                if [ $sys_port -eq $i ];then
                    echo -e "\033[31m $sys_port端口已存在，占用服务端口 \033[0m"
                    let  num=$num+1
                fi
            done
        done
        u=0
        if [ $num -eq 0 ]
        then
            for pro in ${process[@]}
            do
                if [ `ps -ef|grep $pro |grep -v "grep"|wc -l` -ne 0 ]
                then
                    echo "$pro有残余进程，删除后再次执行脚本检测安装环境"
    				exit 1
                    let  u=$u+1
                fi
            done
            for pro in ${PRODUCT_ORDER[@]}
            do
                if [ `ps -ef|grep $pro |grep -v "grep"|wc -l` -ne 0 ]
                then
                    echo "服务有残余进程，删除后再次执行脚本检测安装环境"
                    let  u=$u+1
                fi
            done
        else
          select=''
          read -p "是否继续安装，继续安装可能会无法启动（y/n）:" select
            if [ "$select" != "y" ]; then
            exit 1
            fi
        fi
} #check_install_nginx_system
function install_nginx() {
    download_select=''
    if_select=''
    $controls install -y wget curl net-tools
    if [ $? -ne 0 ];then
      echo -e "${red}安装失败${plain}" && exit 0
    fi
server_name=nginx
download_url=nginx_download_url
manage_download
echo "开始安装Nginx--链接Github获取Nginx安装脚本"
bash <(curl -L https://raw.githubusercontent.com/LGF-LGF/tools/main/InstallFile/Install_nginx.sh)
read -p "按回车键返回主菜单："
} #install_nginx

function setting_ssl() {
echo "开始安装证书--链接Github获取证书安装脚本"
bash <(curl -L https://raw.githubusercontent.com/LGF-LGF/tools/main/InstallFile/Install_ssl_acme.sh)
}

function install_docker() {
  process=(docker)
  check_install_system
  case $select in
        1)
        docker_download_url=$docker_download_url_1
        ;;
        *)
          echo "暂无此版本."
          exit 0
        ;;
  esac
        #manager_download_END
        server_name=docker
        download_url=$docker_download_url
        manage_download
        #manager_download_END
  echo "开始安装Docker--链接github获取Docker安装脚本"
  #写入临时变量
  echo "export download_path=$download_path" >$download_path/config_docker
  echo "export docker_file=${sorted_files[$select]} >$download_path/config_docker

  bash <(curl -L https://raw.githubusercontent.com/LGF-LGF/tools/main/InstallFile/Install_docker.sh)
  read -p "按回车键返回主菜单："
}

select=''
function show_Use() {
    clear
    select=''
    printf "****************************************************************************\n"
                            printf "\t\t**欢迎使用tools脚本菜单**\n"
    printf "****************************************************************************\n"
                            printf "\t\t${green}0. ${plain}退出脚本.\n"
                            printf "\t\t${green}1. ${plain}服务安装.\n"
                            printf "\t\t${green}2. ${plain}acme脚本(搭配cloudflare).\n"
    printf "****************************************************************************\n"
    read -p "输入序号【0-2】：" select
    case $select in
    0)
    exit 1
      ;;
    1)
    show_soft
      ;;
    2)
    setting_ssl
      ;;
    *)
      echo "输入错误"
      exit 1
      ;;
    esac
}

function show_soft() {
#安装软件进程和端口检查，调用函数check_install_system,调用前设置
#    #process=() 检查此数组中的进程
#    #test_server_port=() 检查此数组中的端口
    process=()
    test_server_port=()
    select=''
    if [ $? -eq 0 ];then
      echo -e "${green}变量初始化完成${plain}"
    fi
    clear
    printf "****************************************************************************\n"
                        printf "\t\t**欢迎使用tools软件安装脚本菜单**\n"
    printf "****************************************************************************\n"
                        printf "\t\t${green}0. ${plain}返回主页面.\n"
                        printf "\t\t${green}1. ${plain}配置信息查看.\n"
                        printf "\t\t${green}2. ${plain}Nginx.\n"
                        printf "\t\t${green}3. ${plain}Docker.\n"
    printf "****************************************************************************\n"
    read -p   "输入序号【0-1】：" select
    case $select in
    0)
     return
      ;;
    1)
      clear
      printf "*****************************************************************************\n"
      printf "${green}现在时间：${plain}$time\n"
      printf "*****************************************************************************\n"
      printf "\t\t**全局配置信息**\n"
      printf "*****************************************************************************\n"
      printf "${green}安装包下载路径：${plain}$download_path\n"
      printf "${green}软件安装路径：${plain}$install_path\n"
      printf "*****************************************************************************\n"
      printf "\t\t**服务配置信息**\n"
      printf "*****************************************************************************\n"
      printf "${green}Nginx服务包下载路径：${plain}$nginx_download_url\n"
      printf "${green}Nginx程序用户：${plain}$nginx_user\n"
      printf "*****************************************************************************\n"
      read -p "按回车键返回主菜单："
      ;;
    2)
    printf "\t\t${green}1. ${plain}Nginx${nginx_download_url_1##*/nginx-}\n"
    read -p "Enther Your choice（1）:" select
    case $select in
          1)
          nginx_download_url=$nginx_download_url_1
          ;;
          *)
            echo "暂无此版本."
            exit 0
            ;;
          esac
     echo $nginx_download_url
     process=(nginx)
     test_server_port=(80 443)
     check_install_system
     install_nginx
      ;;
    3)
      printf "\t\t${green}1. ${plain}Docker${docker_download_url_1##*/docker-}\n"
      read -p "Enther Your choice（1）:" select
      install_docker
      ;;
    *)
      echo "输入序号不存在"
      ;;
    esac
} #show_soft


[ `whoami` != root ] && echo -e "${red}需要使用root权限${plain}" && exit 1
while [ true ]; do
show_Use
done