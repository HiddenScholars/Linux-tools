#!/bin/bash
version=2024-04-19
script_dir=$(cd "$(dirname "$0")" && pwd)
#目录菜单 ! menu 为菜单 其余全部当做脚本执行 ，脚本根据功能数组中开头install 或uninstall判断执行卸载还是安装，中间部根据soft还是其他部分执行不同脚本
## 一级主目录及功能
main_menu=("关闭脚本菜单" "服务器软件" "服务器环境" "服务器系统" "容器部署" "网站搭建" "常用开源脚本")
main_menu_function=("exit 0" "ServerSoft_menu"  "ServerEnv_menu" "ServerClean_menu" "DockerInstall_menu" "WebSiteInstall_menu"  "OpenSourceScript_menu")
## 二级服务器软件目录及功能
ServerSoft_menu=("返回主页面" "软件安装" "软件卸载" "软件升级")
ServerSoft_menu_script=("return" "ServerSoftInstall_menu" "ServerSoftUninstall_menu" "ServerSoftUpgrade_menu")
### 三级服务器软件安装脚本
ServerSoftInstall_menu=("返回主页面" "nginx" "docker" "docker-compose" "mysql5")
ServerSoftInstall_menu_script=("return" "install_soft_nginx" "install_soft_docker" "install_soft_docker-compose" "install_soft_mysql5")
### 三级服务器软件卸载脚本
ServerSoftUninstall_menu=("返回主页面" "nginx卸载" "docker卸载" "docker-compose卸载" "mysql5卸载" "tailscale卸载" "lnmp2.0卸载脚本（包含lnmp,lnmpa,lamp")
ServerSoftUninstall_menu_script=("return" "uninstall_soft_nginx" "uninstall_soft_docker" "uninstall_soft_docker-compose" "uninstall_soft_mysql5" "uninstall_tailscale" "uninstall_lnmp2.0")
### 三级服务器软件软件升级
ServerSoftUpgrade_menu=("返回主菜单" "Nginx平滑升(降)级")
ServerSoftUpgrade_menu_script=("return" "upgrade_smooth_nginx")
## 二级服务器环境目录及功能
ServerEnv_menu=("返回主页面" "jdk")
ServerEnv_menu_script=("return" "install_jdk")
## 二级服务器系统目录及功能
ServerClean_menu=("返回主页面" "清理jumpserver社区版(只清理相关镜像与文件)" "jdk环境清理")
ServerClean_menu_script=("return" "clean_jumpserver_free" "clean_jdk_file")
## 二级容器部署目录及功能
DockerInstall_menu=("返回主页面" "jumpserver(社区版-docker环境安装)" "firefox浏览器(docker环境安装)" "bitwarden密码管理(docker环境安装)")
DockerInstall_menu_script=("return" "install_jumpserver_free" "install_DockerFirefox" "install_DockerBitwarden")
## 二级网站搭建目录及功能
WebSiteInstall_menu=("返回主页面" "宝塔国际版" "宝塔（中国大陆版本）" "1Panel" "acme脚本(搭配cloudflare)")
WebSiteInstall_menu_script=("return" "install_aaPanel" "install_bt" "install_1panel" "setting_ssl")
## 二级常用开源脚本目录及功能
OpenSourceScript_menu=("返回主页面" "tailscale" "Nginx(lnmp2.0)" "db数据库(lnmp2.0)" "mphp(lnmp2.0)" "lnmp(lnmp2.0)" "lnmpa(lnmp2.0)" "lamp(lnmp2.0)")
OpenSourceScript_menu_script=("return" "install_tailscale" "install_lnmp_package_nginx" "install_lnmp_package_db" "install_lnmp_package_mphp" "install_lnmp_package_lnmp" "install_lnmp_package_lnmpa" "install_lnmp_package_lamp")

