#!/bin/bash

config_path=/tools/
config_file=/tools/config
version_file=$config_path/version
source $config_file &>/dev/null
red=$(curl -sl https://"$url_address"/HiddenScholars/Linux-tools/"$con_branch"/Check/Check.sh | bash -s -- COLOR red)
green=$(curl -sl https://"$url_address"/HiddenScholars/Linux-tools/"$con_branch"/Check/Check.sh | bash -s -- COLOR green)
plain=$(curl -sl https://"$url_address"/HiddenScholars/Linux-tools/"$con_branch"/Check/Check.sh | bash -s -- COLOR plain)
handle_error() {
    echo "出现运行错误，解决后再次运行！错误码：$?"
    exit 1
}
handle_exit() {
    echo "退出菜单页..."
    exit 0
}
trap handle_error ERR
trap handle_exit EXIT

#菜单目录显示控制
show_use=("退出" "安装" "卸载" "升级" "更新")
show_use_function=("exit 0" "show_Soft" "soft_Uninstall" "soft_Upgrade" "check_update")
show_soft=("返回主页面" "Nginx" "Docker+Docker-compose" "Docker-compose" "Mysql5" "JDK" "acme脚本(搭配cloudflare)" "tailscale" "一键安装所有")
show_soft_function=("return" "install_nginx" "install_docker" "install_docker_compose" "install_mysql5" "install_jdk" "setting_ssl" "install_tailscale" "install_all")
soft_uninstall=("返回主页面" "Nginx卸载" "Docker+Docker-compose卸载" "Mysql5卸载" "tool命令卸载")
soft_uninstall_function=("return" "uninstall_nginx" "uninstall_docker_docker_compose" "uninstall_mysql5" "uninstall_tool")
soft_upgrade=("返回主菜单" "Nginx平滑升(降)级")
soft_upgrade_function=("return" "upgrade_smooth_nginx")

  GET_REMOTE_VERSION=$(curl -sl https://"$url_address"/HiddenScholars/Linux-tools/"$con_branch"/version)
  GET_LOCAL_VERSION=$(cat $version_file)
function check_update() {
          if [ "$GET_REMOTE_VERSION"  != "$GET_LOCAL_VERSION" ];then
             bash <(curl -sL https://"$url_address"/HiddenScholars/Linux-tools/"$con_branch"/UpdateFile/UPDATE.sh)
             #更新完成重新获取本地版本
             GET_LOCAL_VERSION=$(cat $version_file)
          elif [ "$GET_REMOTE_VERSION"  == "$GET_LOCAL_VERSION" ];then
             echo -e "${green}已是最新版本${plain}"
          else
             echo -e "${red} 版本参数错误 ${plain}"
             return 1
          fi
}
function install_nginx() {
echo "开始安装Nginx"
bash <(curl -sL https://"$url_address"/HiddenScholars/Linux-tools/"$con_branch"/InstallFile/Install_nginx.sh)
}
function setting_ssl() {
echo "开始安装证书"
bash <(curl -sL https://"$url_address"/HiddenScholars/Linux-tools/"$con_branch"/InstallFile/Install_ssl_acme.sh)
}
function install_docker() {
echo "开始安装Docker"
bash <(curl -sL https://"$url_address"/HiddenScholars/Linux-tools/"$con_branch"/InstallFile/Install_docker.sh)
echo "开始安装Docker-compose"
bash <(curl -sL https://"$url_address"/HiddenScholars/Linux-tools/"$con_branch"/InstallFile/Install_docker-compose.sh)
}
function install_docker_compose() {
echo "开始安装Docker-compose"
bash <(curl -sL https://"$url_address"/HiddenScholars/Linux-tools/"$con_branch"/InstallFile/Install_docker-compose.sh)
}
function upgrade_smooth_nginx(){
bash <(curl -sL https://"$url_address"/HiddenScholars/Linux-tools/"$con_branch"/Upgrade/Upgrade_smooth_nginx.sh)
}
function uninstall_nginx() {
    bash <(curl -sL https://"$url_address"/HiddenScholars/Linux-tools/"$con_branch"/UninstallFile/Uninstall_nginx.sh)
}
function uninstall_docker_docker_compose() {
    bash <(curl -sL https://"$url_address"/HiddenScholars/Linux-tools/"$con_branch"/UninstallFile/Uninstall_docker_docker_compose.sh)
}
function uninstall_tool() {
    bash <(curl -sL https://"$url_address"/HiddenScholars/Linux-tools/"$con_branch"/Link_localhost/uninstall.sh)
}
function uninstall_mysql5() {
    bash <(curl -sL https://"$url_address"/HiddenScholars/Linux-tools/"$con_branch"/UninstallFile/Uninstall_mysql5.sh)
}
function install_jdk() {
    bash <(curl -sL https://"$url_address"/HiddenScholars/Linux-tools/"$con_branch"/InstallFile/Install_jdk.sh)
}
function install_mysql5() {
    bash <(curl -sL https://"$url_address"/HiddenScholars/Linux-tools/"$con_branch"/InstallFile/Install_mysql5.sh)
}
function install_tailscale() {
    bash <(curl -sL https://"$url_address"/HiddenScholars/Linux-tools/"$con_branch"/InstallFile/Install_tailscale.sh)
}
function install_all() {
for i in "${show_soft_function[@]}"
do
  if [ "$i" != "install_docker_compose" ] && [ "$i" != "install_all" ] && [ "$i" != "return" ]; then
      $i
  fi
done
}
function disk_capacity_check() {
      tool_soft_path=$(echo "$config_path"/soft/ | tr -s '/')
      tool_unpack_file=$(echo "$config_path"/unpack_file/ | tr -s '/')
      capacity=($(du -s "$tool_soft_path" tool_unpack_file | awk '{print $1}'))
      capacity_path=($(du -s "$tool_soft_path" tool_unpack_file | awk '{print $1}'))
      for (( i = 0; i < "${#capacity[@]}"; i++ )); do
         if  [ -n "$Max_disk_usage" ] && [ "$Max_disk_usage" -ne 0 ] && [ "${#capacity[$i]}" -ge "$Max_disk_usage" ]; then
             echo -e "${red}$capacity_path 占用 $((${#capacity[$i]} / 1024 /1024 )) 超过$(("$Max_disk_usage" / 1024 / 1024 )) 阈值进行删除${plain}"
             rm -rf "$capacity_path"
         fi
      done
}

#该参数请勿修改
temp_return_select=0
function show_Use() {
[ $temp_return_select -ne 0 ] && read -rp "回车返回主菜单"
let temp_return_select++
select=''
clear
echo -e "${green}   _|                          _|${plain}"
echo -e "${green}_|_|_|_|    _|_|      _|_|     _|    _|_|_|${plain}"
echo -e "${green}   _|      _|    _|  _|    _|  _|  _|_|${plain}"
echo -e "${green}   _|      _|    _|  _|    _|  _|      _|_|${plain}"
echo -e "${green}     _|_|    _|_|      _|_|    _|  _|_|_|${plain}"
    select=''
    printf "****************************************************************************\n"
                            printf "\t\t**欢迎使用Linux-tools脚本菜单** %s\n" "$([ "$GET_REMOTE_VERSION" != "$GET_LOCAL_VERSION" ] && echo -e "${red}最新版本：v$GET_REMOTE_VERSION.可更新${plain}")"
    printf "****************************************************************************\n"
                            for i in "${!show_use[@]}"
                            do
                            printf "\t\t${green}%s. ${plain}${show_use[$i]}.➤\n" "${i}"
                            done
    printf "****************************************************************************\n"
    read -rp "输入序号【0-"$((${#show_use[@]}-1))"】：" select
    if [ -n "$select" ] ;then
        if [[ "$select" =~ ^[0-9]+$ ]] && [ -n "${show_use_function[$select]}" ]  ; then
            eval  "${show_use_function[$select]}"
        else
           echo "不存在的功能"
        fi
    else
       echo "输入序号才能执行"
    fi
}
function show_Soft() {
    select=''
    clear
    printf "****************************************************************************\n"
                        printf "\t\t**欢迎使用Linux-tools软件安装脚本菜单**\n"
    printf "****************************************************************************\n"
                            for i in "${!show_soft[@]}"
                            do
                            printf "\t\t${green}%s. ${plain}${show_soft[$i]}.\n" "${i}"
                            done
    printf "****************************************************************************\n"
    read -rp   "输入序号【0-"$((${#show_soft[@]}-1))"】：" select
    if [ -n "$select" ] ;then
            if [[ "$select" =~ ^[0-9]+$ ]] && [ -n "${show_soft_function[$select]}" ]  ; then
                eval  "${show_soft_function[$select]}"
            else
               echo "不存在的功能"
            fi
    else
           echo "输入序号才能执行"
    fi

}
function soft_Uninstall() {
      select=''
      uninstall_select=''
      clear
      printf "****************************************************************************\n"
                              printf "\t\t**欢迎使用Linux-tools脚本菜单**\n"
      printf "****************************************************************************\n"
                            for i in "${!soft_uninstall[@]}"
                            do
                            printf "\t\t${green}%s. ${plain}${soft_uninstall[$i]}.\n" "${i}"
                            done
      printf "****************************************************************************\n"
      read -rp "输入序号【0-"$((${#soft_uninstall[@]}-1))"】：" select
      if [ -n "$select" ] ;then
            if [[ "$select" =~ ^[0-9]+$ ]] && [ -n "${soft_uninstall_function[$select]}" ]  ; then
                read -rp "是否卸载请确认（y/n）" uninstall_select
                if [ "$uninstall_select" == "y" ]; then
                   eval  "${soft_uninstall_function[$select]}"
                fi
            else
               echo "不存在的功能"
            fi
      else
           echo "输入序号才能执行"
      fi

}
function soft_Upgrade() {
    select=''
    clear
    printf "****************************************************************************\n"
                                printf "\t\t**欢迎使用Linux-tools脚本菜单**\n"
        printf "****************************************************************************\n"
                            for i in "${!soft_upgrade[@]}"
                            do
                            printf "\t\t${green}%s. ${plain}${soft_upgrade[$i]}.\n" "${i}"
                            done
        printf "****************************************************************************\n"
        read -rp "输入序号【0-"$((${#soft_upgrade[@]}-1))"】：" select
    if [ -n "$select" ] ;then
            if [[ "$select" =~ ^[0-9]+$ ]] && [ -n "${soft_upgrade_function[$select]}" ]  ; then
                eval  "${soft_upgrade_function[$select]}"
            else
               echo "不存在的功能"
            fi
    else
           echo "输入序号才能执行"
    fi
}

while  true ; do
    disk_capacity_check
    show_Use
done