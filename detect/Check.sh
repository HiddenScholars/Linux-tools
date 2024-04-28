#!/bin/bash

originate_dir=$(pwd | awk -F '/Linux-tools' '{print $1 "/Linux-tools/"}')
script_dir=$(pwd | awk -F '/Linux-tools' '{print $1 "/Linux-tools" $2}')
source "$originate_dir"/install.conf

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
    #清理临时目录
    clean_tmp
    # 依赖安装
    tar xf "$originate_dir"/soft/depend/"$os_arch"/"$os"/"$service_name"/"$service_name"_depend.tar.gz -C "$originate_dir"/tmp/ --strip-components 1
    ## 循环计数器
    local count=0
    # 统计软件包数量
    local total=$(find "$originate_dir"/tmp/ | tail -n +2 | wc -l)
    # 查找软件包并循环安装
    for rpm in $(find "$originate_dir"/tmp/| tail -n +2); do
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
    getent  group "$group" &>/dev/null
    if [ $? -eq 0 ];then
       printf "\033[0;32m[✔]\033[0m\n"
    else
       groupadd "$group"
       getent  group "$group" &>/dev/null
       if [ $? -eq 0 ];then
          printf "\033[0;32m[✔]\033[0m\n"
       fi
       printf "\033[0;31m[✘]\033[0m\n"
       return 1
    fi
    printf "用户{$user}"
    if ! id "$user" &>/dev/null;then
       useradd -s /sbin/nologin -g "$group" -N "$user"
        printf "\033[0;32m[✔]\033[0m\n"
    elif id "$user" &>/dev/null;then
       usermod -a -G "$group" "$user"
        printf "\033[0;32m[✔]\033[0m\n"
    fi
}
case $1 in
PortCheck)
                  shift
                  PortCheck "$@"
                  ;;
ProcessCheck)
                  shift
                  ProcessCheck "$@"
                  ;;
PathCheck)
                  shift
                  PathCheck "$@"
                  ;;
clean_tmp)
                  shift
                  clean_tmp
                  ;;
check_package_version)
                  shift
                  check_package_version "$@"
                  ;;
COLOR)
                 shift
                 COLOR "$1"
                 ;;
SetVariables)
                  shift
                  SetVariables "$@"
                  ;;
install_depend)
                  shift
                  install_depend "$@"
                  ;;
check_user_group)
                  shift
                  check_user_group "$@"
                  ;;
*)
                  echo "failed 404"
                  ;;
esac