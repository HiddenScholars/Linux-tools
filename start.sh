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
        elif [ "$ID" == "ubuntu" ]; then
            SystemVersion="ubuntu"
        elif [ "$ID" == "debian" ]; then
            SystemVersion="debian"
        elif [ "$ID" == "anolis" ]; then
            SystemVersion="Anolis OS"
        elif [ "$ID" == "alpine" ]; then
            SystemVersion="alpine"
        else
            echo "[$(date '+%Y-%m-%d %H:%M:%S')] 暂不支持$ID:$VERSION_ID的发行版本"
            exit 1
        fi
    else
      echo "[$(date '+%Y-%m-%d %H:%M:%S')] 系统检测失败..."
      exit 1
    fi
    if [ "$(uname -m)" != "x86_64" ]; then
       echo "[$(date '+%Y-%m-%d %H:%M:%S')] 不支持$CPUArchitecture架构"
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
  else
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] 修改install.conf文件失败,install.conf不存在"
    exit 1
  fi
}
function ProcessCheck() {
    local process=("$@")
    if [ "${#process[@]}" -ne 0 ];then
        for pro in "${process[@]}"
        do
          printf "{$process}进程检测\t\t"
          local check_outcome=($("$originate_dir"/Command/"$os_arch"/"$os"/pgrep "$pro"))
          if [ "${#check_outcome[@]}" -ne 0 ]; then
              if docker info &>/dev/null; then
                for docker_pid in $(docker ps -qa)
                do
                    GET_DockerServicePID+=("$docker_pid")
                done
                if [ "${#GET_DockerServicePID[@]}" -ne 0 ]; then
                    temp_num=0
                    for ((i=0;i < "${#GET_DockerServicePID[@]}";i++))
                    do

                       DockerCheckOutcome=$(docker inspect --format '{{ .State.Pid }}' "${GET_DockerServicePID[$i]}")
                       if [ "$DockerCheckOutcome" == "$check_outcome" ];then
                          let temp_num++
                       fi
                    done
                    if [ "$temp_num" == 0 ];then
                       printf "\033[0;31m[✘]\033[0m\n"
                       echo "[$(date '+%Y-%m-%d %H:%M:%S')] 有{$process}进程存在卸载后再次执行脚本"
                       return 1
                    else
                       printf "\033[0;32m[✔]\033[0m\n"
                    fi
                fi
              else
                printf "\033[0;31m[✘]\033[0m\n"
                echo "[$(date '+%Y-%m-%d %H:%M:%S')] 有残留进程卸载后再次执行脚本"
                return 1
              fi
          else
              printf "\033[0;32m[✔]\033[0m\n"
          fi
        done
    else
      echo "[$(date '+%Y-%m-%d %H:%M:%S')] 未检测到进程"
    fi
}
function PortCheck() {
    local ports=("$@")
    if [ "${#ports[@]}" -ne 0 ]; then
        for port in "${ports[@]}"
        do
          printf "{$port}端口检测\t\t"
          local PortCheckOutcome=($("$originate_dir"/Command/"$os_arch"/"$os"/netstat -anp | grep "$port" | grep -v grep))
          if [ "${#check_outcome[@]}" -ne 0 ]; then
              printf "\033[0;31m[✘]\033[0m\n"
              echo "[$(date '+%Y-%m-%d %H:%M:%S')] 端口被占用检查后再次执行脚本"
              return 1
          else
              printf "\033[0;32m[✔]\033[0m\n"
          fi
        done
    else
      echo "[$(date '+%Y-%m-%d %H:%M:%S')] 未检测到端口"
    fi
}
function PathCheck() {
    local paths=("$@")
    for i in "${paths[@]}"
    do
      i=$(echo "$i" | tr -s '/')
      printf "$i\t\t"
      if [ -d "$i" ]; then
         printf "\033[0;31m[✘]\033[0m\n"
         echo "[$(date '+%Y-%m-%d %H:%M:%S')] 使用的目录已存在，请提前备份或执行卸载脚本清除环境"
         return 1
      elif [ ! -d "$i" ]; then
          mkdir -p "$i"
          printf "\033[0;32m[✔]\033[0m\n"
      fi
    done
}
function check_package_version() {
   local name=$1  # nginx,mysql,jdk,docker,docker-compose...
   if [ ! -d "$originate_dir"/soft/package/"$os_arch"/"$name"/ ]; then
       echo "[$(date '+%Y-%m-%d %H:%M:%S')] 安装包目录不存在"
       return 1
   fi
   local packages_name=($(find "$originate_dir"/soft/package/"$os_arch"/"$name"/ | grep tar.gz | awk -F "/$name/" '{print $2}'))
   if [ "${#packages_name[@]}" -ne 0 ]; then
       for ((i=0;i<"${#packages_name[@]}";i++))
       do
          GET_PackageVersion_1=$(echo "${packages_name[$i]}" | grep -oE '[0-9]+\.[0-9]+\.[0-9]+')
          GET_PackageVersion_2=$(echo "${packages_name[$i]}" | grep -oE '[0-9]+\.[0-9]+\.tar.gz+' | sed 's/\.tar\.gz$//')
          GET_PackageVersion_3=$(echo "${packages_name[$i]}" | sed 's/.*\(jdk.*tar\.gz\)/\1/')
          if [ "${#GET_PackageVersion_1}" -ne 0 ]; then
            echo "$i : $GET_PackageVersion_1"
          elif [ "${#GET_PackageVersion_2}" -ne 0  ]; then
            echo "$i : $GET_PackageVersion_2"
          elif [ "${#GET_PackageVersion_3}" -ne 0  ]; then
            echo "$i : $GET_PackageVersion_3"
          else
            if [ -n "$name"  ] && [ "${#packages_name[@]}" -ne 0 ]; then
                echo "$i : 未识别的版本"
            fi
          fi
          read -rp "[$(date '+%Y-%m-%d %H:%M:%S')] Enter Your install service version choice：" y
          nginx_package=$(find "$originate_dir"/soft/package/"$os_arch"/"$name"/ | grep tar.gz | grep "${packages_name[$i]}" )
          nginx_package=$(echo "$nginx_package" | tr -s '/')
          echo "[$(date '+%Y-%m-%d %H:%M:%S')] Start unzipping $nginx_package"
          tar xf "$nginx_package" -C "$originate_dir"/tmp/ --strip-components 1
          if [ $? -eq 0 ]; then
             echo "[$(date '+%Y-%m-%d %H:%M:%S')] The decompression is complete"
          else
             echo "[$(date '+%Y-%m-%d %H:%M:%S')] Failed to decompress"
              return 1
          fi
       done
   else
      echo "[$(date '+%Y-%m-%d %H:%M:%S')] 不存在安装包"
      return 1
   fi
}
function clean_tmp() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] 清理临时目录"
    if [ -d "$originate_dir"/tmp/ ]; then
        local tmp_files=$(find "$originate_dir"/tmp/ | awk -F'/tmp/' '{print $2}' | grep -v '^$' | wc -l)
        if [ "$tmp_files" != 0 ]; then
            rm -rf "$originate_dir"/tmp/*
        fi
    elif [ ! -d "$originate_dir"/tmp/ ]; then
        mkdir "$originate_dir"/tmp/
    fi
}
function COLOR() {
red='\033[31m'
green='\033[32m'
yellow='\033[33m'
plain='\033[0m'
if [ "$1" == "red" ]; then
    printf "%s" "$red"
elif [ "$1" == "green" ]; then
    printf "%s" "$green"
elif [  "$1" == "yellow" ]; then
    printf "%s" "$yellow"
elif [  "$1" == "plain" ]; then
    printf "%s" "$plain"
else
     return 1
fi
}
function SetVariables() {
  variables_name=$1 #PATH
  variables_path=$2 #/usr/local/sbin/
  variables_file=$3 #file.txt
  if [ -n "$variables_name" ] && [ -n "$variables_path" ] && [ -n "$variables_file" ]; then
     echo "[$(date '+%Y-%m-%d %H:%M:%S')] Start setting variables..."
     if [ ! -f "$variables_file" ]; then
         mkdir -p "$variables_file"
     fi
     variables_path=$(echo "$variables_path" | tr -s '/')
     source "$variables_file"
     if [ -n "$variables_name" ];then
         sed -i "/^$variables_name=/d" "$variables_file"
         sed -i "/^export $variables_name=/d" "$variables_file"
         if [ "$variables_name" == "PATH" ]; then
            if [ -n "$PATH" ]; then
               echo "$variables_name=$variables_path:$PATH" >>"$variables_file"
               source "$variables_file"
               variables_filtering_1=$(echo "$PATH" | tr ":" "\n" | awk '{gsub(/\/+/,"/"); print}' | awk '!seen[$0]++' | tr "\n" ":") #clean  repeat /
               variables_filtering_2=$(echo "$variables_filtering_1" | tr ":" "\n" | awk '!seen[$0]++' | tr "\n" ":") #clean repeat path,awk -F ":"
               variables_filtering_3=$(echo "$variables_filtering_2" | tr ":" "\n" | awk '!seen[$0]++' | tr "\n" ":" |  sed 's/:*$//') #clean :: ,awk -F ":"
               sed -i "s|^${variables_name}=.*|${variables_name}=${variables_filtering_3}|g" "$variables_file"
            elif [ -z "$PATH" ]; then
                 echo "[$(date '+%Y-%m-%d %H:%M:%S')] variables PATH not found"
            fi
         else
            echo "$variables_name=$variables_path" >>"$variables_file"
         fi
     elif [ -z "$variables_name" ];then
          echo "$variables_name=$variables_path" >>"$variables_file"
     fi
     echo "[$(date '+%Y-%m-%d %H:%M:%S')] Finish setting variables..."
  else
     [ -z "$variables_name" ] && echo "[$(date '+%Y-%m-%d %H:%M:%S')] variables_name not found."
     [ -z "$variables_path" ] && echo "[$(date '+%Y-%m-%d %H:%M:%S')] variables_path not found."
     [ -z "$variables_file" ] && echo "[$(date '+%Y-%m-%d %H:%M:%S')] variables_file not found."
  fi
}
function install_depend(){
    service_name=$1
    # 依赖安装
    ## 循环计数器
    local count=0
    # 统计软件包数量
    local total=$(find "$originate_dir"/soft/depend/"$os_arch"/"$os"/"$service_name"/ | tail -n +2 | wc -l)
    # 查找软件包并循环安装
    for rpm in $(find "$originate_dir"/soft/depend/"$os_arch"/"$os"/"$service_name"/ | tail -n +2); do
        ((count++))
        # 更新进度条
        progress=$((count * 100 / total))
        echo -ne "依赖安装: $progress%   \r"
        if [ "$os" == "centos_7" ]; then
            rpm -Uvh --force "$rpm" 2>&1 | while IFS= read -r line; do echo "[$(date +'%Y-%m-%d %H:%M:%S')] $line"; done >> "$script_dir"/install.log
        elif [ "$os" == "ubuntu" ]; then
            dpkg -i "$rpm" 2>&1 | while IFS= read -r line; do echo "[$(date +'%Y-%m-%d %H:%M:%S')] $line"; done >> "$script_dir"/install.log
        fi
    done
    printf "\n"
}
function check_user_group(){
    local user=$1
    local group=$2
    printf "用户组{$group}"
    getent  group $group &>/dev/null
    if [ $? -eq 0 ];then
       printf "\033[0;32m[✔]\033[0m\n"
    else
       groupadd $group
       getent  group $group &>/dev/null
       if [ $? -eq 0 ];then
          printf "\033[0;32m[✔]\033[0m\n"
       fi
       printf "\033[0;31m[✘]\033[0m\n"
       return 1
    fi
    printf "用户{$user}"
    if ! id $user &>/dev/null;then
       useradd -s /sbin/nologin -g $group -N $user
        printf "\033[0;32m[✔]\033[0m\n"
    elif id $user &>/dev/null;then
       usermod -a -G $group $user
        printf "\033[0;32m[✔]\033[0m\n"
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
          printf "$script_dir/$script_path/script/$script_name/install.sh\t\t"
          if [ -f "$script_dir/$script_path/script/$script_name/install.sh" ] && [ -x "$script_dir/$script_path/script/$script_name/install.sh" ]; then
              printf "\033[0;32m[✔]\033[0m\n"
          else
              if [ -f "$script_dir/$script_path/script/$script_name/install.sh" ]; then
                  chmod +x "$script_dir/$script_path/script/$script_name/install.sh"
                  if [ -x "$script_dir/$script_path/script/$script_name/install.sh" ];then
                     printf "\033[0;32m[✔]\033[0m\n"
                  else
                     printf "\033[0;31m[×]\033[0m\n"
                  fi
              else
                 printf "\033[0;31m[×]\033[0m\n"
              fi
          fi
          bash "$script_dir/$script_path/script/$script_name/install.sh"
        else
          exit 1
       fi
    elif [ "$install_uninstall" == "uninstall" ]; then
       if [ "$script_path" == "soft" ]; then
         printf "$script_dir/$script_path/script/$script_name/uninstall.sh\t\t"
          if [ -f "$script_dir/$script_path/script/$script_name/uninstall.sh" ] && [ -x "$script_dir/$script_path/script/$script_name/uninstall.sh" ]; then
              printf "\033[0;32m[✔]\033[0m\n"
          else
              if [ -f "$script_dir/$script_path/script/$script_name/uninstall.sh" ]; then
                  chmod +x "$script_dir/$script_path/script/$script_name/uninstall.sh"
                  if [ -x "$script_dir/$script_path/script/$script_name/uninstall.sh" ];then
                     printf "\033[0;32m[✔]\033[0m\n"
                  else
                     printf "\033[0;31m[×]\033[0m\n"
                  fi
              else
                 printf "\033[0;31m[×]\033[0m\n"
              fi
          fi
          bash "$script_dir/$script_path/script/$script_name/uninstall.sh"
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
temp_return_select=0
while true; do
[ "$temp_return_select" -ne 0 ] && read -rp "[$(date '+%Y-%m-%d %H:%M:%S')] 回车返回主菜单"
let temp_return_select++
clear
main
done