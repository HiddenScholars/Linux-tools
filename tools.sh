#!/bin/bash

config_path=/tools/
config_file=/tools/config
version_file=$config_path/version
red=$(curl -sl https://"$url_address"/HiddenScholars/Linux-tools/"$con_branch"/Check/Check.sh | bash -s -- COLOR red)
green=$(curl -sl https://"$url_address"/HiddenScholars/Linux-tools/"$con_branch"/Check/Check.sh | bash -s -- COLOR green)
plain=$(curl -sl https://"$url_address"/HiddenScholars/Linux-tools/"$con_branch"/Check/Check.sh | bash -s -- COLOR plain)

handle_error() {
    echo "出现运行错误，解决后再次运行！错误码：$?"
    exit 1
}
handle_exit() {
    echo "脚本退出..."
    exit 0
}
trap handle_error ERR
trap handle_exit EXIT

#Linux-tools start check ...
[ `whoami` != root ] && echo -e "${red}需要使用root权限${plain}" && exit 0
function CHECK_FILE() {
     if [ -z "$url_address" ] && [ -z "$con_branch" ] ;then
       set -x
       url_address=raw.githubusercontent.com
       con_branch=main
       set +x
     else
       source $config_file &>/dev/null #当url_address and con_branch 都存在时优先使用config配置
     fi
      if [  ! -f $version_file ]; then
          [ ! -d ${config_path} ] && mkdir ${config_path}
          echo "0" > $version_file
      fi
      if [ ! -f ${config_file} ];then
            [ ! -d ${config_path} ] && mkdir ${config_path}
            echo -e "${green} config downloading... ${plain}"
            wget -P ${config_path} https://$url_address/HiddenScholars/Linux-tools/$con_branch/config
            [ ! -f ${config_file} ] && echo -e "${red}download failed${plain}" && exit 0
            sed -i "s/url_address=.*/url_address=$url_address/g" "$config_file" #下载完成后修改仓库地址
           sed -i "s/con_branch=.*/con_branch=$con_branch/g" "$config_file" #下载完成后修改分支
      fi

    GET_DOWNLOAD_PATH=$(grep -c download_path $config_file)
    source $config_file &>/dev/null
    if [ -z "$download_path" ] && [ "$GET_DOWNLOAD_PATH" == 1 ]; then
       sed -i "s/download_path=.*/download_path=/tools/soft/g" $config_file
    elif [ -z "$download_path" ] && [ "$GET_DOWNLOAD_PATH" == 0 ]; then
      echo "download_path=/tools/soft" >>$config_file
    fi
    GET_INSTALL_PATH=$(grep -c install_path $config_file)
    if [ -z "$install_path" ] && [ "$GET_INSTALL_PATH" == 1 ]; then
       sed -i "s/install_path=.*/install_path=/usr/local/soft/g" $config_file
    elif [ -z "$install_path" ] && [ "$GET_INSTALL_PATH" == 0 ];then
      echo "install_path=/usr/local/soft/" >>$config_file
    fi
    if [ -n "$download_path" ] && [ ! -d "$download_path" ]; then
        mkdir -p "$download_path"
    fi
    if [ -n "$install_path" ] && [ ! -d "$install_path" ]; then
        mkdir -p "$install_path"
    fi
}
function initialize_check() {
source $config_file &>/dev/null
bash <(curl -sL https://$url_address/HiddenScholars/Linux-tools/$con_branch/Link_localhost/install.sh) # tool link install.sh
# 环境检测
curl -sl https://$url_address/HiddenScholars/Linux-tools/$con_branch/Check/Check.sh | bash -s -- SET_CONFIG
# 获取包管理器
GET_PACKAGE_MASTER=$(curl -sl https://$url_address/HiddenScholars/Linux-tools/$con_branch/Check/Check.sh | bash -s -- PACKAGE_MASTER)
# 获取系统版本
GET_SYSTEM_CHECK=$(curl -sl https://$url_address/HiddenScholars/Linux-tools/$con_branch/Check/Check.sh | bash -s -- SYSTEM_CHECK)
# 必装命令检测
GET_DIRECTIVES_CHECK=$(curl -sl https://$url_address/HiddenScholars/Linux-tools/$con_branch/Check/Check.sh | bash -s -- DIRECTIVES_CHECK 0 "wget" "netstat" "pgrep" "find")
for i in "${GET_DIRECTIVES_CHECK[@]}"
do
    if [ "$i" == "netstat" ]; then
        "$GET_PACKAGE_MASTER" -y install net-tools
    elif [ "$i" == "pgrep" ]; then
        case "$GET_SYSTEM_CHECK" in
        debian)
              "$GET_PACKAGE_MASTER" -y install procps
              ;;
        ubuntu)
              "$GET_PACKAGE_MASTER" -y install procps
              ;;
        centos)
              "$GET_PACKAGE_MASTER" -y install procps-ng
              ;;
        kali_Linux)
              "$GET_PACKAGE_MASTER" -y install procps
              ;;
        *)
              echo "SYSTEM_CHECK NOT FOUND"
              return 1
              ;;
        esac
    fi
done
}
echo "脚本获取成功，数据处理中，请稍后..."
case $1 in
-d)
  case $2 in
  config)
          CHECK_FILE
          if [ -f ${config_file} ];then
            echo -e "${green}download success ${plain}"
            exit 0
          else
            echo -e "${red}download failed${plain}"
            exit 0
          fi
          ;;
  *)
          echo -e "${red}参数错误${plain}"
          ;;
  esac
  ;;
*)
  CHECK_FILE
  initialize_check
  bash <(curl -sL https://$url_address/HiddenScholars/Linux-tools/$con_branch/Show_Use/Show_menu.sh) # function menu
  ;;
esac