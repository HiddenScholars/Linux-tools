#!/bin/bash

version=2024-5-18
#全局变量
# 网络环境 具体地址：url_address 没有网络环境：null
network_env=''
# 脚本pid
SCRIPT_PID=$$
# 系统版本
system=''
# 系统架构
#system_arch=''
# 包管理器
controls=''
# 安装包下载路径
download_path=''
# 存储下载下来的安装包名称,脚本内使用无需配置文件中持久存储
download_package_path=''
# 软件安装路径
soft_install_path=''
# 内置下载链接使用判断 y: 确认 其他*: 输入的自定义链接
url_address_select=''
# nginx的所属用户
nginx_user='nginx'
# nginx的所属用户组
nginx_group='nginx'
# mysql的所属用户
mysql_user='mysql'
# mysql的所属用户组
mysql_group='mysql'
# mysql占用端口
mysql_port='13306'
# 全局参数设置 -必须执行
function ArgsSet() {
# 捕获 ERR 信号，并调用处理函数
trap 'handle_error $LINENO' ERR
config_name=~/.main.conf
printf "\n\n"
echo "[$(date '+%Y-%m-%d %H:%M:%S')] config: $config_name"
if [ ! -f $config_name ];then
cat << EOF > "$config_name"
network_env=''
system=''
controls=''
download_path=''
soft_install_path=''
url_address_select=''
nginx_user=nginx
nginx_group=nginx
mysql_user=mysql
mysql_group=mysql
mysql_password=''
mysql_port=13306
EOF
fi
if [ -f $config_name ]; then
    source "$config_name"
    printf "\n"
    if [ -z "$download_path" ] ;then
      read -rp "初次使用,定义下载安装包存储路径: " download_path
      printf "安装包存储路径: "
      download_path="$(cd $download_path && pwd)/"
      PathCheck "$download_path"
      printf "\n\n"
    fi
    if [ -z "$soft_install_path" ];then
      read -rp "初次使用，定义软件安装路径: " soft_install_path
      printf "中间件安装路径: "
      soft_install_path="$(cd $soft_install_path && pwd)/"
      PathCheck "$soft_install_path"
      printf "\n\n"
    fi
    if [ -z "$url_address_select" ];then
      read -rp "初次使用，设置是否使用内置下载链接(y/n): " url_address_select
      printf "\n"
    fi
fi
    check_env
    check_system
    sed -i "s|network_env=.*|network_env=$network_env|g" "$config_name"
    sed -i "s|system=.*|system=$system|g" "$config_name"
    sed -i "s|controls=.*|controls=$controls|g" "$config_name"
    sed -i "s|download_path=.*|download_path=$download_path|g" "$config_name"
    sed -i "s|soft_install_path=.*|soft_install_path=$soft_install_path|g" "$config_name"
    sed -i "s|url_address_select=.*|url_address_select=$url_address_select|g" "$config_name"
}
# 检测错误信号,定义信号处理函数
handle_error() {
    echo "错误发生在第 $1 行"
    exit 1
}
# 检测网络环境
function check_env() {
  local args_1=$1 # $1 == --nodeps 强制执行一遍
  if [ -z "$network_env" ]; then
      local ip1_address="https://www.github.com"
      local ip2_address="https://www.gitee.com"
      local check_address=("$ip1_address" "$ip2_address") #执行检测的地址
      local check_result=() #返回地址访问时间 单位：ms
      echo "[$(date '+%Y-%m-%d %H:%M:%S')] 网络环境检测..."
      for (( i = 0; i < ${#check_address[@]}; i++ )); do
          printf "$(echo "${check_address[$i]}" | awk -F '.' '{print $2}')..."
          for (( y = 0; y < 2; y++ )); do
              if ping -c 2 -W 2 "$(echo "${check_address[$i]}" | awk -F 'https://' '{print $2}')"  &>/dev/null; then #先进行域名解析测试，测试通过后curl进行计算请求耗时
                  #通过curl计算请求耗时
                  check_result+=("$(curl -s -m 5 -kIs -w "%{time_total}\n" -o /dev/null "${check_address[$i]}" | awk '{print int($1)}')")
                  #ping 方法计算耗时，太过浪费时间废弃使用
                  #check_result+=("$(ping "${check_address[$i]}" -c 1 -W 2 | grep 'bytes' | grep -v 'PING' | awk -F 'time=' '{print $2}' | awk '{print $1}' | awk -F '.' '{printf "%.0f\n", $1}')")
                  printf "\t\033[0;32m[ok]\033[0m\r"
                  break
              fi
              if [ "$y"  == "1" ]; then
                 printf "\t\033[0;31m[×]\033[0m\r"
                 y=$y+1
                 #check_result+=("null") #超过2次检测失败，返回null
              fi
          done
      done
      if [ "${#check_result[@]}" == 2 ]; then
            for (( tim = 0; tim < "${#check_result[@]}"; tim++ )); do
                if [ "${check_result[$tim]}" -gt "${check_result[$((${#check_result[@]}-1))]}" ]; then
                    echo "[$(date '+%Y-%m-%d %H:%M:%S')] 网络检测成功"
                    network_env="${check_address[$((${#check_result[@]}-1))]}"
                    break
                elif [ "${check_result[$tim]}" -lt "${check_result[$((${#check_result[@]}-1))]}" ]; then
                    echo "[$(date '+%Y-%m-%d %H:%M:%S')] 网络检测成功"
                    network_env="${check_address[$tim]}"
                    break
                elif [ "${check_result[$tim]}" == "${check_result[$((${#check_result[@]}-1))]}" ]; then
                    echo "[$(date '+%Y-%m-%d %H:%M:%S')] 网络检测成功"
                    network_env="${check_address[$tim]}"
                    break
                fi
            done
      elif [ "${#check_result[@]}" == 1 ]; then
           echo "[$(date '+%Y-%m-%d %H:%M:%S')] 网络检测成功"
           network_env="${check_address[0]}"
      else
           echo "[$(date '+%Y-%m-%d %H:%M:%S')] 无法连接到互联网，请稍后再试"
           network_env=null
      fi
  elif [ "$args_1" == "--nodeps" ]; then
      local ip1_address="https://www.github.com"
      local ip2_address="https://www.gitee.com"
      local check_address=("$ip1_address" "$ip2_address") #执行检测的地址
      local check_result=() #返回地址访问时间 单位：ms
      echo "[$(date '+%Y-%m-%d %H:%M:%S')] 网络环境检测..."
      for (( i = 0; i < ${#check_address[@]}; i++ )); do
          printf "$(echo "${check_address[$i]}" | awk -F '.' '{print $2}')..."
          for (( y = 0; y < 2; y++ )); do
              if ping -c 2 -W 2 "$(echo "${check_address[$i]}" | awk -F 'https://' '{print $2}')"  &>/dev/null; then #先进行域名解析测试，测试通过后curl进行计算请求耗时
                  #通过curl计算请求耗时
                  check_result+=("$(curl -s -m 5 -kIs -w "%{time_total}\n" -o /dev/null "${check_address[$i]}" | awk '{print int($1)}')")
                  #ping 方法计算耗时，太过浪费时间废弃使用
                  #check_result+=("$(ping "${check_address[$i]}" -c 1 -W 2 | grep 'bytes' | grep -v 'PING' | awk -F 'time=' '{print $2}' | awk '{print $1}' | awk -F '.' '{printf "%.0f\n", $1}')")
                  printf "\t\033[0;32m[ok]\033[0m\r"
                  break
              fi
              if [ "$y"  == "1" ]; then
                 printf "\t\033[0;31m[×]\033[0m\r"
                 y=$y+1
                 #check_result+=("null") #超过2次检测失败，返回null
              fi
          done
      done
      if [ "${#check_result[@]}" == 2 ]; then
            for (( tim = 0; tim < "${#check_result[@]}"; tim++ )); do
                if [ "${check_result[$tim]}" -gt "${check_result[$((${#check_result[@]}-1))]}" ]; then
                    echo "[$(date '+%Y-%m-%d %H:%M:%S')] 网络检测成功"
                    network_env="${check_address[$((${#check_result[@]}-1))]}"
                    break
                elif [ "${check_result[$tim]}" -lt "${check_result[$((${#check_result[@]}-1))]}" ]; then
                    echo "[$(date '+%Y-%m-%d %H:%M:%S')] 网络检测成功"
                    network_env="${check_address[$tim]}"
                    break
                elif [ "${check_result[$tim]}" == "${check_result[$((${#check_result[@]}-1))]}" ]; then
                    echo "[$(date '+%Y-%m-%d %H:%M:%S')] 网络检测成功"
                    network_env="${check_address[$tim]}"
                    break
                fi
            done
      elif [ "${#check_result[@]}" == 1 ]; then
           echo "[$(date '+%Y-%m-%d %H:%M:%S')] 网络检测成功"
           network_env="${check_address[0]}"
      else
           echo "[$(date '+%Y-%m-%d %H:%M:%S')] 无法连接到互联网，请稍后再试"
           network_env=null
      fi
  fi

}
# 检测系统
function check_system() {
  local check_system_result=''
      if [ -f /etc/os-release ]; then
          check_system_result=$(cat /etc/os-release | grep "^NAME=" | awk -F '"' '{print $2}' | awk '{print $1}')
          if [ "$check_system_result" == "CentOS" ]; then
              system=centos
          elif [ "$check_system_result" == "Debian" ]; then
              system=debian
          else
              system=null
              echo "[$(date '+%Y-%m-%d %H:%M:%S')] 暂不支持$check_system_result的发行版本"
              exit 1
          fi
      else
        echo "[$(date '+%Y-%m-%d %H:%M:%S')] 系统检测失败..."
        exit 1
      fi
      if [ "$(uname -m)" != "x86_64" ]; then
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
}
# 检测服务进程存活情况
function ProcessCheck() {
      local process=("$@")
      if [ "${#process[@]}" -ne 0 ];then
          for ((pro=0;pro<"${#process[@]}";pro++))
          do
            printf "${process[$pro]} 进程检测...\t\t"
            if [ "$(ps aux | grep "${process[$pro]}" | grep -v "$0" | grep -v grep |  awk '{print $2}' | wc -l)" -ne 0 ]; then
                local check_outcome=($(ps aux | grep "${process[$pro]}" | grep -v "$0" | grep -v grep |  awk '{print $2}'))
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
                      if [ "$temp_num" != ${#check_outcome[@]} ];then
                         printf "\033[0;31m[✘]\033[0m\n"
                         echo "[$(date '+%Y-%m-%d %H:%M:%S')] 进程已存在"
                         return 1
                      else
                         printf "\033[0;32m[ok]\033[0m\n"
                      fi
                  else
                    printf "\033[0;32m[ok]\033[0m\n"
                  fi
                else
                  printf "\033[0;31m[✘]\033[0m\n"
                  echo "[$(date '+%Y-%m-%d %H:%M:%S')] 进程已存在"
                  return 1
                  if [ "$pro" == "$((${#process[@]}-1))" ];then
                     return 1
                  fi
                fi
          else
                printf "\033[0;32m[ok]\033[0m\n"
            fi
          done
      else
        echo "[$(date '+%Y-%m-%d %H:%M:%S')] 未检测到进程参数"
      fi
}
# 检测端口占用情况
function PortCheck() {
    local ports=("$@")
    if [ "${#ports[@]}" -ne 0 ]; then
        for (( p=0;p < ${#ports[@]};p++))
        do
          printf "${ports[$p]} 端口检测...\t\t"
          local PortCheckOutcome=($(netstat -tuln | grep ":${ports[$p]}")) # netstat -p参数非root下无法使用
          if [ "${#PortCheckOutcome[@]}" -ne 0 ]; then
              printf "\033[0;31m[✘]\033[0m\n"
              echo "[$(date '+%Y-%m-%d %H:%M:%S')] 端口已占用"
              return
          else
              printf "\033[0;32m[ok]\033[0m\n"
          fi
        done
    else
      echo "[$(date '+%Y-%m-%d %H:%M:%S')] 未检测到端口参数"
    fi
}
# 检测路径是否存在,不存在尝试创建
function PathCheck() {
    local paths=("$@")
    if [ ${#paths[@]} != 0 ]; then
        for i in "${paths[@]}"
        do
          i=$(echo "$i" | tr -s '/')
          printf "$i\t\t"
          if [ -d "$i" ]; then
             printf "\033[0;32m[ok]\033[0m\n"

          elif [ ! -d "$i" ]; then
              if mkdir -p "$i" &>/dev/null;then
                 printf "\033[0;32m[ok]\033[0m\n"
              else
                 printf "\033[0;31m[✘]\033[0m\n"
                 echo "[$(date '+%Y-%m-%d %H:%M:%S')] 创建目录失败"
                 return 1
              fi
          fi
        done
    else
       echo "[$(date '+%Y-%m-%d %H:%M:%S')] 缺少路径参数"
    fi
}
# 设置变量
function SetVariables() {
  variables_name=$1 #PATH_NAME
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
# 使用功能自述
function Readme() {
  case $1 in
  level_1)
    printf "\n\n"
    echo "version: $version"
    echo "使用方法："
    printf "\t - SetVariables - 作用：设置环境变量，参数：[变量名] [路径] [写入的文件]\n"
    printf "\t - PathCheck - 作用：检测路径是否存在，参数：[路径] ...\n"
    printf "\t - PortCheck - 作用：检测端口占用情况，参数：[端口 端口 端口]，最少有一个参数，多个参数时通过使用数组的方式传入变量\n"
    printf "\t - ProcessCheck - 作用：检测进程是否存在，参数：[进程 进程 进程]，最少有一个参数，多个参数时通过使用数组的方式传入变量\n"
    printf "\t - Download - 作用：安装包下载，参数：[下载路径] [下载链接] ...\n"
    printf "\t - ConfigOutput -作用： 输出默认程序配置文件，将文件重定向到新的文件中使用\n"
    printf "\t - PathBackup - 作用：备份路径，参数：[备份路径] [备份文件]\n"
    printf "\t - install - 作用: 安装脚本支持的软件和服务\n"
    printf "\t - uninstall - 作用: 卸载脚本支持的软件和服务\n"
    printf "\t - menu - 作用：控制台输出菜单，通过菜单调用功能\n"
    printf "\n\n"
    ;;
  *)
    echo "缺少菜单级别参数"
    ;;
  esac
}
# 安装包下载
function Download() {
  DownloadUrl=("$@")
  if [ -z "$download_path" ]; then
      download_path=$(dirname "$0")
  elif [ ! -d "$download_path" ];then
      echo "[$(date '+%Y-%m-%d %H:%M:%S')] $download_path 不存在,尝试创建"
      if mkdir -p "$download_path"; then
          echo "[$(date '+%Y-%m-%d %H:%M:%S')] 创建成功"
      else
          echo "[$(date '+%Y-%m-%d %H:%M:%S')] 创建失败"
          return 1
      fi
  fi
  if [ ${#DownloadUrl[@]} == 0 ]; then
      echo "[$(date '+%Y-%m-%d %H:%M:%S')] 缺少下载参数"
      return 1
  fi
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] 安装包下载路径: [$download_path]"
      for (( url = 0; url < "${#DownloadUrl[@]}"; url++ ));do
          trap - ERR
          GET_PackageVersion_1=$(echo "${DownloadUrl[$url]}" | grep -oE '[0-9]+\.[0-9]+\.[0-9]+')
          GET_PackageVersion_2=$(echo "${DownloadUrl[$url]}" | grep -oE '[0-9]+\.[0-9]+\.tar.gz+' | sed 's/\.tar\.gz$//')
          GET_PackageVersion_3=$(echo "${DownloadUrl[$url]}" | awk -F'/' '{print $NF}')
          GET_UrlDomainName=$(echo "${DownloadUrl[$url]}" | awk -F'/' '{print $3}')
          trap 'handle_error $LINENO' ERR
          if [ -n "$GET_PackageVersion_1"  ];then
            printf "$url、$GET_PackageVersion_1 \t DomainName : $GET_UrlDomainName\n"
          elif [ -n "$GET_PackageVersion_2" ];then
            printf "$url、$GET_PackageVersion_2 \t DomainName : $GET_UrlDomainName\n"
          elif [ -n "$GET_PackageVersion_3"  ];then
            printf "$url、$GET_PackageVersion_3 \t DomainName : $GET_UrlDomainName\n"
          else
            echo "[$(date '+%Y-%m-%d %H:%M:%S')] 版本识别失败"
            return 1
          fi
      done
      while  true ; do
          if  [ "${#DownloadUrl[@]}" -ne 0 ];then
              read -rp "[$(date '+%Y-%m-%d %H:%M:%S')] Enter Your install service version choice：" y
          fi
          if [[ "$y" =~ ^[0-9]+$ ]] && [ -n "${DownloadUrl[$y]}" ] ; then
              [ -f "$download_path"/$(echo "${DownloadUrl[$y]}" | awk -F'/' '{print $NF}') ] && rm -rf $(echo "$download_path"/$(echo "${DownloadUrl[$y]}" | awk -F'/' '{print $NF}') | tr -s '/')
              wget -P "$download_path" "${DownloadUrl[$y]}"
               if [ $? -eq 0 ];then
                echo "[$(date '+%Y-%m-%d %H:%M:%S')] 下载成功."
                download_package_path=$(echo "$(cd $download_path && pwd)/${DownloadUrl[$y]}" | awk -F'/' '{print $NF}')
                break
               else
                echo "[$(date '+%Y-%m-%d %H:%M:%S')] 下载失败."
                return 1
              fi
          else
              echo "[$(date '+%Y-%m-%d %H:%M:%S')] 输入错误."
              #return 1
          fi
      done
}
# 内置安装包下载地址
function PackageDownloadUrl() {
    case $1 in
    nginx)
      printf "https://nginx.org/download/nginx-1.24.0.tar.gz\n"
      printf "https://nginx.org/download/nginx-1.22.1.tar.gz\n"
      ;;
    jdk) # uname -m | awk -F '_' '{print $2}' 获取32/64位版本号
      printf "https://repo.huaweicloud.com/java/jdk/8u152-b16/jdk-8u152-linux-x$(uname -m | awk -F '_' '{print $2}').tar.gz\n"
      ;;
    docker)
      printf "https://mirrors.tuna.tsinghua.edu.cn/docker-ce/linux/static/stable/$(uname -m)/docker-17.03.0-ce.tgz\n"
      ;;
    docker-compose)
      printf "https://github.com/docker/compose/releases/download/v2.23.3/docker-compose-Linux-$(uname -m)\n"
      ;;
    mysql)
      printf "https://dev.mysql.com/get/Downloads/MySQL-8.4/mysql-8.4.0-linux-glibc2.17-$(uname -m).tar.xz\n"
      printf "https://downloads.mysql.com/archives/get/p/23/file/mysql-5.7.44-linux-glibc2.12-$(uname -m).tar.gz\n"
      printf "https://downloads.mysql.com/archives/get/p/23/file/mysql-5.7.43-linux-glibc2.12-$(uname -m).tar.gz\n"
      ;;
    *)
      echo "[$(date '+%Y-%m-%d %H:%M:%S')] 缺少参数"
      ;;
    esac
}
# 内置创建不可登陆用户和用户组
function CreateNoLoginUserGroup() {
# 获取传入的用户名和组名
username=$1
groupname=$2
if [ -z "$username" ] || [ -z "$groupname" ]; then
    return 1
fi
# 检查用户组是否存在
if ! getent group "$groupname" &> /dev/null; then
    # 组不存在，创建组
    groupadd "$groupname"
fi
# 创建用户并指定用户组，同时设置为不可登录
if ! id "$username" &> /dev/null; then
    useradd -M  -g "$groupname" "$username" # -M 表示用户不可登录
fi
# 确保用户属于指定的组
if ! groups "$username" | grep -q "$groupname"; then
    usermod -a -G "$groupname" "$username"
fi
}
# 内置删除不可登录的用户和用户组
function RemoveNoLoginUserGroup() {
    local user="$1"
    local group="$2"
    if id "$user" &> /dev/null; then
        userdel -r "$user" &>/dev/null
    fi
    if getent group "$group" &>/dev/null;then
        local group_users=$(getent group "$group" | cut -d: -f4)
        if [ -z "$group_users" ]; then
            groupdel "$group" &>/dev/null
        fi
    fi
}
# install参数执行对应函数
function install() {
    case $1 in
    nginx|Nginx|NGINX)
      shift
      InstallNginx "$@"
      ;;
    jdk|Jdk|JDK)
      shift
      InstallJdk "$@"
      ;;
    mysql|Mysql|MYSQL)
      shift
      InstallMysql "$@"
      ;;
    *)
      echo "不支持的参数"
      return 1
    esac
}
# uninstall参数执行对应函数
function uninstall() {
    case $1 in
    jdk|Jdk|JDK)
      shift
      UninstallJdk "$@"
      ;;
    nginx|Nginx|NGINX)
      shift
      UninstallNginx "$@"
      ;;
    mysql|Mysql|MYSQL)
      shift
      UninstallMysql "$@"
      ;;
    *)
      echo "不支持的参数"
      return 1
    esac
}

