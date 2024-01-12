#!/bin/bash

nginx_download_url=
docker_download_url=
select_download_version=
config_path=/tools/
config_file=/tools/config.sh
#Linux-tools start check ...
[ `whoami` != root ] && echo -e "${red}需要使用root权限${plain}" && exit 1
branch_select_num=0
# 获取 Github 仓库分支列表
branches=$(curl -s "https://api.github.com/repos/HiddenScholars/Linux-tools/branches" | grep '"name":' | sed -E 's/.*"name": "(.*)",/\1/')
# 将分支列表存入数组
branch_array=()
while IFS= read -r branch; do
  branch_array+=("$branch")
done <<< "$branches"
clear
echo
echo -e "选择项目分支，main为主节点，其余为测试节点会有新功能但并不保证稳定"
# 逐个读取数组元素
for branch in "${branch_array[@]}"; do
  echo -e "${green}$branch_select_num.$branch${plain}"
  let branch_select_num++
done

   read -p "Enther Your branch num (0 ...):" branch_select_choice
   [ -z $branch_select_choice ] && echo -e "${red}不存在的分支${plain}" && exit 0
   con_branch=${branch_array[$branch_select_choice]}
#config.sh check
#======================================================================
  if [ ! -f ${config_file} ];then
    [ ! -d ${config_path} ] && mkdir ${config_path}
    echo -e "${red}config文件不存在，开始下载...${plain}"
    wget -P ${config_path} https://raw.githubusercontent.com/HiddenScholars/Linux-tools/$con_branch/config.sh
    [ ! -f ${config_file} ] && echo -e "${red}下载失败，config文件不存在，检查后再次执行脚本!!!${plain}" && exit 0

  elif  [ `curl -s https://raw.githubusercontent.com/HiddenScholars/Linux-tools/$con_branch/config.sh | wc -l` -gt `cat $config_file | wc -l ` ];then
      config_select=''
      read -p "config.sh文件有变化，是否重新下载？（y/n）" config_select
      if [ "$config_select" == "y" ];then
        mv $config_file $config_path/config_bak$time
        wget -P ${config_path} https://raw.githubusercontent.com/HiddenScholars/Linux-tools/$con_branch/config.sh
        [ ! -f ${config_file} ] && echo -e "${red}下载失败，config文件不存在，检查后再次执行脚本!!!${plain}" && exit 0
      fi
  fi
source $config_file
#======================================================================
# install link localhost
bash <(curl -L https://raw.githubusercontent.com/HiddenScholars/Linux-tools/$con_branch/Link_localhost/install.sh)
#======================================================================

case $1 in
-d)
  case $2 in
  config.sh)
          wget -P ${config_path} https://raw.githubusercontent.com/HiddenScholars/Linux-tools/$con_branch/config.sh
          [ ! -f ${config_file} ] && echo -e "${red}下载失败，config文件不存在，检查后再次执行脚本!!!${plain}" && exit 0
          ;;
  *)
  echo -e "${red}参数错误${plain}"
    ;;
  esac
;;
*)
  while [ true ]; do
  bash <(curl -L https://raw.githubusercontent.com/HiddenScholars/Linux-tools/$con_branch/Show_Use/Show_menu.sh)
  done
  ;;
esac