function SYSTEM_CHECK() {
    if [ -f /etc/os-release ]; then
        source /etc/os-release
        if [ "$ID" == "centos" ]; then
            if [ "$VERSION_ID" == "7" ]; then
               SystemVersion="centos_7"
            fi
        elif [ "$ID" == "ubuntu" ]; then
            SystemVersion="ubuntu"
        elif [ "$ID" == "debian" ]; then
            SystemVersion="debian"
        elif [ "$ID" == "anolis" ]; then
            SystemVersion="Anolis OS"
        else
            echo "[$(date '+%Y-%m-%d %H:%M:%S')] 暂不支持$ID:$VERSION_ID的发行版本"
            exit 1
        fi
    else
      echo "[$(date '+%Y-%m-%d %H:%M:%S')] 系统检测失败..."
      exit 1
    fi
    if [ "$(uname -m)" == "x86_64" ]; then
        CPUArchitecture=$(uname -m)
    else
       echo "[$(date '+%Y-%m-%d %H:%M:%S')] 暂不支持$CPUArchitecture架构"
       exit 1
    fi
    if command -v apt-get &>/dev/null; then
      controls='apt-get'
    elif command -v yum &>/dev/null; then
      controls='yum'
    else
      echo "[$(date '+%Y-%m-%d %H:%M:%S')] 找不到支持的包管理工具"
      exit 1
    fi
  if [ -f "$script_dir"/install.conf ]; then
      sed -i "s|os=.*|os=$SystemVersion|g" "$script_dir"/install.conf
      sed -i "s|package_manager=.*|package_manager=$controls|g" "$script_dir"/install.conf
      sed -i "s|os_arch=.*|os_arch=$CPUArchitecture|g" "$script_dir"/install.conf
  else
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] 修改install.conf文件失败,install.conf不存在"
    exit 1
  fi
}
function check_file(){
  if [ ! -f "$script_dir"/install.conf ]; then
      printf
  fi
}
function menu() {
    # 获取传入的数组参数
    local array1=("${!1}")
    local array2=("${!2}")
    select=''
    printf "==========================================\n"
    for ((i=0;i<${#array1[@]};i++))
    do
        printf "\t%s. %s.➤\n" "${i}" "${array1[$i]}"
    done
    printf "==========================================\n"
    read -rp "[$(date '+%Y-%m-%d %H:%M:%S')] 输入序号【0-"$((${#array1[@]}-1))"】：" select
    if [ -n "$select" ] ;then
        if [[ "$select" =~ ^[0-9]+$ ]] && [ -n "${array2[$select]}" ]  ; then
            # 数据分割,过滤是否为菜单
            local check_args=$(echo "${array2[$select]}" | awk -F '_' '{print $NF}')
            if [  "$check_args" == "menu" ]; then
               main "${array2[$select]}"
            else
              script_run "${array2[$select]}"
            fi
        else
           echo "[$(date '+%Y-%m-%d %H:%M:%S')] 不存在的功能"
        fi
    else
       echo "[$(date '+%Y-%m-%d %H:%M:%S')] 输入序号才能执行"
    fi
}
function script_run() {
    local args=$1
    #数据分隔，判断数据为卸载还是安装
    local install_uninstall=$(echo "$args" | awk -F '_'  '{print $1}')
    local script_path=$(echo "$args" | awk -F '_'  '{print $2}')
    local script_name=$(echo "$args" | awk -F '_'  '{print $3}')
    if [ "$install_uninstall" == "install" ]; then
       if [ "$script_path" == "soft" ]; then
         "$script_dir"/Command/"$os_arch"/"$os"/figlet -f "$script_dir"/Command/font/slant.flf  "$script_name"
          printf "$script_dir/$script_path/script/$os_arch/$script_name/install.sh\t\t"
          if [ -f "$script_dir/$script_path/script/$os_arch/$script_name/install.sh" ] && [ -x "$script_dir/$script_path/script/$os_arch/$script_name/install.sh" ]; then
              printf "\033[0;32m[✔]\033[0m\n"
          else
              if [ -f "$script_dir/$script_path/script/$os_arch/$script_name/install.sh" ]; then
                  chmod +x "$script_dir/$script_path/script/$os_arch/$script_name/install.sh"
                  if [ -x "$script_dir/$script_path/script/$os_arch/$script_name/install.sh" ];then
                     printf "\033[0;32m[✔]\033[0m\n"
                  else
                     printf "\033[0;31m[×]\033[0m\n"
                  fi
              else
                 printf "\033[0;31m[×]\033[0m\n"
              fi
          fi
          bash "$script_dir/$script_path/script/$os_arch/$script_name/install.sh"
        else
          exit 1
       fi
    elif [ "$install_uninstall" == "uninstall" ]; then
       if [ "$script_path" == "soft" ]; then
         "$script_dir"/Command/"$os_arch"/"$os"/figlet -f "$script_dir"/Command/font/slant.flf "$script_name"
         printf "$script_dir/$script_path/script/$os_arch/$script_name/uninstall.sh\t\t"
          if [ -f "$script_dir/$script_path/script/$os_arch/$script_name/uninstall.sh" ] && [ -x "$script_dir/$script_path/script/$os_arch/$script_name/uninstall.sh" ]; then
              printf "\033[0;32m[✔]\033[0m\n"
          else
              if [ -f "$script_dir/$script_path/script/$os_arch/$script_name/uninstall.sh" ]; then
                  chmod +x "$script_dir/$script_path/script/$os_arch/$script_name/uninstall.sh"
                  if [ -x "$script_dir/$script_path/script/$os_arch/$script_name/uninstall.sh" ];then
                     printf "\033[0;32m[✔]\033[0m\n"
                  else
                     printf "\033[0;31m[×]\033[0m\n"
                  fi
              else
                 printf "\033[0;31m[×]\033[0m\n"
              fi
          fi
          bash "$script_dir/$script_path/script/$os_arch/$script_name/uninstall.sh"
       else
         exit 1
       fi
    else
       echo "[$(date '+%Y-%m-%d %H:%M:%S')] 未找到安装脚本"
       exit 1
    fi

}
function main() {
    local args=$1
    if [ -z "$args" ]; then
       menu main_menu[@] main_menu_function[@]
    else
      menu "$args"[@] "$args"_script[@]
    fi
}

SYSTEM_CHECK
source "$script_dir"/install.conf
chmod +x "$script_dir"/Command/"$os_arch"/"$os"/*
chmod -R +x "$script_dir"/soft/sbin/"$os_arch"/"$os"/
temp_return_select=0
while true; do
[ "$temp_return_select" -ne 0 ] && read -rp "[$(date '+%Y-%m-%d %H:%M:%S')] 回车返回主菜单"
let temp_return_select++
clear
"$script_dir"/Command/"$os_arch"/"$os"/figlet -f "$script_dir"/Command/font/slant.flf Linux-tools
main
done