# 内置jdk安装脚本
function InstallJdk() {
    # 报错后停止执行
    trap 'handle_error $LINENO' ERR
    # 变量检测
    local package_name=$1
    [ -z "$url_address_select" ] && read -rp "是否使用脚本内置下载链接(y/n) (default: y): " url_address_select
    [ -z "$download_path" ] && read -rp "指定下载路径 (default: ./): " download_path
    [ -z "$soft_install_path" ] && read -rp "指定安装路径 (default: /usr/local/): " soft_install_path
    [ -z "$soft_install_path" ] && soft_install_path="/usr/local/"
    [ -z "$url_address_select" ] && url_address_select=y
    if [ -z "$download_path" ];then
      download_path=$(dirname "$0")
    else
      download_path=$download_path
    fi
    # 检测是否传入了安装包,没有传入使用内置下载链接或指定连接下载安装包后安装
    if [ -n "$package_name" ]; then
       echo "[$(date '+%Y-%m-%d %H:%M:%S')] 使用 $package_name 安装包"
       download_package_path=$package_name
    elif [ -z "$package_name" ]; then
        case $url_address_select in
          y|Y)
            Download $(PackageDownloadUrl jdk)
            ;;
          *)
            read -rp "请输入下载链接-UrlAddress: " url_address_select
            Download "$url_address_select"
            ;;
        esac
    fi
    # 开始安装
    set -x
    sh -c "$controls remove -y java* openjdk* &>/dev/null"
    set +x
    local GET_JDK_PATH_NAME=$(tar -tf "$download_package_path" | awk -F '/' '{print $1}' | awk NR==1)
    # 检测是否需要备份
    DirBackupCheck "$GET_JDK_PATH_NAME" jdk
    # 解压安装包
    set -x
    cd "$download_path" && sh -c "tar xf $download_path/$download_package_path -C $soft_install_path"
    set +x
    # 设置变量
    SetVariables JAVA_HOME "$soft_install_path$GET_JDK_PATH_NAME" /etc/profile
    SetVariables PATH "$soft_install_path$GET_JDK_PATH_NAME/bin/" /etc/profile
    SetVariables CLASSPATH "$soft_install_path$GET_JDK_PATH_NAME/lib/dt.jar:$soft_install_path$GET_JDK_PATH_NAME/lib/tools.jar" /etc/profile
    # 验证安装结果
    source /etc/profile
    if java -version; then
        if javac -version; then
            echo "[$(date '+%Y-%m-%d %H:%M:%S')] 安装成功"
        else
            echo "[$(date '+%Y-%m-%d %H:%M:%S')] 安装失败"
        fi
    fi
}
# 内置jdk清除脚本
function UninstallJdk() {
trap 'handle_error $LINENO' ERR
echo "[$(date '+%Y-%m-%d %H:%M:%S')] 开始卸载"
"$controls" remove java* openjdk*  -y &>/dev/null
source /etc/profile
if [ -d "$JAVA_HOME" ]; then
    rm -rf "$JAVA_HOME"
fi
sed -i "\|export JAVA_HOME=.*|d" /etc/profile
sed -i "\|JAVA_HOME=.*|d" /etc/profile
sed -i "\|export CLASSPATH=.*|d" /etc/profile
sed -i "\|CLASSPATH=.*|d" /etc/profile
# 原始PATH保存
original_PATH="$PATH"

# 创建一个新的PATH变量，排除包含"jdk"的路径
new_PATH=""

# 使用IFS将PATH按冒号分割
IFS=: read -ra path_elements <<< "$PATH"

# 遍历PATH中的每个元素
for element in "${path_elements[@]}"; do
  # 检查元素是否包含"jdk"，如果不包含，则添加到新的PATH中
  if [[ ! "$element" =~ .*jdk.* ]]; then
    new_PATH+=":$element"
  fi
done

# 移除新PATH的第一个冒号，因为它是多余的
new_PATH="${new_PATH#:}"

# 替换结果
sed -i "s|PATH=.*|PATH=$new_PATH|" /etc/profile


# 如果需要，可以将新的PATH设置回环境变量
# 注意：在实际操作中，谨慎修改环境变量，特别是PATH，可能会影响到系统行为
# export PATH="$new_PATH"
echo "[$(date '+%Y-%m-%d %H:%M:%S')] 卸载完成"
}
# 内置mysql安装脚本
function InstallMysql() {
    # 报错后停止执行
    trap 'handle_error $LINENO' ERR
    # 变量检测
    local package_name=$1
    [ -z "$url_address_select" ] && read -rp "是否使用脚本内置下载链接(y/n) (default: y): " url_address_select
    [ -z "$download_path" ] && read -rp "指定下载路径 (default: ./): " download_path
    [ -z "$soft_install_path" ] && read -rp "指定安装路径 (default: /usr/local/): " soft_install_path
    [ -z "$soft_install_path" ] && soft_install_path="/usr/local/"
    [ -z "$url_address_select" ] && url_address_select=y
    if [ -z "$download_path" ];then
      download_path=$(dirname "$0")
    else
      download_path=$download_path
    fi
    # 检测是否传入了安装包,没有传入使用内置下载链接或指定连接下载安装包后安装
    if [ -n "$package_name" ]; then
       echo "[$(date '+%Y-%m-%d %H:%M:%S')] 使用 $package_name 安装包"
       download_package_path=$package_name
    elif [ -z "$package_name" ]; then
        case $url_address_select in
          y|Y)
            Download $(PackageDownloadUrl mysql)
            ;;
          *)
            read -rp "请输入下载链接-UrlAddress: " url_address_select
            Download "$url_address_select"
            ;;
        esac
    fi
    # 开始安装
    # 卸载mysql和mariadb环境
    set -x
    sh -c "$controls remove -y mysql* mariadb* &>/dev/null"
    set +x
    # 检测端口是否被占用
    PortCheck $mysql_port
    # 检测进程是否被占用
    ProcessCheck mysql mariadb
    # 检测安装包是否符合要求
