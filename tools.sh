#!/bin/bash

nginx_download_url=
docker_download_url=
select_download_version=
config_path=/tools/
config_file=/tools/config
version_file=$config_path/version
branch_array=()
branch_select_choice=0

source $config_file &>/dev/null
#Linux-tools start check ...
#[ `whoami` != root ] && echo -e "${red}需要使用root权限${plain}" && exit 0

function CHECK_URL_ADDRESS() {
    if [ -z "$url_address" ]; then
                  url_address_number=("raw.githubusercontent.com" "raw.yzuu.cf")
    
                  for i in "${!url_address_number[@]}"
                  do
                      echo "$i：${url_address_number[$i]}"
                  done
                  read -rp  "下载地址为空,请选择或手动输入下载地址：" url_address_select
                  if [[ $url_address_select =~ ^[0-9]+$ ]]; then
                      if [  -n "${url_address_number[$url_address_select]}" ]; then
                          url_address=${url_address_number[$url_address_select]}
                          if [ -f $config_file ];then
                             sed -i "s/url_address=.*/url_address=$url_address/g" $config_file
                             source $config_file &>/dev/null
                             [ "$url_address" != "${url_address_number[$url_address_select]}" ] && echo "url_address=${url_address_number[$url_address_select]}" >> $config_file
                          fi
                      else
                          echo -e "${red}选择的地址不存在${plain}"
                          exit 0
                      fi
                  elif [[ $url_address_select =~ [a-zA-Z0-9]+\.[a-zA-Z]{2,3}(/\S*)?$ ]]; then
                      url_address=$url_address_select
                          if [ -f $config_file ];then
                             sed -i "s/url_address=.*/url_address=$url_address/g" $config_file
                             source $config_file &>/dev/null
                             [ "$url_address" != "$url_address_select" ] && echo "url_address=$url_address_select" >> $config_file
                          fi
                  else
                     echo "参数错误"
                     exit 0
                  fi
          fi
}
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
            echo -e "${red}config downloading...${plain}"
            wget -P ${config_path} https://$url_address/HiddenScholars/Linux-tools/$con_branch/config
            [ ! -f ${config_file} ] && echo -e "${red}download failed${plain}" && exit 0
            sed -i "s/url_address=.*/url_address=$url_address/g" $config_file #下载完成后修改仓库地址
            sed -i "s/con_branch=.*/con_branch=$con_branch/g" $config_file #下载完成后修改分支
      fi
}

source $config_file &>/dev/null
bash <(curl -sL https://$url_address/HiddenScholars/Linux-tools/$con_branch/Link_localhost/install.sh) # tool link install.sh
curl -sL https://$url_address/HiddenScholars/Linux-tools/$con_branch/Check/Check.sh | DIRECTIVES=("wget" "netstat" "lll") bash DIRECTIVES_CHECK 0
case $1 in
-d)
  case $2 in
  config)
          wget -P ${config_path} https://$url_address/HiddenScholars/Linux-tools/$con_branch/config
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
  CHECK_URL_ADDRESS
  bash <(curl -sL https://$url_address/HiddenScholars/Linux-tools/$con_branch/Show_Use/Show_menu.sh) # function menu
  ;;
esac