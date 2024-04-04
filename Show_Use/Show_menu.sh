#!/bin/bash

config_path=/tools/
config_file=/tools/config
version_file=$config_path/version
source $config_file &>/dev/null
red=$(curl -sl https://"$url_address"/HiddenScholars/Linux-tools/"$con_branch"/Check/Check.sh | bash -s -- COLOR red)
green=$(curl -sl https://"$url_address"/HiddenScholars/Linux-tools/"$con_branch"/Check/Check.sh | bash -s -- COLOR green)
plain=$(curl -sl https://"$url_address"/HiddenScholars/Linux-tools/"$con_branch"/Check/Check.sh | bash -s -- COLOR plain)
handle_error() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] 出现运行错误，解决后再次运行！错误码：$?"
}
handle_exit() {
    printf "\n%s 由于用户取消退出菜单页...\n" "[$(date '+%Y-%m-%d %H:%M:%S')]"
    exit 0
}
trap handle_error ERR
trap handle_exit EXIT

#菜单目录显示控制
show_use=("关闭脚本菜单" "中间件安装" "中间件卸载" "中间件升级" "环境安装" "开源项目部署" "网站建设" "DIY工具" "系统清理" "文件更新")
show_use_function=("exit 0" "show_Soft" "soft_Uninstall" "soft_Upgrade" "install_env" "install_open_source_projects" "install_web_site_install" "install_diy" "system_clean" "check_update")
show_soft=("返回主页面" "Nginx" "Docker+Docker-compose" "Docker-compose" "Mysql5" "Nginx(lnmp2.0)" "db数据库(lnmp2.0)" "mphp(lnmp2.0)" "lnmp(lnmp2.0)" "lnmpa(lnmp2.0)" "lamp(lnmp2.0)"  "一键执行全部中间件安装脚本")
show_soft_function=("return" "install_nginx" "install_docker" "install_docker_compose" "install_mysql5" "install_lnmp_package_nginx" "install_lnmp_package_db" "install_lnmp_package_mphp" "install_lnmp_package_lnmp" "install_lnmp_package_lnmpa" "install_lnmp_package_lamp" "install_all")
soft_uninstall=("返回主页面" "Nginx卸载" "Docker+Docker-compose卸载" "Mysql5卸载" "tailscale卸载" "lnmp2.0卸载脚本（包含lnmp,lnmpa,lamp）" "tool命令卸载")
soft_uninstall_function=("return" "uninstall_nginx" "uninstall_docker_docker_compose" "uninstall_mysql5" "uninstall_tailscale" "uninstall_lnmp2.0" "uninstall_tool")
soft_upgrade=("返回主菜单" "Nginx平滑升(降)级")
soft_upgrade_function=("return" "upgrade_smooth_nginx")
env_install=("返回主页面" "JDK")
env_install_function=("return" "install_jdk")
open_source_projects=("返回主页面" "jumpserver(社区版-docker安装)")
open_source_projects_function=("return" "install_jumpserver_free")
web_site_install=("返回主页面" "宝塔国际版" "宝塔（中国大陆版本）" "1Panel" "acme脚本(搭配cloudflare)")
web_site_install_function=("return" "install_aaPanel" "install_bt" "install_1panel" "setting_ssl")
diy_install=("返回主页面" "tailscale")
diy_install_function=("return" "install_tailscale")
run_system_clean=("返回主页面" "清理jumpserver社区版(只清理相关镜像与文件)" "jdk环境清理")
run_system_clean_function=("return" "clean_jumpserver_free" "clean_jdk_file")

  GET_REMOTE_VERSION=$(curl -sl https://"$url_address"/HiddenScholars/Linux-tools/"$con_branch"/version)
  GET_LOCAL_VERSION=$(cat $version_file)
function check_update() {
          if [ "$GET_REMOTE_VERSION"  != "$GET_LOCAL_VERSION" ];then
             bash <(curl -sL https://"$url_address"/HiddenScholars/Linux-tools/"$con_branch"/UpdateFile/UPDATE.sh)
             #更新完成重新获取本地版本
             GET_LOCAL_VERSION=$(cat $version_file)
          elif [ "$GET_REMOTE_VERSION"  == "$GET_LOCAL_VERSION" ];then
             echo -e "[$(date '+%Y-%m-%d %H:%M:%S')] ${green}已是最新版本${plain}"
          else
             echo -e "[$(date '+%Y-%m-%d %H:%M:%S')] ${red} 版本参数错误 ${plain}"
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
function uninstall_tailscale() {
    bash <(curl -sL https://"$url_address"/HiddenScholars/Linux-tools/"$con_branch"/UninstallFile/Uninstall_tailscale.sh)
}
function uninstall_lnmp2.0() {
    bash <(curl -sL https://"$url_address"/HiddenScholars/Linux-tools/"$con_branch"/UninstallFile/Uninstall_lnmp_lamp_lnmpa.sh)
}
function clean_jdk_file() {
    bash <(curl -sL https://"$url_address"/HiddenScholars/Linux-tools/"$con_branch"/UninstallFile/Uninstall_jdk.sh)
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
function install_aaPanel() {
    URL=https://www.aapanel.com/script/install_6.0_en.sh && if [ -f /usr/bin/curl ];then curl -ksSO "$URL" ;else wget --no-check-certificate -O install_6.0_en.sh "$URL";fi;bash install_6.0_en.sh aapanel
}
function install_bt() {
    if [ -f /usr/bin/curl ];then curl -sSO https://download.bt.cn/install/install_panel.sh;else wget -O install_panel.sh https://download.bt.cn/install/install_panel.sh;fi;bash install_panel.sh ed8484bec
}
function install_1panel() {
    if [ "$SystemVersion" == "centos" ] || [ "$SystemVersion" == "Anolis OS" ]; then
        curl -sSL https://resource.fit2cloud.com/1panel/package/quick_start.sh -o quick_start.sh && sh quick_start.sh
    elif [ "$SystemVersion" == "ubuntu" ]; then
        curl -sSL https://resource.fit2cloud.com/1panel/package/quick_start.sh -o quick_start.sh && sudo bash quick_start.sh
    elif [ "$SystemVersion" == debian ]; then
        curl -sSL https://resource.fit2cloud.com/1panel/package/quick_start.sh -o quick_start.sh && bash quick_start.sh
    else
        echo "[$(date '+%Y-%m-%d %H:%M:%S')] 未知的系统版本，请前往GitHub-Issue查找/提交问题."
    fi
}
function install_jumpserver_free() {
    bash <(curl -sL https://"$url_address"/HiddenScholars/Linux-tools/"$con_branch"/InstallFile/Install_jumpserver.sh)
}
function clean_jumpserver_free() {
    bash <(curl -sL https://"$url_address"/HiddenScholars/Linux-tools/"$con_branch"/UninstallFile/Uninstall_jumpserver.sh)
}
function install_lnmp_package_nginx() {
    bash <(curl -sL https://"$url_address"/HiddenScholars/Linux-tools/"$con_branch"/InstallFile/Install_lnmp_lamp_lnmpa.sh) nginx
}
function install_lnmp_package_db() {
    bash <(curl -sL https://"$url_address"/HiddenScholars/Linux-tools/"$con_branch"/InstallFile/Install_lnmp_lamp_lnmpa.sh) db
}
function install_lnmp_package_lnmp() {
    bash <(curl -sL https://"$url_address"/HiddenScholars/Linux-tools/"$con_branch"/InstallFile/Install_lnmp_lamp_lnmpa.sh) lnmp
}
function install_lnmp_package_lnmpa() {
    bash <(curl -sL https://"$url_address"/HiddenScholars/Linux-tools/"$con_branch"/InstallFile/Install_lnmp_lamp_lnmpa.sh) lnmpa
}
function install_lnmp_package_lamp() {
    bash <(curl -sL https://"$url_address"/HiddenScholars/Linux-tools/"$con_branch"/InstallFile/Install_lnmp_lamp_lnmpa.sh) lamp
}
function install_lnmp_package_mphp() {
    bash <(curl -sL https://"$url_address"/HiddenScholars/Linux-tools/"$con_branch"/InstallFile/Install_lnmp_lamp_lnmpa.sh) mphp
}

function install_all() {
for (( i = 0; i < "${#show_soft_function[@]}"; i++ )); do
continue_select=''
  if [ "${show_soft_function[$i]}" != "install_docker_compose" ] && [ "${show_soft_function[$i]}" != "install_all" ] && [ "${show_soft_function[$i]}" != "return" ]; then
      echo "${show_soft[$i]}准备安装"
      read -rp "是否跳过此次安装(y/n default:n)" continue_select
      if [ "$continue_select" == "y" ];then
        ${show_soft_function[$i]}
      fi
  fi
done
}
function disk_capacity_check() {
  if [ -d $config_path/soft/ ] && [ -d $config_path/unpack_file/ ]; then
      tool_soft_path=$(echo "$download_path" | tr -s '/')
      tool_unpack_file=$(echo "$config_path"/unpack_file/ | tr -s '/')
      capacity=($(du -s "$tool_soft_path" "$tool_unpack_file" | awk '{print $1}'))
      capacity_path=($(du -s "$tool_soft_path" "$tool_unpack_file" | awk '{print $2}'))
      for (( i = 0; i < "${#capacity[@]}"; i++ )); do
         if  [ -n "$Max_disk_usage" ] && [ "$Max_disk_usage" -gt "1048576" ] && [ "${#capacity[$i]}" -ge "$Max_disk_usage" ]; then
             echo -e "${red}${capacity_path[$i]}占用$((${capacity[$i]} / 1024 /1024 ))G超过$((Max_disk_usage / 1024 / 1024 ))G阈值进行删除${plain}"
             rm -rf "$capacity_path"
         fi
      done
  fi
}
function install_env() {
    select=''
    install_env_select=''
    clear
    printf "****************************************************************************\n"
                        printf "\t\t**欢迎使用Linux-tools工具脚本菜单**\n"
    printf "****************************************************************************\n"
                            for i in "${!env_install[@]}"
                            do
                            printf "\t\t${green}%s. ${plain}${env_install[$i]}.\n" "${i}"
                            done
    printf "****************************************************************************\n"
    read -rp   "[$(date '+%Y-%m-%d %H:%M:%S')] 输入序号【0-"$((${#env_install[@]}-1))"】：" select
    if [ -n "$select" ] ;then
            if [[ "$select" =~ ^[0-9]+$ ]] && [ -n "${env_install_function[$select]}" ]  ; then
                [ "$select" -ne 0 ] && read -rp "[$(date '+%Y-%m-%d %H:%M:%S')] 请确认是否进行环境安装（y/n）" install_env_select
                if [ "$install_env_select" == "y" ]; then
                   echo "[$(date '+%Y-%m-%d %H:%M:%S')] 开始安装"
                   eval  "${env_install_function[$select]}"
                   echo "[$(date '+%Y-%m-%d %H:%M:%S')] 完成安装"
                elif [ "$select" -eq 0 ]; then
                   echo "[$(date '+%Y-%m-%d %H:%M:%S')] 取消环境安装"
                   eval  "${env_install_function[$select]}"
                elif [ -z "$install_env_select" ] || [ "$install_env_select" == "n" ]; then
                   echo "[$(date '+%Y-%m-%d %H:%M:%S')] 取消环境安装"
                fi
            else
               echo "[$(date '+%Y-%m-%d %H:%M:%S')] 不存在的功能"
            fi
    else
           echo "[$(date '+%Y-%m-%d %H:%M:%S')] 输入序号才能执行"
    fi
}
function install_open_source_projects() {
    select=''
    install_open_source_projects_select=''
    clear
    printf "****************************************************************************\n"
                        printf "\t\t**欢迎使用Linux-tools工具脚本菜单**\n"
    printf "****************************************************************************\n"
                            for i in "${!open_source_projects[@]}"
                            do
                            printf "\t\t${green}%s. ${plain}${open_source_projects[$i]}.\n" "${i}"
                            done
    printf "****************************************************************************\n"
    read -rp   "[$(date '+%Y-%m-%d %H:%M:%S')] 输入序号【0-"$((${#open_source_projects[@]}-1))"】：" select
    if [ -n "$select" ] ;then
            if [[ "$select" =~ ^[0-9]+$ ]] && [ -n "${open_source_projects_function[$select]}" ]  ; then
                [ "$select" -ne 0 ] && read -rp "[$(date '+%Y-%m-%d %H:%M:%S')] 请确认是否安装该开源项目（y/n）" install_open_source_projects_select
                if [ "$install_open_source_projects_select" == "y" ]; then
                  echo "[$(date '+%Y-%m-%d %H:%M:%S')] 开始安装"
                  eval  "${open_source_projects_function[$select]}"
                  echo "[$(date '+%Y-%m-%d %H:%M:%S')] 完成安装"
                elif [ "$select" -eq 0 ]; then
                  echo "[$(date '+%Y-%m-%d %H:%M:%S')] 取消安装该开源项目"
                  eval  "${open_source_projects_function[$select]}"
                elif [ -z "$install_open_source_projects_select" ] || [ "$install_open_source_projects_select" == "n" ]; then
                  echo "[$(date '+%Y-%m-%d %H:%M:%S')] 取消安装该开源项目"
                fi
            else
               echo "[$(date '+%Y-%m-%d %H:%M:%S')] 不存在的功能"
            fi
    else
           echo "[$(date '+%Y-%m-%d %H:%M:%S')] 输入序号才能执行"
    fi
}
function install_web_site_install() {
    select=''
    install_web_site_install_select=''
    clear
    printf "****************************************************************************\n"
                        printf "\t\t**欢迎使用Linux-tools工具脚本菜单**\n"
    printf "****************************************************************************\n"
                            for i in "${!web_site_install[@]}"
                            do
                            printf "\t\t${green}%s. ${plain}${web_site_install[$i]}.\n" "${i}"
                            done
    printf "****************************************************************************\n"
    read -rp   "[$(date '+%Y-%m-%d %H:%M:%S')] 输入序号【0-"$((${#web_site_install[@]}-1))"】：" select
    if [ -n "$select" ] ;then
            if [[ "$select" =~ ^[0-9]+$ ]] && [ -n "${web_site_install_function[$select]}" ]  ; then
                [ "$select" -ne 0 ] && read -rp "[$(date '+%Y-%m-%d %H:%M:%S')] 请确认是否安装该建站工具（y/n）" install_web_site_install_select
                if [ "$install_web_site_install_select" == "y" ]; then
                   echo "[$(date '+%Y-%m-%d %H:%M:%S')] 开始安装"
                   eval  "${web_site_install_function[$select]}"
                   echo "[$(date '+%Y-%m-%d %H:%M:%S')] 完成安装"
                elif [ "$select" -eq 0 ]; then
                   echo "[$(date '+%Y-%m-%d %H:%M:%S')] 取消安装该建站工具"
                   eval  "${web_site_install_function[$select]}"
                elif [ -z "$install_web_site_install_select" ] || [ "$install_web_site_install_select" == "n" ]; then
                   echo "[$(date '+%Y-%m-%d %H:%M:%S')] 取消安装该建站工具"
                fi
            else
               echo "[$(date '+%Y-%m-%d %H:%M:%S')] 不存在的功能"
            fi
    else
           echo "[$(date '+%Y-%m-%d %H:%M:%S')] 输入序号才能执行"
    fi
}
function install_diy() {
    select=''
    install_diy_select=''
    clear
    printf "****************************************************************************\n"
                        printf "\t\t**欢迎使用Linux-tools工具脚本菜单**\n"
    printf "****************************************************************************\n"
                            for i in "${!diy_install[@]}"
                            do
                            printf "\t\t${green}%s. ${plain}${diy_install[$i]}.\n" "${i}"
                            done
    printf "****************************************************************************\n"
    read -rp  "[$(date '+%Y-%m-%d %H:%M:%S')] 输入序号【0-"$((${#diy_install[@]}-1))"】：" select
    if [ -n "$select" ] ;then
            if [[ "$select" =~ ^[0-9]+$ ]] && [ -n "${diy_install_function[$select]}" ]  ; then
                 [ "$select" -ne 0 ] && read -rp "[$(date '+%Y-%m-%d %H:%M:%S')] 请确认是否安装该DIY工具（y/n）" install_diy_select
                 if [ "$install_diy_select" == "y" ]; then
                    echo "[$(date '+%Y-%m-%d %H:%M:%S')] 开始安装"
                    eval  "${diy_install_function[$select]}"
                    echo "[$(date '+%Y-%m-%d %H:%M:%S')] 完成安装"
                 elif [ "$select" -eq 0 ]; then
                    echo "[$(date '+%Y-%m-%d %H:%M:%S')] 取消安装该DIY工具"
                    eval  "${diy_install_function[$select]}"
                 elif [ -z "$install_diy_select" ] || [ "$install_diy_select" == "n" ]; then
                     echo "[$(date '+%Y-%m-%d %H:%M:%S')] 取消安装该DIY工具"
                 fi
            else
               echo "[$(date '+%Y-%m-%d %H:%M:%S')] 不存在的功能"
            fi
    else
           echo "[$(date '+%Y-%m-%d %H:%M:%S')] 输入序号才能执行"
    fi
}
function system_clean() {
    select=''
    run_system_clean_select=''
    clear
    printf "****************************************************************************\n"
                        printf "\t\t**欢迎使用Linux-tools工具脚本菜单**\n"
    printf "****************************************************************************\n"
                            for i in "${!run_system_clean[@]}"
                            do
                            printf "\t\t${green}%s. ${plain}${run_system_clean[$i]}.\n" "${i}"
                            done
    printf "****************************************************************************\n"
    read -rp  "[$(date '+%Y-%m-%d %H:%M:%S')] 输入序号【0-"$((${#run_system_clean[@]}-1))"】：" select
    if [ -n "$select" ] ;then
            if [[ "$select" =~ ^[0-9]+$ ]] && [ -n "${run_system_clean_function[$select]}" ]  ; then
                 [ "$select" -ne 0 ] && read -rp "[$(date '+%Y-%m-%d %H:%M:%S')] 请确认是否进行清理（y/n）" run_system_clean_select
                 if [ "$run_system_clean_select" == "y" ]; then
                    echo "[$(date '+%Y-%m-%d %H:%M:%S')] 开始清理"
                    eval  "${run_system_clean_function[$select]}"
                    echo "[$(date '+%Y-%m-%d %H:%M:%S')] 清理完成"
                 elif [ "$select" -eq 0 ]; then
                    echo "[$(date '+%Y-%m-%d %H:%M:%S')] 取消清理"
                    eval  "${run_system_clean_function[$select]}"
                 elif [ -z "$run_system_clean_select" ] || [ "$run_system_clean_select" == "n" ]; then
                     echo "[$(date '+%Y-%m-%d %H:%M:%S')] 取消清理"
                 fi
            else
               echo "[$(date '+%Y-%m-%d %H:%M:%S')] 不存在的功能"
            fi
    else
           echo "[$(date '+%Y-%m-%d %H:%M:%S')] 输入序号才能执行"
    fi
}
#该参数请勿修改
temp_return_select=0
function show_Use() {
[ $temp_return_select -ne 0 ] && read -rp "[$(date '+%Y-%m-%d %H:%M:%S')] 回车返回主菜单"
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
                            printf "\t\t**欢迎使用Linux-tools脚本菜单** %s\n" "$([ "$GET_REMOTE_VERSION" != "$GET_LOCAL_VERSION" ] && echo -e "${green}有本地文件需更新，更新版本号v$GET_REMOTE_VERSION.${plain}")"
    printf "****************************************************************************\n"
                            for i in "${!show_use[@]}"
                            do
                            printf "\t\t${green}%s. ${plain}${show_use[$i]}.➤\n" "${i}"
                            done
    printf "****************************************************************************\n"
    read -rp "[$(date '+%Y-%m-%d %H:%M:%S')] 输入序号【0-"$((${#show_use[@]}-1))"】：" select
    if [ -n "$select" ] ;then
        if [[ "$select" =~ ^[0-9]+$ ]] && [ -n "${show_use_function[$select]}" ]  ; then
           if [ "${show_use_function[$select]}" == "exit 0" ]; then
               bash
           fi
            eval  "${show_use_function[$select]}"
        else
           echo "[$(date '+%Y-%m-%d %H:%M:%S')] 不存在的功能"
        fi
    else
       echo "[$(date '+%Y-%m-%d %H:%M:%S')] 输入序号才能执行"
    fi
}
function show_Soft() {
    select=''
    install_select=''
    clear
    printf "****************************************************************************\n"
                        printf "\t\t**欢迎使用Linux-tools工具脚本菜单**\n"
    printf "****************************************************************************\n"
                            for i in "${!show_soft[@]}"
                            do
                            printf "\t\t${green}%s. ${plain}${show_soft[$i]}.\n" "${i}"
                            done
    printf "****************************************************************************\n"
    read -rp   "[$(date '+%Y-%m-%d %H:%M:%S')] 输入序号【0-"$((${#show_soft[@]}-1))"】：" select
    if [ -n "$select" ] ;then
            if [[ "$select" =~ ^[0-9]+$ ]] && [ -n "${show_soft_function[$select]}" ]  ; then
                [ "$select" -ne 0 ] && read -rp "[$(date '+%Y-%m-%d %H:%M:%S')] 请确认是否执行（y/n）" install_select
                if [ "$install_select" == "y" ]; then
                  echo "[$(date '+%Y-%m-%d %H:%M:%S')] 开始安装"
                  eval  "${show_soft_function[$select]}"
                  echo "[$(date '+%Y-%m-%d %H:%M:%S')] 完成安装"
                elif [ "$select" -eq 0 ]; then
                  echo "[$(date '+%Y-%m-%d %H:%M:%S')] 取消安装"
                  eval  "${show_soft_function[$select]}"
                elif [ -z "$install_select" ] || [ "$install_select" == "n" ]; then
                  echo "[$(date '+%Y-%m-%d %H:%M:%S')] 取消安装"
                fi
            else
               echo "[$(date '+%Y-%m-%d %H:%M:%S')] 不存在的功能"
            fi
    else
           echo "[$(date '+%Y-%m-%d %H:%M:%S')] 输入序号才能执行"
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
      read -rp "[$(date '+%Y-%m-%d %H:%M:%S')] 输入序号【0-"$((${#soft_uninstall[@]}-1))"】：" select
      if [ -n "$select" ] ;then
            if [[ "$select" =~ ^[0-9]+$ ]] && [ -n "${soft_uninstall_function[$select]}" ]  ; then
                [ "$select" -ne 0 ] && read -rp "[$(date '+%Y-%m-%d %H:%M:%S')] 是否卸载请确认（y/n）" uninstall_select
                if [ "$uninstall_select" == "y" ]; then
                   echo "[$(date '+%Y-%m-%d %H:%M:%S')] 开始卸载"
                   eval  "${soft_uninstall_function[$select]}"
                   echo "[$(date '+%Y-%m-%d %H:%M:%S')] 完成卸载"
                elif [ "$select" -eq 0 ]; then
                   echo "[$(date '+%Y-%m-%d %H:%M:%S')] 取消卸载"
                   eval  "${soft_uninstall_function[$select]}"
                elif [ -z "$uninstall_select" ] || [ "$uninstall_select" == "n" ]; then
                   echo "[$(date '+%Y-%m-%d %H:%M:%S')] 取消卸载"
                fi
            else
               echo "[$(date '+%Y-%m-%d %H:%M:%S')] 不存在的功能"
            fi
      else
           echo "[$(date '+%Y-%m-%d %H:%M:%S')] 输入序号才能执行"
      fi

}
function soft_Upgrade() {
    select=''
    upgrade_select=''
    clear
    printf "****************************************************************************\n"
                                printf "\t\t**欢迎使用Linux-tools脚本菜单**\n"
        printf "****************************************************************************\n"
                            for i in "${!soft_upgrade[@]}"
                            do
                            printf "\t\t${green}%s. ${plain}${soft_upgrade[$i]}.\n" "${i}"
                            done
        printf "****************************************************************************\n"
        read -rp "[$(date '+%Y-%m-%d %H:%M:%S')] 输入序号【0-"$((${#soft_upgrade[@]}-1))"】：" select
    if [ -n "$select" ] ;then
            if [[ "$select" =~ ^[0-9]+$ ]] && [ -n "${soft_upgrade_function[$select]}" ]  ; then
                [ "$select" -ne 0 ] && read -rp "[$(date '+%Y-%m-%d %H:%M:%S')] 请确认是否进行升级（y/n）" upgrade_select
                if [ "$upgrade_select" == "y" ]; then
                    echo "[$(date '+%Y-%m-%d %H:%M:%S')] 开始升级"
                    eval  "${soft_upgrade_function[$select]}"
                    echo "[$(date '+%Y-%m-%d %H:%M:%S')] 完成安装"
                elif [ "$select" -eq 0 ];then
                    echo "[$(date '+%Y-%m-%d %H:%M:%S')] 取消升级"
                    eval  "${soft_upgrade_function[$select]}"
                elif [ -z "$upgrade_select" ] || [ "$upgrade_select" == "n" ]; then
                    echo "[$(date '+%Y-%m-%d %H:%M:%S')] 取消升级"
                fi
            else
               echo "[$(date '+%Y-%m-%d %H:%M:%S')] 不存在的功能"
            fi
    else
           echo "[$(date '+%Y-%m-%d %H:%M:%S')] 输入序号才能执行"
    fi
}

while  true ; do
    disk_capacity_check
    show_Use
done