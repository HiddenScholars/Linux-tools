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


function check_install_system() {
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
    select=''
    download_select=''
    if_select=''
    $controls install -y wget curl net-tools
    if [ $? -ne 0 ];then
      echo -e "${red}安装失败${plain}" && exit 0
    fi
    [ ! -d "$download_path/nginx/" ] && echo "$download_path/nginx不存在，自动创建" && mkdir -p $download_path/nginx
    if [ `ls $download_path/nginx/ | wc -l` -ne 0 ];then
      echo -e "${red}$download_path/nginx/中存在文件${plain}"
      cd $download_path/nginx/
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
      read -p  "文件夹中存在文件是否继续下载（y/n）：" download_select

      if [ "$download_select" == "y" ]; then
            wget -P $download_path/nginx/ $nginx_download_url
            cd $download_path/nginx/
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
      wget -P $download_path/nginx/ $nginx_download_url
      cd $download_path/nginx/
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
    [ ! -f $download_path/nginx/${sorted_files[$select]} ] && echo -e "${red}文件不存在${plain}" && exit 0
    echo $release
    if [ "$release" == "centos" ]; then
        yum install -y gcc gcc-c++ pcre pcre-devel zlib zlib-devel openssl openssl-devel gd gd-devel
    elif [ "$release" == "ubuntu" ]; then
        apt install -y gcc g++ libpcre3 libpcre3-dev zlib1g zlib1g-dev libssl-dev libgd-dev
    else
        apt install -y gcc g++ libpcre3 libpcre3-dev zlib1g zlib1g-dev libssl-dev libgd-dev
    fi
    [ -d $install_path/nginx/ ] && mv $install_path/nginx/ $install_path/nginx$time
    mkdir -p /temp/nginx_file
    tar xvf $download_path/nginx/${sorted_files[$select]} -C /temp/nginx_file/ --strip-components 1
    cd /temp/nginx_file/ && ./configure --prefix=${install_path}/nginx/ \
                                                --with-pcre \
                                                --with-http_ssl_module \
                                                --with-http_v2_module \
                                                --with-http_realip_module \
                                                --with-http_addition_module \
                                                --with-http_sub_module \
                                                --with-http_dav_module \
                                                --with-http_flv_module \
                                                --with-http_mp4_module \
                                                --with-http_gunzip_module \
                                                --with-http_gzip_static_module \
                                                --with-http_random_index_module \
                                                --with-http_secure_link_module \
                                                --with-http_stub_status_module \
                                                --with-http_auth_request_module \
                                                --with-http_image_filter_module \
                                                --with-http_slice_module \
                                                --with-mail \
                                                --with-threads \
                                                --with-file-aio \
                                                --with-stream \
                                                --with-mail_ssl_module \
                                                --with-stream_ssl_module && make && make install
    source /etc/profile
    if [ -z $NGINX_HOME ];then
    echo "export NGINX_HOME=$install_path/nginx/" >>/etc/profile
    source /etc/profile
    fi
    if [ ! -z $nginx_user ]; then
    id $nginx_user &>/dev/null
    [ $? -ne 0 ] && useradd -s /sbin/nologin $nginx_user
    chown -R $nginx_user:$nginx_user $NGINX_HOME
    fi

    if [ -f $NGINX_HOME/sbin/nginx ]; then
        echo -e "${green}安装完成...${plain}"
        cd /temp/  && rm -rf nginx_file
        else
        echo -e "${red}安装失败...${plain}"
        exit 0
    fi

echo "[Unit]
Description=The Nginx HTTP Server
After=network.target remote-fs.target nss-lookup.target

[Service]
Type=forking
PIDFile=$NGINX_HOME/logs/nginx.pid
ExecStart=$NGINX_HOME/sbin/nginx
ExecReload=$NGINX_HOME/sbin/nginx -s reload
ExecStop=$NGINX_HOME/sbin/nginx -s stop
PrivateTmp=true

[Install]
WantedBy=multi-user.target" > /usr/lib/systemd/system/nginx.service

chmod +x /usr/lib/systemd/system/nginx.service
systemctl daemon-reload
systemctl start nginx.service
systemctl enable nginx.service
systemctl status nginx.service
ps -ef | grep nginx &>/dev/null
[ $? -ne 0 ] && exit 0

echo -e "设置防火墙..."
if [ ${release} == "centos" ]; then
    if [ `ps -ef | grep firewalld | wc -l ` -ne 0 ];then
        firewall-cmd --permanent --add-port=80/tcp
        firewall-cmd --permanent --add-port=443/tcp
        firewall-cmd --reload
    else
       [ "$(grep '<port protocol=\"tcp\" port=\"80\"/>' /etc/firewalld/zones/public.xml | wc -l)" -eq 0 ] && sed -i '$!N;$!P;$!D;$s|\(.*\)\n\(.*\)|\1\n<port protocol="tcp" port="80"/>\n\2|' /etc/firewalld/zones/public.xml
       [ "$(grep '<port protocol=\"tcp\" port=\"443\"/>' /etc/firewalld/zones/public.xml | wc -l)" -eq 0 ] && sed -i '$!N;$!P;$!D;$s|\(.*\)\n\(.*\)|\1\n<port protocol="tcp" port="443"/>\n\2|' /etc/firewalld/zones/public.xml
     fi
elif [ ${release} == "ubuntu" ];then
    if [ `dpkg --get-selections | grep ufw | wc -l` -ne 0 ]; then
        ufw allow 80/tcp
        ufw allow 443/tcp
        ufw reload
    else
      echo -e "${red}未检出ufw进程，不进行更改${plain}"
    fi
else
    echo -e "${red}无法识别的防火墙${plain}"
fi
read -p "按回车键返回主菜单："
} #install_nginx

function setting_ssl() {
echo "111"
}

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
function install_docker() {
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
  bash <(curl -L https://raw.githubusercontent.com/LGF-LGF/tools/main/InstallFile/install_docker.sh)
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