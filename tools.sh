#!/bin/bash

nginx_download_url=
docker_download_url=
select_download_version=
config_path=/tools/
config_file=/tools/config.sh

#Linux-tools start check ...
[ `whoami` != root ] && echo -e "${red}需要使用root权限${plain}" && exit 1
# 获取 Github 仓库分支列表
branches=$(curl -s "https://api.github.com/repos/HiddenScholars/Linux-tools/branches" | grep '"name":' | sed -E 's/.*"name": "(.*)",/\1/')
# 将分支列表存入数组
branch_array=()
branch_select_choice=0
while IFS= read -r branch; do
  branch_array+=("$branch")
done <<< "$branches"
clear
echo -e "选择项目分支，main为主节点，其余为测试节点会有新功能但并不保证稳定"
# 逐个读取数组元素
for branch in "${!branch_array[@]}"; do
  echo -e "${green}$branch.${branch_array[$branch]}${plain}"
done
   read -p "Enther Your branch num (0 ...):" branch_select_choice
   if [ -z ${branch_array[$branch_select_choice]} ]; then
      echo -e "${red}不存在的分支${plain}" && exit 0
   elif ! [[ $branch_select_choice =~ ^[0-9]+$ ]]; then
      echo -e "${red}输入错误${plain}" && exit 0
   fi
   con_branch=${branch_array[$branch_select_choice]}

#config.sh check
#======================================================================
  if [ -z $url_address ]; then
    url_address_number=("raw.githubusercontent.com" "raw.yzuu.cf")

          for i in "${!url_address_number[@]}"
          do
              echo "$i：${url_address_number[$i]}"
          done
          read -p  "永久下载地址变量为空,请选择或手动输入下载地址：" url_address_select
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
      read -p  "${red}未检测到github特征，是否继续(y/n)${plain}" countinue
     [ "$countinue" != "y" ] && exit 0
  fi


  if [ ! -f ${config_file} ];then
    [ ! -d ${config_path} ] && mkdir ${config_path}
    echo -e "${red}config文件不存在，开始下载...${plain}"
        wget -P ${config_path} https://$url_address/HiddenScholars/Linux-tools/$con_branch/config.sh
    [ ! -f ${config_file} ] && echo -e "${red}下载失败，config文件不存在，检查后再次执行脚本!!!${plain}" && exit 0
    sed -i "s/url_address=.*/url_address=$url_address/g" $config_file #下载完成后修改仓库地址
  elif  [ `curl -s https://$url_address/HiddenScholars/Linux-tools/$con_branch/config.sh | wc -l` -gt `cat $config_file | wc -l ` ];then
      config_select=''
      read -p "config.sh文件有变化，是否重新下载？（y/n）" config_select
      if [ "$config_select" == "y" ];then
        mv $config_file $config_path/config_bak$time
        source $config_path/config_bak$time
        wget -P ${config_path} https://$url_address/HiddenScholars/Linux-tools/$con_branch/config.sh
        [ ! -f ${config_file} ] && echo -e "${red}下载失败，config文件不存在，检查后再次执行脚本!!!${plain}" && exit 0
        sed -i "s/url_address=.*/url_address=$url_address/g" $config_file #下载完成后修改仓库地址
      fi
  fi
source $config_file &>/dev/null
#======================================================================
# install link localhost
#======================================================================
bash <(curl -sL https://$url_address/HiddenScholars/Linux-tools/$con_branch/Link_localhost/install.sh)
#======================================================================

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
  retry_number=1
  while [ true ]; do
  bash <(curl -sL https://$url_address/HiddenScholars/Linux-tools/$con_branch/Show_Use/Show_menu.sh) $con_branch || [ $? -ne 0 ] && echo -e "${red}与github仓库链接失败，重试$retry_number次${plain}"
  [ $retry_number == 3 ] && echo "链接失败，不再重试" && exit 0
  let retry_number++
  done
  ;;
esac