#    local GET_PACKAGE_GLIBC_VERSION=$(echo "$download_package_path" | grep -oE 'glibc([0-9]+\.[0-9]+)' | grep -oE '([0-9]+\.[0-9]+)')
#    if [ -n "$GET_PACKAGE_GLIBC_VERSION" ]; then
#       if [ "$GET_PACKAGE_GLIBC_VERSION" == "$(ldd --version | grep ldd | awk '{print $4}')" ]; then
#          echo "[$(date '+%Y-%m-%d %H:%M:%S')] 安装包glibc校验完成"
#       else
#          echo "[$(date '+%Y-%m-%d %H:%M:%S')] 安装包glibc版本错误,无法安装"
#          return 1
#       fi
#    else
#       echo "[$(date '+%Y-%m-%d %H:%M:%S')] 获取安装包glibc版本失败"
#       return 1
#    fi
    # 检测mysql 8 or 5
    local GET_PACAKGE_NAME_VERSION=$(echo "$download_package_path" | awk -F '.' '{print $1}' | awk -F '-' '{print $2}')
    # 检测是否需要备份
    local GET_MYSQL_PATH_NAME=$(tar -tf "$download_package_path" | awk -F '/' '{print $1}' | awk NR==1)
    DirBackupCheck mysql mysql
    # 创建mysql用户
    CreateNoLoginUserGroup $mysql_user $mysql_group
    # 解压安装包
    # 安装包+安装路径 去除多余'/'
    if [ -f ./$download_package_path ];then
       download_package_path=$(echo "./$download_package_path" | tr -s '/')
       echo "[$(date '+%Y-%m-%d %H:%M:%S')] 安装包路径: $download_package_path"
    elif [ -f $download_path/$download_package_path ];then
       download_package_path=$(echo "$download_path/$download_package_path" | tr -s '/')
       echo "[$(date '+%Y-%m-%d %H:%M:%S')] 安装包路径: $download_package_path"
    else
      echo "[$(date '+%Y-%m-%d %H:%M:%S')] 安装包未找到"
      return 1
    fi
    # 创建解压目标目录
    PathCheck "$soft_install_path/mysql/"
    # 解压路径+mysql 去除多余'/'
    local tar_xf_path=$(echo "$soft_install_path/mysql/" | tr -s '/')
    # 安装路径+安装包解压后顶级目录 去除多余'/'
    local src_path=$(echo "$soft_install_path/mysql/$GET_MYSQL_PATH_NAME" | tr -s '/')
    # 安装路径+mysql+安装顶级目录改名为mysql目录 去除多余'/'
    local dst_path=$(echo "$soft_install_path/mysql/mysql/" | tr -s '/')
    set -x
    sh -c "tar xf $download_package_path -C  $tar_xf_path" \
    && mv $src_path $dst_path
    set +x
