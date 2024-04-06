#!/bin/bash

SystemCategory=''
SystemVersion=''
CPUArchitecture=''
controls=''
config_path=/tools
config_file=/tools/config
handle_error() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] 出现运行错误，解决后再次运行！错误码：$0 : $?"
    exit 1
}
trap handle_error ERR
function PACKAGE_MASTER() {
if command -v apt-get &> /dev/null; then
    controls='apt-get'
elif command -v yum &> /dev/null; then
    controls='yum'
else
    controls='N/A'
fi
}
function SYSTEM_CHECK() {
CPUArchitecture=$(uname -m)
SystemCategory=$(awk -F= '/^NAME/{print $2}' /etc/os-release)
if [  "$SystemCategory" == '"CentOS Linux"' ];then
SystemVersion="centos"
elif [ "$SystemCategory" == '"Ubuntu"' ];then
SystemVersion="ubuntu"
elif [ "$SystemCategory" == '"Debian GNU/Linux"' ];then
SystemVersion="debian"
elif [ "$SystemCategory" == '"Anolis OS"' ]; then
SystemVersion="Anolis OS"
else
SystemVersion=N/A
fi
}
PACKAGE_MASTER
SYSTEM_CHECK
function DIRECTIVES_CHECK() {
    if [ "$1" == 0 ]; then
       local NOTFONUDDIRECTIVES_EXEC=$1 #$1==0 repo install
       if [ -n "$2" ];then
           shift
           DIRECTIVES=("$@")
       fi
    else
       DIRECTIVES=("$@")

    fi
    GET_WHICH=$(command -v which | wc -l)
    if [ "${GET_WHICH}" != 0 ] && [ "${#DIRECTIVES[@]}" != 0 ]; then
        for i in "${DIRECTIVES[@]}"
        do
          which "$i" &>/dev/null
          if [ $? -ne 0  ]; then
              NOTFONUDDIRECTIVES+=("$i")
             [ "${#NOTFONUDDIRECTIVES[@]}" != 0 ] && printf  "%s\t" "$i"
          fi
        done
        printf "\tNot_installed.\n" #名称不可更改，调用时可根据该名称标注结尾
    else
      echo "The argument is empty or which is not found."
      exit 1
    fi
    if [ -n "$NOTFONUDDIRECTIVES_EXEC" ] && [ "$NOTFONUDDIRECTIVES_EXEC" -eq 0 ]; then
        for (( i = 0; i < "${#NOTFONUDDIRECTIVES[@]}"; i++ )); do
               $controls -y install "${NOTFONUDDIRECTIVES[$i]}"
               if [ $? -eq 0  ]; then
                   unset "NOTFONUDDIRECTIVES[$i]"
               fi
        done
        if [ "${#NOTFONUDDIRECTIVES[@]}" -ne 0 ]; then
              echo
              printf "Software Package："
              for (( i = 0; i < "${#NOTFONUDDIRECTIVES[@]}"; i++ )); do
                  printf "%s\t" "${NOTFONUDDIRECTIVES[$i]}"
              done
              printf "\t Installed_failed!"
              exit 1;
        fi
    fi

}
function SET_CONFIG() {
   source $config_file &>/dev/null
   if [ "$controls" != "N/A" ] && [ "$SystemVersion" != "N/A" ] && [ "$CPUArchitecture" == "x86_64" ] && [ -f "$config_file" ]; then
        GET_LOCAL_CONTROLS=$(grep -c 'controls=' $config_file)
        if [ "$GET_LOCAL_CONTROLS" == "1" ]; then
           sed -i "s/controls=.*/controls='$controls'/g" $config_file
        else
           echo -e "\n" >> "$config_file"
           echo "controls='$controls'" >> "$config_file"
        fi
        GET_LOCAL_CPUArchitecture=$(grep -c 'CPUArchitecture=' $config_file)
        if [ "$GET_LOCAL_CPUArchitecture" == "1" ]; then
            sed -i "s/CPUArchitecture=.*/CPUArchitecture='$CPUArchitecture'/g" $config_file
        else
            echo -e "\n" >> "$config_file"
            echo "CPUArchitecture='$CPUArchitecture'" >> $config_file
        fi
        GET_LOCAL_SystemVersion=$(grep -c 'SystemVersion=' $config_file)
        if [ "$GET_LOCAL_SystemVersion" == "1" ]; then
            sed -i "s/SystemVersion=.*/SystemVersion='$SystemVersion'/g" $config_file
        else
            echo -e "\n" >> "$config_file"
            echo "SystemVersion='$SystemVersion'" >> $config_file
        fi
        sed -i '/^$/d' $config_file &>/dev/null
   else
     if [ -f "$config_file" ]; then
        echo "[$(date '+%Y-%m-%d %H:%M:%S')] 不支持的版本"
        echo "[$(date '+%Y-%m-%d %H:%M:%S')] 软件包管理器：$controls"
        echo "[$(date '+%Y-%m-%d %H:%M:%S')] Linux系统版本：$SystemVersion"
        echo "[$(date '+%Y-%m-%d %H:%M:%S')] CPU架构：$CPUArchitecture"
        exit 1
    else
        echo "[$(date '+%Y-%m-%d %H:%M:%S')] $config_file not found."
        exit 1
     fi
   fi
}
function PROCESS_CHECK() {
    PROCESS_EXIST=()
    PROCESS_RESIDUE=()
    PROCESS_NAME=("$@")
    for i in "${PROCESS_NAME[@]}"
    do
        GET_PROCESS_NUM=$(ps aux | grep -v grep | grep -v "$0" | grep -c "$i" )
       if [ "$GET_PROCESS_NUM" -ne 0 ]; then
          PROCESS_EXIST+=("$i")
          printf "%s\t" "$i"
       fi
    done
     if [ -n "${PROCESS_EXIST[@]}" ] && [ "${#PROCESS_EXIST[@]}" -ne 0 ];then
       printf "PROCESS_EXIST\n"
    fi
    if [ "${#PROCESS_EXIST[@]}" -eq 0 ]; then
       for y in "${PROCESS_NAME[@]}"
       do
          GET_PROCESS_RESIDUE_ID=$(pgrep "$y")
          if [ -n "$GET_PROCESS_RESIDUE_ID"  ]; then
              PROCESS_RESIDUE+=("$y")
              printf "%s\t" "$y"
          fi
       done
     if [ -n "${PROCESS_EXIST[@]}" ] && [ "${#PROCESS_RESIDUE[@]}" -ne 0 ];then
       printf ",PROCESS_RESIDUE\n"
     fi
    fi
}
function PORT_CHECK() {
    GET_PORT=("$@")
    for i in "${GET_PORT[@]}"
    do
    CHECK_PORT_GET=$(netstat -tuln | grep -c "$i")
    if [ "$CHECK_PORT_GET" -ne 0 ]; then
        PORT_EXIST+=("$i")
        printf  "%s\t" "$i"
    fi
    done
    if [ "${#PORT_EXIST[@]}" -ne 0 ];then
      printf "：PORT_EXIST\n"
    fi
}
function PACKAGE_DOWNLOAD() {
    source $config_file &>/dev/null
    local ServerName=$1
    shift
    DownloadUrl=("$@")
    tr_s_variable_1=$(echo "/$download_path/$ServerName/" | tr -s '/')
    if [ -n "$tr_s_variable_1" ] && [ ! -d "$tr_s_variable_1" ];then
      mkdir -p "$tr_s_variable_1"
    fi
    for (( i = 0; i < "${#DownloadUrl[@]}"; i++ )); do
        GET_PackageVersion_1=$(echo "${DownloadUrl[$i]}" | grep -oE '[0-9]+\.[0-9]+\.[0-9]+')
        GET_PackageVersion_2=$(echo "${DownloadUrl[$i]}" | grep -oE '[0-9]+\.[0-9]+\.tar.gz+' | sed 's/\.tar\.gz$//')
        GET_PackageVersion_3=$(echo "${DownloadUrl[$i]}" | sed 's/.*\(jdk.*tar\.gz\)/\1/')
        if [ "${#GET_PackageVersion_1}" -ne 0 ]; then
          echo "$i : $GET_PackageVersion_1"
        elif [ "${#GET_PackageVersion_2}" -ne 0  ]; then
          echo "$i : $GET_PackageVersion_2"
        elif [ "${#GET_PackageVersion_3}" -ne 0  ]; then
          echo "$i : $GET_PackageVersion_3"
        else
          if [ -n "$ServerName"  ] && [ "${#DownloadUrl[@]}" -ne 0 ]; then
              echo "$i : 未识别的版本"
          fi
        fi
    done
    if [ -n "$ServerName"  ] && [ "${#DownloadUrl[@]}" -ne 0 ];then
      read -rp "Enter Your install service version choice：" y
    fi
    if [[ "$y" =~ ^[0-9]+$ ]] && [ "$i" -le "${#DownloadUrl[@]}" ] ; then
        tr_s_variable_2=$(echo "$download_path/$ServerName/$ServerName" | tr -s '/')
        if [ -f "$tr_s_variable_2" ]; then
           if [ -f "$tr_s_variable_2$(date +%Y%m%d)_bak" ];then
              rm -rf "$tr_s_variable_2$(date +%Y%m%d)_bak"
           else
            mv "$tr_s_variable_2" "$tr_s_variable_2$(date +%Y%m%d)_bak"
           fi
        fi
        wget -O "$tr_s_variable_2" "${DownloadUrl[$y]}"
        if [ ! -f "$tr_s_variable_2" ];then
          echo "[$(date '+%Y-%m-%d %H:%M:%S')] download failed."
          return 1
        fi
    elif [ -z "$y" ] && [ -f "$download_path/$ServerName/$ServerName" ] ; then
        echo "[$(date '+%Y-%m-%d %H:%M:%S')] Skip the installation."
    else
        echo "[$(date '+%Y-%m-%d %H:%M:%S')] Input Failed."
        return 1
    fi
}
function check_unpack_file_path() {
    if [ ! -d "$config_path"/unpack_file ];then
      mkdir -p "$config_path"/unpack_file
    fi
    getUnpackNumber=$(find "$config_path/unpack_file/" -maxdepth 1 -type f -o -type d | wc -l)
    if [ "$getUnpackNumber" -gt  11 ];then
      source $config_file &>/dev/null
      cd "$config_path"/ && tar cvf unpack_file_bak"$time".tar.gz unpack_file/*
      rm -rf unpack_file/*
      mv "$config_path"/unpack_file_bak* unpack_file/
    fi
    # 存放不存在的目录的变量
    missing_dirs=""
    # 检测并创建目录
    for ((i=1; i<=100; i++)); do
        dir=$i
        if [ -d "$config_path/unpack_file/$dir"  ] && [ "$(find $config_path/unpack_file/"$dir" |  wc -l )" -eq 1 ]; then
            missing_dirs=$dir
            let i+=100
        elif [ ! -d "$config_path/unpack_file/$dir" ]; then
            mkdir "$config_path/unpack_file/$dir"
            missing_dirs=$dir
            let i+=100
        fi
    done
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
            echo "$variables_name=$variables_path:$PATH" >>"$variables_file"
            source "$variables_file"
            variables_filtering_1=$(echo "$PATH" | tr ":" "\n" | awk '{gsub(/\/+/,"/"); print}' | awk '!seen[$0]++' | tr "\n" ":") #clean  repeat /
            variables_filtering_2=$(echo "$PATH" | tr ":" "\n" | awk '!seen[$0]++' | tr "\n" ":") #clean repeat path,awk -F ":"
            variables_filtering_3=$(echo "$PATH" | tr ":" "\n" | awk '!seen[$0]++' | tr "\n" ":" |  sed 's/:*$//') #clean :: ,awk -F ":"
            sed -i "s|^${variables_name}=.*|${variables_name}=${variables_filtering_3}|g" "$variables_file"
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
case $1 in
DIRECTIVES_CHECK)
                  shift
                  DIRECTIVES_CHECK "$@"
                  ;;
SET_CONFIG)
                  shift
                  SET_CONFIG
                  ;;
PACKAGE_MASTER)
                  shift
                  PACKAGE_MASTER
                  echo "$controls"
                  ;;
PROCESS_CHECK)
                  shift
                  PROCESS_CHECK "$@"
                  ;;
SYSTEM_CHECK)
                  shift
                  SYSTEM_CHECK
                  echo  "$SystemVersion"
                  ;;
PORT_CHECK)
                  shift
                  PORT_CHECK  "$@"
                  ;;
PACKAGE_DOWNLOAD)
                  shift
                  PACKAGE_DOWNLOAD "$@"
                  ;;
check_unpack_file_path)
                  shift
                  check_unpack_file_path
                  echo "$missing_dirs"
                  ;;
COLOR)
                 shift
                 COLOR "$1"
                 ;;
CPUArchitecture)
                  shift
                  SYSTEM_CHECK
                  echo "$CPUArchitecture"
                  ;;
SetVariables)
                  shift
                  SetVariables "$@"
                  ;;
*)
                  echo "failed 404"
                  exit 1;
esac