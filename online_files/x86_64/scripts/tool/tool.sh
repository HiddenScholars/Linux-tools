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