if [ -d "$dst_path" ]; then
        local mysql_install_path=$(echo "/$soft_install_path"/mysql/mysql/ | tr -s '/')
        local mysql_install_path_bin=$(echo "/$soft_install_path"/mysql/mysql/bin/ | tr -s '/')
        local mysql_socket_path=$(echo "/$soft_install_path"/mysql/mysql/mysql.sock | tr -s '/')
        local mysql_data_path=$(echo "/$soft_install_path"/mysql/mysqldata$mysql_port/ | tr -s '/')
        local mysql_log_error_path=$(echo "/$soft_install_path"/mysql/logs/mysqld.log | tr -s '/')
        local mysql_pid_path=$(echo "/$soft_install_path"/mysql/mysql/mysql.pid | tr -s '/')
        local my_cnf_path=$(echo "/$soft_install_path"/mysql/etc/my.cnf | tr -s '/')
        # 设置变量
        SetVariables PATH "$soft_install_path/mysql/mysql/bin/" /etc/profile
        source /etc/profile
        # 检测路径是否存在,不存在则创建
        PathCheck "$mysql_install_path" "$mysql_install_path_bin" "$mysql_data_path" "/$soft_install_path/mysql/logs/" $soft_install_path/mysql/etc/
# 更改名称备份mysql默认读取的my.cnf,防止配置冲突
# 定义备份前缀
BACKUP_PREFIX="my.cnf.backup."
# 常见的my.cnf路径
CONF_PATHS=($(find / -name my.cnf))
# 遍历每个路径
for path in "${CONF_PATHS[@]}"; do
  # 检查路径是否为文件且存在
  if [[ -f "$path" ]]; then
    # 获取绝对路径
    abs_path=$(readlink -f "$path")
    # 创建初始备份文件名
    backup_file="$abs_path.$BACKUP_PREFIX$(date +%Y%m%d%H%M%S)"
    # 循环直到找到一个可用的备份文件名
    while [[ -e "$backup_file" ]]; do
      # 提取数字后缀（如果有）
      num_suffix=$(basename "$backup_file" | grep -o -E '\d+$')
      # 如果没有数字后缀，添加一个
      if [[ -z "$num_suffix" ]]; then
        num_suffix="1"
      else
        # 递增后缀
        ((num_suffix++))
      fi
      # 更新备份文件名
      backup_file="${abs_path}.${BACKUP_PREFIX}${num_suffix}"
    done
    # 移动原文件并创建备份
    mv "$abs_path" "$backup_file"
  fi
