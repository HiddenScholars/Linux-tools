#!/bin/bash

nginx_download_url=
docker_download_url=
select_download_version=
config_path=/tools/
config_file=/tools/config.sh
version_file=$config_path/version
branch_array=()
branch_select_choice=0

source $config_file &>/dev/null
#Linux-tools start check ...
[ `whoami` != root ] && echo -e "${red}需要使用root权限${plain}" && exit 0
function SELECT_BRANCHES() {
        if [ -z $con_branch ]; then
                branches=$(curl -s "https://api.github.com/repos/HiddenScholars/Linux-tools/branches" | grep '"name":' | sed -E 's/.*"name": "(.*)",/\1/' | sort)
                while IFS= read -r branch; do
                  branch_array+=("$branch")
                done <<< "$branches"
                clear
                echo -e "选择项目分支，main为主分支，其余为测试节点会有新功能但并不保证稳定"
                for branch in "${!branch_array[@]}"; do
                  echo -e "${green}$branch.${branch_array[$branch]}${plain}"
                done
                   read -p "select branch num (0 ...)(default：0):" branch_select_choice
                   if [ -z ${branch_array[$branch_select_choice]} ]; then
                      echo -e "${red}不存在的分支${plain}" && exit 0
                   elif ! [[ $branch_select_choice =~ ^[0-9]+$ ]]; then
                      echo -e "${red}输入错误${plain}" && exit 0
                   fi
                con_branch=${branch_array[$branch_select_choice]}
                sed -i "s/con_branch=.*/con_branch=$con_branch/g" $config_file
        fi
}
function CHECK_URL_ADDRESS() {
    if [ -z $url_address ]; then
                  url_address_number=("raw.githubusercontent.com" "raw.yzuu.cf")
    
                  for i in "${!url_address_number[@]}"
                  do
                      echo "$i：${url_address_number[$i]}"
                  done
                  read -p  "下载地址为空,请选择或手动输入下载地址：" url_address_select
                  if [[ $url_address_select =~ ^[0-9]+$ ]]; then
                      if [ ! -z ${url_address_number[$url_address_select]} ]; then
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
          ping -c 1 $url_address &>/dev/null
          if [ $? -ne 0 ];then
              echo "与$url_address 通信异常请检查网络环境！！！"
              exit 0
          fi
          temp_url_address_github_check=0
          for (( i=0; i < 4; i++ ))
          do
           [ `curl -is https://$url_address | grep github.com | wc -l` == 0 ] && let temp_url_address_github_check++
          done
          if [ $temp_url_address_github_check == 3 ];then
              read -p  "链接超时或$url_address 未检测到github特征，是否继续(y/n)" countinue
             [ "$countinue" != "y" ] && exit 0
          fi
}
function CHECK_FILE() {
      if [  ! -f $version_file ]; then
          [ ! -d ${config_path} ] && mkdir ${config_path}
          touch $version_file
      fi
      if [ ! -f ${config_file} ];then
            [ ! -d ${config_path} ] && mkdir ${config_path}
            echo -e "${red}config文件不存在，开始下载...${plain}"
            wget -P ${config_path} https://$url_address/HiddenScholars/Linux-tools/$con_branch/config.sh
            [ ! -f ${config_file} ] && echo -e "${red}下载失败，config文件不存在，检查后再次执行脚本!!!${plain}" && exit 0
            sed -i "s/url_address=.*/url_address=$url_address/g" $config_file #下载完成后修改仓库地址
      fi
}

source $config_file &>/dev/null
bash <(curl -sL https://$url_address/HiddenScholars/Linux-tools/$con_branch/Link_localhost/install.sh)

case $1 in
-d)
  case $2 in
  config.sh)
          wget -P ${config_path} https://$url_address/HiddenScholars/Linux-tools/$con_branch/config.sh
          [ ! -f ${config_file} ] && echo -e "${red}下载失败，config文件不存在，检查后再次执行脚本!!!${plain}" && exit 0
          ;;
  *)
  echo -e "${red}参数错误${plain}"
    ;;
  esac
;;
*)
  CHECK_FILE
  SELECT_BRANCHES
  CHECK_URL_ADDRESS
  bash <(curl -L https://$url_address/HiddenScholars/Linux-tools/$con_branch/Show_Use/Show_menu.sh)
  ;;
esac