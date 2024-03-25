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
    printf "\n由于用户取消退出...\n"
    bash
    exit 0
}
trap handle_error ERR
trap handle_exit EXIT
function CHECK_FILE() {
     source $config_file &>/dev/null #优先使用config中的配置
     [ "$con_branch" == "TestMain" ] && printf "正在访问测试节点\n"
     if [ -z "$url_address" ] && [ -z "$con_branch" ] ;then
       set -x
       url_address=raw.githubusercontent.com
       con_branch=main
       set +x
     fi
      if [  ! -f $version_file ]; then
          [ ! -d ${config_path} ] && mkdir ${config_path}
          GET_REMOTE_VERSION=$(curl -sl https://"$url_address"/HiddenScholars/Linux-tools/"$con_branch"/version)
          echo "$GET_REMOTE_VERSION" > $version_file
      fi
      if [ ! -f ${config_file} ];then
            [ ! -d ${config_path} ] && mkdir ${config_path}
            echo  " config downloading..."
            wget -O ${config_file} https://$url_address/HiddenScholars/Linux-tools/$con_branch/Config_file/config_"$country"
            [ ! -f ${config_file} ] && echo -e "${red}download failed${plain}" && exit 0
            sed -i "s/url_address=.*/url_address=$url_address/g" "$config_file" #下载完成后修改仓库地址
            sed -i "s/con_branch=.*/con_branch=$con_branch/g" "$config_file" #下载完成后修改分支
      fi

    GET_DOWNLOAD_PATH=$(grep -c download_path $config_file)
    source $config_file &>/dev/null
    if [ -z "$download_path" ] && [ "$GET_DOWNLOAD_PATH" == 1 ]; then
       sed -i "s/download_path=.*/download_path=/tools/soft/g" $config_file
    elif [ -z "$download_path" ] && [ "$GET_DOWNLOAD_PATH" == 0 ]; then
      echo -e "\n" >> "$config_file"
      echo "download_path=/tools/soft" >>$config_file
    fi
    GET_INSTALL_PATH=$(grep -c install_path $config_file)
    if [ -z "$install_path" ] && [ "$GET_INSTALL_PATH" == 1 ]; then
       sed -i "s/install_path=.*/install_path=/usr/local/soft/g" $config_file
    elif [ -z "$install_path" ] && [ "$GET_INSTALL_PATH" == 0 ];then
      echo -e "\n" >> "$config_file"
      echo "install_path=/usr/local/soft/" >>$config_file
    fi
    if [ -n "$download_path" ] && [ ! -d "$download_path" ]; then
        mkdir -p "$download_path"
    fi
    if [ -n "$install_path" ] && [ ! -d "$install_path" ]; then
        mkdir -p "$install_path"
    fi
    sed '/^$/d' "$config_file" &>/dev/null #删除空行
}
function initialize_check() {
#Linux-tools start check ...
[ $(whoami) != root ] && echo -e "${red}需要使用root权限${plain}" && exit 0
source $config_file &>/dev/null
bash <(curl -sL https://$url_address/HiddenScholars/Linux-tools/$con_branch/Link_localhost/install.sh) # tool link install.sh
# 环境检测
bash <(curl -sl https://$url_address/HiddenScholars/Linux-tools/$con_branch/Check/Check.sh) SET_CONFIG
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
function progress_bar() {
    local total_functions=$1  # 总函数数量
    local executed_functions=$2  # 已执行的函数数量
    local progress=$((executed_functions * 100 / total_functions))  # 计算进度百分比
    printf "\r处理中: [%-50s] %d%%" $(printf '#%.0s' $(seq 1 $((progress / 2)))) $progress
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
        progress_bar 2 1
        initialize_check
        progress_bar 2 2
  printf "\n数据处理完成正在获取菜单\n"
  bash <(curl -L https://$url_address/HiddenScholars/Linux-tools/$con_branch/Show_Use/Show_menu.sh) # function menu
  bash
  ;;
esac