done

# 创建my.cnf文件
cat << EOF > $soft_install_path/mysql/etc/my.cnf
[mysql]
socket=$mysql_socket_path
[mysqld]
socket=$mysql_socket_path
port=$mysql_port
basedir=$mysql_install_path
datadir=$mysql_data_path
lower_case_table_names=0
max_connections=200
character-set-server=utf8
max_allowed_packet=16M
explicit_defaults_for_timestamp=true
log-error=$mysql_log_error_path
pid-file=$mysql_pid_path
[mysql.server]
user=$mysql_user
basedir=$mysql_install_path
EOF
       # 更改mysql程序目录所属用户和组
       chown -R $mysql_user:$mysql_group "$soft_install_path/mysql/"
       # 更改my.cnf执行权限
       chmod 644 "$soft_install_path/mysql/etc/my.cnf"
       # 数据库初始化 --initialize 参数带有随机密码  --initialize-insecure 该参数将以root空密码方式创建
       set -x
       sh -c "mysqld --defaults-file=$my_cnf_path --initialize --user=$mysql_user"
       set +x
       local GET_MYSQL_TEMP_PASSWORD=$(cat "$mysql_log_error_path" | grep 'temporary password' | awk '{print $NF}')
       echo "[$(date '+%Y-%m-%d %H:%M:%S')] 初始化完成随机密码: $GET_MYSQL_TEMP_PASSWORD"
       # 数据库初始化完成,启动程序
       mysqld_safe --defaults-file=$soft_install_path/mysql/etc/my.cnf &
       if [ $? -eq 0 ];then
          echo "[$(date '+%Y-%m-%d %H:%M:%S')] 启动成功"
       else
          echo "[$(date '+%Y-%m-%d %H:%M:%S')] 启动失败"
          return 1
       fi
       # 数据库初始化sql,重置密码
       # 判断数据库密码
       if [ -z "$mysql_password" ];then
         mysql_password=$GET_MYSQL_TEMP_PASSWORD
         echo "[$(date '+%Y-%m-%d %H:%M:%S')] 未指定数据库密码,延续使用临时密码"
       else
         echo "[$(date '+%Y-%m-%d %H:%M:%S')] 使用指定数据库密码"
       fi
        #倒计时9秒等待数据库启动
        local total_seconds=9
        for ((i=$total_seconds; i>=1; i--)); do
            sleep 1
            printf "%d\r" "$i"
        done
        printf "\r"
        echo "[$(date '+%Y-%m-%d %H:%M:%S')] 执行mysql初始化SQL,创建root远程账号,赋予该账号任何机器都可以远程权限并授权所有的库的操作权限..."
        local sql_list1="ALTER USER 'root'@'localhost' IDENTIFIED BY  '$mysql_password';"
        local sql_list2="CREATE USER 'root'@'%' IDENTIFIED BY '$mysql_password';"
        local sql_list3="GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' WITH GRANT OPTION;"
        local sql_list4="flush privileges;"
        mysql -u root -p"$GET_MYSQL_TEMP_PASSWORD" --socket="$mysql_socket_path" --connect-expired-password -e "$sql_list1"
        # 初始化完成后修改登录密码为: $mysql_password变量
        mysql -u root -p"$mysql_password" --socket="$mysql_socket_path" --connect-expired-password -e "$sql_list2"
        mysql -u root -p"$mysql_password" --socket="$mysql_socket_path" --connect-expired-password -e "$sql_list3"
        mysql -u root -p"$mysql_password" --socket="$mysql_socket_path" --connect-expired-password -e "$sql_list4"
        echo "[$(date '+%Y-%m-%d %H:%M:%S')] 关闭root启动mysqld_safe更换成$mysql_user启动"
        mysqladmin -u root -p"$mysql_password" shutdown --socket="$mysql_socket_path"
    else
        echo "[$(date '+%Y-%m-%d %H:%M:%S')] $dst_path 目录不存在"
        return 1
