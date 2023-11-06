#!/bin/bash

red='\033[31m'
green='\033[32m'
yellow='\033[33m'
plain='\033[0m'

#常维护变量
nginx_download_url=https://nginx.org/download/nginx-1.24.0.tar.gz
download_path=/tools/soft/
#注：这里为所有安装软件的统一路径，任何软件都会以软件名在这个路径下创建路径安装，路径重复根据date +%Y%m%d进行备份
install_path=/usr/local/soft/
time=date +%Y%m%d
#软件统一管理账号
User=my_soft
Groupadd=my_soft


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
    LOGE "未检测到系统版本，请联系脚本作者！\n" && exit 1
fi
# select erector
controls=''
if [ "$release" == "centos" ];then
  controls='yum'
elif [ "$release" == "ubuntu" ];then
  controls='apt'
elif [ "$release" == "debain" ]; then
  controls='apt'
fi

function install_nginx() {
    select=''
    Controls
    $controls install -y wget curl 
    if [ $? -ne 0 ];then
      echo -e "${red}安装失败${plain}" && exit 0
    fi
    [ ! -f "$download_path" ] && echo "$download_path不存在，自动创建" && mkdir -p $download_path
    wget -P $download_path/ $nginx_download_url
    num=0
    for i in ${download_path[@]}
    do
    echo "$num：$i"
    let num++
    done
    read -p "选择安装包：" select
    if [ -z select ]; then
        echo "未选择安装包，退出脚本"
        exit 0
    fi
    [ -f $install_path/nginx/ ] && mv $install_path/nginx/ $install_path/nginx$time
    mkdir $install_path/nginx_file
    tar xvf "${download_path[select]}" -C $install_path/nginx_file/ --strip-components 1
    if [ "$release" == "centos" ]; then
        yum install -y gcc gcc-c++ pcre pcre-devel zlib zlib-devel openssl openssl-devel gd gd-devel
    elif [ "$release" == "ubuntu" ]; then
        apt install -y gcc g++ libpcre3 libpcre3-dev zlib1g zlib1g-dev libssl-dev libgd-dev
    else
        apt install -y gcc g++ libpcre3 libpcre3-dev zlib1g zlib1g-dev libssl-dev libgd-dev
    fi
    cd $install_path/nginx_file/ && ./configure --prefix=${install_path}/soft/nginx/  \
                                    --user=$User \
                                    --group=$Groupadd \
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
    chmod -R $User:$Groupadd $install_path/nginx/
    echo "Nginx_Home=$install_path/nginx/" >/etc/profile
    source /etc/profile/
    if [ -f $Nginx_home/sbin/nginx ]; then
        echo "${green}安装完成...${plain}"
        else
        echo "${red}安装失败...${plain}'"
        exit
    fi

}

select=''
function show_Use() {
    select=''
    echo -e "${green}0. ${plain}退出脚本."
    echo -e "${green}1. ${plain}软件安装."
    read -p   "输入序号【0-1】：" select
    case $select in
    0)
    exit 1
      ;;
    1)
    show_soft
      ;;
    *)
      echo "输入错误"
      ;;
    esac
}

function show_soft() {
    select=''
    echo -e "${green}0. ${plain}返回主页面."
    echo -e "${green}1. ${plain}Nginx."
    read -p   "输入序号【0-1】：" select
    case $select in
    0)
     return
      ;;
    1)
     install_nginx
      ;;
    esac
}


while [ true ]; do
show_Use
done



