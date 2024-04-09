#!/bin/bash

config_path=/tools/
config_file=/tools/config.xml

handle_error() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] 出现运行错误，解决后再次运行！错误码：$?"
    exit 1
}
handle_exit() {
    printf "\n%s 由于执行错误或用户取消而退出...\n" "[$(date '+%Y-%m-%d %H:%M:%S')]"
    bash
    exit 0
}
trap handle_error ERR
trap handle_exit EXIT
con_branch=$(awk -v RS="</parameters>" '/<parameters>/{gsub(/.*<parameters>[\r\n\t ]*|[\r\n\t ]*$/,"");print}' $config_file | awk -F'[><]' '/<con_branch>/{print $3}')
url_address=$(awk -v RS="</parameters>" '/<parameters>/{gsub(/.*<parameters>[\r\n\t ]*|[\r\n\t ]*$/,"");print}' $config_file | awk -F'[><]' '/<url_address>/{print $3}')
function CHECK_FILE() {
country=$(awk -v RS="</parameters>" '/<parameters>/{gsub(/.*<parameters>[\r\n\t ]*|[\r\n\t ]*$/,"");print}' $config_file | awk -F'[><]' '/<country>/{print $3}')
     [ "$con_branch" == "TestMain" ] && printf "%s 正在访问测试节点\n" "[$(date '+%Y-%m-%d %H:%M:%S')]"
     if [ -z "$url_address" ] && [ -z "$con_branch" ] ;then
       set -x
       url_address=raw.githubusercontent.com
       con_branch=main
       set +x
     fi
      if [ ! -f ${config_file} ];then
            [ ! -d ${config_path} ] && mkdir -p ${config_path}
            echo  " config downloading..."
            wget -O ${config_file} https://$url_address/HiddenScholars/Linux-tools/$con_branch/Config_file/config_"$country"
            [ ! -f ${config_file} ] && echo -e "[$(date '+%Y-%m-%d %H:%M:%S')] download failed" && exit 0
            sed -i "s|<url_address>.*</url_address>|<url_address>$url_address</url_address>|g" $config_file
            sed -i "s|<con_branch>.*</con_branch>|<con_branch>$con_branch</con_branch>|g" $config_file
      fi

    GET_DOWNLOAD_PATH=$(awk -v RS="</paths>" '/<paths>/{gsub(/.*<paths>[\r\n\t ]*|[\r\n\t ]*$/,"");print}' $config_file | awk -F'[><]' '/<download_path>/{print $3}')
    if [ -z "$GET_DOWNLOAD_PATH" ]; then
       sed -i "s|<download_path>.*</download_path>|<download_path>/tools/soft/</download_path>|g" $config_file
       echo "[$(date '+%Y-%m-%d %H:%M:%S')] setting download_path /tools/soft/."
    fi
    GET_INSTALL_PATH=$(awk -v RS="</paths>" '/<paths>/{gsub(/.*<paths>[\r\n\t ]*|[\r\n\t ]*$/,"");print}' $config_file | awk -F'[><]' '/<install_path>/{print $3}')
    if [ -z "$GET_INSTALL_PATH" ];then
       sed -i "s|<install_path>.*</install_path>|<install_path>/usr/local/soft/</install_path>|g" $config_file
       echo "[$(date '+%Y-%m-%d %H:%M:%S')] setting install_path /usr/local/soft/."
    fi

    GET_DOWNLOAD_PATH=$(awk -v RS="</paths>" '/<paths>/{gsub(/.*<paths>[\r\n\t ]*|[\r\n\t ]*$/,"");print}' $config_file | awk -F'[><]' '/<download_path>/{print $3}')
    GET_INSTALL_PATH=$(awk -v RS="</paths>" '/<paths>/{gsub(/.*<paths>[\r\n\t ]*|[\r\n\t ]*$/,"");print}' $config_file | awk -F'[><]' '/<install_path>/{print $3}')
    # check PATH
    if [ -n "$GET_INSTALL_PATH" ] && [ -n "$GET_DOWNLOAD_PATH" ]; then
        if [ ! -d "$GET_DOWNLOAD_PATH" ]; then
            mkdir -p "$GET_DOWNLOAD_PATH"
        fi
        if [ ! -d "$GET_INSTALL_PATH" ]; then
            mkdir -p "$GET_INSTALL_PATH"
        fi
    else
      echo "[$(date '+%Y-%m-%d %H:%M:%S')] The read install_path or download_path is incorrect. "
      exit 1
    fi
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] tool write. "
    curl -sl https://"$url_address"/HiddenScholars/Linux-tools/"$con_branch"/Command/tool > $config_path/tool
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] tool write is complete. "
}
function SetTool(){
  if [  -f /etc/init.d/tool ];then
    rm -rf /etc/init.d/tool && [ -L /usr/bin/tool ] && rm -rf /usr/bin/tool
    echo  "[$(date '+%Y-%m-%d %H:%M:%S')] 删除tool指令"
  elif [ -f /tools/tool ];then
    rm -rf /tools/tool && [ -L /usr/bin/tool ] && rm -rf /usr/bin/tool
  elif [ -L /usr/bin/tool ];then
    rm -rf /usr/bin/tool
    echo  "[$(date '+%Y-%m-%d %H:%M:%S')] 删除tool软连接"
  fi
  sed -i "s/con_branch=.*/con_branch=$con_branch/g" $config_file
  sed -i "s/url_address=.*/url_address=$url_address/g" $config_file
  chmod +x $config_file
}
function initialize_check() {
#Linux-tools start check ...
[ $(whoami) != root ] && echo -e "[$(date '+%Y-%m-%d %H:%M:%S')] 需要使用root权限" && exit 1
SetTool
bash <(curl -sl https://$url_address/HiddenScholars/Linux-tools/$con_branch/Check/Check.sh) SET_CONFIG
GET_DIRECTIVES_CHECK=($(curl -sl https://$url_address/HiddenScholars/Linux-tools/$con_branch/Check/Check.sh | bash -s -- DIRECTIVES_CHECK 0 "wget" "netstat" "pgrep" "find" "md5sum"))
for i in "${GET_DIRECTIVES_CHECK[@]}"
do
    if [ "$i" == "netstat" ]; then
        "$controls" -y install net-tools
    elif [ "$i" == "pgrep" ]; then
        case "$SystemVersion" in
        debian)
              "$controls" -y install procps
              ;;
        ubuntu)
              "$controls" -y install procps
              ;;
        centos)
              "$controls" -y install procps-ng
              ;;
        kali_Linux)
              "$controls" -y install procps
              ;;
        *)
              echo "[$(date '+%Y-%m-%d %H:%M:%S')] SystemVersion NOT FOUND"
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
echo "[$(date '+%Y-%m-%d %H:%M:%S')] 脚本获取成功，数据处理中，请稍后..."
case $1 in
-d)
  case $2 in
  config.xml)
          CHECK_FILE
          if [ -f ${config_file} ];then
            echo -e "[$(date '+%Y-%m-%d %H:%M:%S')] download success"
            exit 0
          else
            echo -e "[$(date '+%Y-%m-%d %H:%M:%S')] [$(date '+%Y-%m-%d %H:%M:%S')] download failed"
            exit 0
          fi
          ;;
  *)
          echo -e "[$(date '+%Y-%m-%d %H:%M:%S')] [$(date '+%Y-%m-%d %H:%M:%S')] 参数错误"
          ;;
  esac
  ;;
*)
  CHECK_FILE
  progress_bar 2 1
  initialize_check
  progress_bar 2 2
  printf "\n"
  bash <(curl -sl https://"$url_address"/HiddenScholars/Linux-tools/"$con_branch"/Check/Check.sh) SetVariables PATH /tools/ /etc/profile
  printf "\n%s 数据处理完成正在获取菜单\n" "[$(date '+%Y-%m-%d %H:%M:%S')]"
  bash <(curl -L https://$url_address/HiddenScholars/Linux-tools/$con_branch/Show_Use/Show_menu.sh) # function menu
  bash
  ;;
esac