fi
# 设置启动程序
# 设置变量
cat <<EOF > /etc/rc.d/init.d/mysqld
#!/bin/bash

mysql_user=$mysql_user
mysql_group=$mysql_group
mysql_password='$mysql_password'
PID=$mysql_pid_path
socket=$mysql_socket_path
cnf_path=$(echo "/$soft_install_path"/mysql/etc/my.cnf | tr -s '/')
command_mysqld_safe=$(echo $mysql_install_path/bin/mysqld_safe | tr -s '/')
command_mysqladmin=$(echo $mysql_install_path/bin/mysqladmin | tr -s '/')

EOF
cat <<'EOF' >> /etc/rc.d/init.d/mysqld
function start() {
    printf "正在启动请稍候..."
    if [ ! -f $PID ];then
       $command_mysqld_safe --defaults-file=$cnf_path --user=$mysql_user >/dev/null &
       if [ $? -eq 0 ];then
          sleep 10
          printf "\t启动成功\n"
       else
          printf "\t启动失败,请查看mysqld_safe.log\n"
       fi
    else
       printf "\t已经启动,不再执行启动操作\n"
    fi
}
function stop(){
    printf "正在停止请稍候..."
    if [ -f $PID ];then
       $command_mysqladmin -u root -p"$mysql_password" shutdown --socket=$socket &>/dev/null
       if [ $? -eq 0 ];then
          sleep 10
          printf "\t停止成功\n"
       else
          printf "\t停止失败\n"
       fi
    else
       printf "\t已经关闭,不再执行关闭操作\n"
    fi
}
function status(){
    if [ -f $PID ];then
        echo "MySQL is running."
    else
        echo "MySQL is not running."
    fi
}
function restart(){
    stop
    start
}
case $1 in
start)
    start
    ;;
