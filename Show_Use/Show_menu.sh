#!/bin/bash

config_path=/tools/
config_file=/tools/config
version_file=$config_path/version
source $config_file &>/dev/null
red=$(curl -sl https://"$url_address"/HiddenScholars/Linux-tools/"$con_branch"/Check/Check.sh | bash -s -- COLOR red)
green=$(curl -sl https://"$url_address"/HiddenScholars/Linux-tools/"$con_branch"/Check/Check.sh | bash -s -- COLOR green)
plain=$(curl -sl https://"$url_address"/HiddenScholars/Linux-tools/"$con_branch"/Check/Check.sh | bash -s -- COLOR plain)

function check_update() {
  GET_REMOTE_VERSION=$(curl -s https://"$url_address"/HiddenScholars/Linux-tools/"$con_branch"/version)
  GET_LOCAL_VERSION=$(cat $version_file)
          if [[ "$GET_LOCAL_VERSION" =~ ^[0-9]+$ ]] && [ "$GET_REMOTE_VERSION"  -ne "$GET_LOCAL_VERSION" ];then
             # shellcheck disable=SC2086
             bash <(curl -sL https://$url_address/HiddenScholars/Linux-tools/$con_branch/UpdateFile/UPDATE.sh)
             if [ $? -eq 0 ]; then
             echo "$GET_REMOTE_VERSION" >$version_file
             fi
             echo -e "${green}已是最新版本${plain}"
          else
             echo -e "${red} 版本参数错误 ${plain}"
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
function uninstall_docker() {
    bash <(curl -sL https://"$url_address"/HiddenScholars/Linux-tools/"$con_branch"/UninstallFile/Uninstall_docker.sh)
}
function uninstall_tool() {
    bash <(curl -sL https://"$url_address"/HiddenScholars/Linux-tools/"$con_branch"/Link_localhost/uninstall.sh)
}

#菜单目录显示控制
show_use=("退出" "安装" "卸载" "升级" "acme脚本(搭配cloudflare)" "检查更新")
show_use_function=("exit 1" "show_Soft" "soft_Uninstall" "soft_Upgrade" "setting_ssl" "check_update")
show_soft=("返回主页面" "nginx" "docker" "docker-compose")
show_soft_function=("return" "install_nginx" "install_docker" "install_docker_compose")
soft_uninstall=("返回主页面" "Nginx卸载" "Docker卸载" "tool命令卸载")
soft_uninstall_function=("return" "uninstall_nginx" "uninstall_docker" "uninstall_tool")
soft_upgrade=("返回主菜单" "Nginx平滑升(降)级")
soft_upgrade_function=("return" "upgrade_smooth_nginx")



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
                            printf "\t\t**欢迎使用Linux-tools脚本菜单** \t version：%s\n" "$(cat $config_path/version)"
    printf "****************************************************************************\n"
                            for i in "${!show_use[@]}"
                            do
                            printf "\t\t${green}%s. ${plain}${show_use[$i]}.\n" "${i}"
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
                eval  "${soft_uninstall_function[$select]}"
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
    show_Use
done