stop)
    stop
    ;;
status)
    status
    ;;
restart)
    restart
    ;;
*)
    echo "mysqld [参数] args: start|stop|restart"
    ;;
esac
EOF
chmod +x /etc/rc.d/init.d/mysqld && chown $mysql_user:$mysql_group /etc/rc.d/init.d/mysqld
cat << EOF > /etc/systemd/system/mysqld.service
[Unit]
Description=MySQL Community Server
After=network.target
[Service]
Type=forking
User=$mysql_user
Group=$mysql_group

PIDFile=$mysql_pid_path
ExecStart=/etc/init.d/mysqld start
ExecReload=/etc/init.d/mysqld restart
ExecStop=/etc/init.d/mysqld stop

TimeoutSec=600
Restart=on-failure
PrivateTmp=true

[Install]
WantedBy=multi-user.target
EOF
sudo systemctl daemon-reload
sudo systemctl start mysqld
echo -e "\033[32m安装完成 远程端口: $mysql_port 最终登陆密码: $mysql_password\033[0m"
echo -e "\033[32mmysql管理命令 systemctl start|stop|restart|status|enable|disable mysqld\033[0m"
}
# 内置mysql卸载脚本
function UninstallMysql() {
echo "[$(date '+%Y-%m-%d %H:%M:%S')] 卸载开始"
if [ -f "/etc/systemd/system/mysql.service" ];then
  systemctl stop mysql.service
  systemctl disable mysql.service &>/dev/null
  systemctl daemon-reload
  rm -rf /etc/systemd/system/mysql.service
fi
if [ -f "/etc/systemd/system/mysqld.service" ];then
   systemctl stop mysqld.service
   systemctl disable mysqld.service &>/dev/null
   systemctl daemon-reload
   rm -rf /etc/systemd/system/mysqld.service
fi
[ -f "/etc/rc.d/init.d/mysqld" ] && rm -rf /etc/rc.d/init.d/mysqld
#检测是否存在mysqld_safe进程, 存在的话记录mysqld_safe的进程id, 杀死进程
MYSQLD_SAFE_PID=$(ps -ef | grep mysqld_safe | grep -v grep | awk '{print $2}')
if [ -n "$MYSQLD_SAFE_PID" ]; then
  kill -9 $MYSQLD_SAFE_PID
fi
#检测是否存在mysqld进程, 存在的话记录mysqld的进程id, 杀死进程
MYSQLD_PID=$(ps -ef | grep mysqld | grep -v mysqld_safe | grep -v grep | awk '{print $2}')
if [ -n "$MYSQLD_PID" ]; then
  kill -9 $MYSQLD_PID
fi
# 检测进程中是否能检索到my.cnf文件路径, 能检测到的话记录下mysql的安装路径
local MYCNF_PATHS=($(find / -name my.cnf))
if [ ${#MYCNF_PATHS[@]} -gt 0 ]; then
  for MYCNF_PATH in "${MYCNF_PATHS[@]}"; do
    local MYSQL_BASEDIR=$(grep -i 'basedir' $MYCNF_PATH | awk -F'=' '{print $2}' | tr -d ' '| awk 'NR==1')
	  local MYSQL_DATADIR=$(grep -i 'datadir' $MYCNF_PATH | awk -F'=' '{print $2}' | tr -d ' '| awk 'NR==1')
	  local MYSQL_LOGS_ERROR=$(grep -i 'log-error' $MYCNF_PATH | awk -F'=' '{print $2}' | tr -d ' '| awk 'NR==1')
	  # 检测mysql安装的上一级路径是否存在文件没有文件进行删除
    local GET_UPPER_LEVEL=$(cd $MYSQL_BASEDIR && cd .. && pwd)
    # 删除my.cnf路径
    rm -rf "$(dirname $MYCNF_PATH)"
    # 删除mysql安装路径
    if [ -n "$MYSQL_BASEDIR" ]; then
       [ -d "$MYSQL_BASEDIR" ] && rm -rf "$MYSQL_BASEDIR"
    fi
    # 删除mysql数据路径
    if [ -n "$MYSQL_DATADIR" ]; then
       [ -d "$MYSQL_DATADIR" ] && rm -rf "$MYSQL_DATADIR"
    fi
    # 删除mysql日志路径
    if [ -n "$MYSQL_LOGS_ERROR" ]; then
       [ -f "$MYSQL_LOGS_ERROR" ] && rm -rf "$(dirname $MYSQL_LOGS_ERROR)"
    fi
    if [ -d "$GET_UPPER_LEVEL" ];then
       if [ -z "$(ls -A "$GET_UPPER_LEVEL")" ]; then
         rm -rf "$GET_UPPER_LEVEL"
       fi
    fi
  done
fi
source /etc/profile
sudo sed -i '/^MYSQL_HOME=/d' /etc/profile
sudo sed -i '/^mysql_home=/d' /etc/profile
# 清除PATH中包含mysql的路径
original_PATH="$PATH"
new_PATH=""
IFS=: read -ra path_elements <<< "$PATH"
for element in "${path_elements[@]}"; do
  # 检查元素是否包含"mysql"，如果不包含，则添加到新的PATH中
  if [[ ! "$element" =~ .*mysql.* ]]; then
    new_PATH+=":$element"
  fi
done
new_PATH="${new_PATH#:}"
sed -i "s|PATH=.*|PATH=$new_PATH|" /etc/profile
source /etc/profile
# 删除创建的用户和用户组
RemoveNoLoginUserGroup $mysql_user $mysql_group
echo "[$(date '+%Y-%m-%d %H:%M:%S')] 卸载完成"
}
case $1 in
 PathBackup)
   ArgsSet
   shift
   DirBackupCheck "$@"
   ;;
 ConfigOutput)
   ArgsSet
   shift
   DefaultConfigOutput "$@"
    ;;
  Download)
    ArgsSet
    shift
    Download "$@"
    ;;
  SetVariables)
    ArgsSet
    shift
    SetVariables "$@"
    ;;
  PathCheck)
    ArgsSet
    shift
    PathCheck "$@"
    ;;
  PortCheck)
    ArgsSet
    shift
    PortCheck "$@"
    ;;
  ProcessCheck)
    ArgsSet
    shift
    ProcessCheck "$@"
    ;;
  install)
    ArgsSet
    shift
    install "$@"
    ;;
  uninstall)
    ArgsSet
    shift
    uninstall "$@"
    ;;
  menu)
    shift
    ArgsSet
    ;;
  -h|-help|--help|help)
    Readme level_1
    ;;
  *)
    check_env --nodeps #强制检查一遍网络
    ArgsSet
    ;;
esac



#set +x