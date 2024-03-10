#!/bin/bash


SystemCategory=''
SystemVersion=''
CPUArchitecture=''
controls=''
config_path=/tools
config_file=/tools/config
source $config_file
function PACKAGE_MASTER() {
if command -v apt-get &> /dev/null; then
    controls='apt-get'
elif command -v yum &> /dev/null; then
    controls='yum'
else
    controls=1
    return 1
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
else
SystemVersion=1
return 1
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
              return 1;
        fi
    fi

}
function SET_CONFIG() {
   if [ "$controls" != "1" ] && [ "$SystemVersion" != "1" ] && [ "$CPUArchitecture" == "x86_64" ] && [ -f "$config_file" ]; then
        GET_CONTROLS=$(grep -c 'controls=' $config_file)
        if [ "$GET_CONTROLS" == "1" ]; then
           sed -i "s/controls=.*/controls=$controls/g" $config_file
        else
           echo "controls=$controls" >> "$config_file"
        fi
        GET_CPUArchitecture=$(grep -c 'CPUArchitecture=' $config_file)
        if [ "$GET_CPUArchitecture" == "1" ]; then
            sed -i "s/CPUArchitecture=.*/CPUArchitecture=$GET_CPUArchitecture/g" $config_file
        else
            echo "CPUArchitecture=$GET_CPUArchitecture" >> $config_file
        fi
        GET_SystemVersion=$(grep -c 'SystemVersion=' $config_file)
        if [ "$GET_SystemVersion" == "1" ]; then
            sed -i "s/SystemVersion=.*/SystemVersion=$SystemVersion/g" $config_file
        else
            echo "SystemVersion=$SystemVersion" >> $config_file
        fi
   else
     if [ -f "$config_file" ]; then
        echo "不支持的版本"
        echo "软件包管理器：$controls"
        echo "Linux系统版本：$SystemVersion"
        echo "CPU架构：$CPUArchitecture"
        return 1
    else
        echo "$config_file not found."
        return 1
     fi
   fi
}
function PROCESS_CHECK() {
    PROCESS_NAME=("$@")
    for i in "${PROCESS_NAME[@]}"
    do
        GET_PROCESS_NUM=$(ps aux | grep -v grep | grep -v "$0" | grep -c "$i" )
       if [ "$GET_PROCESS_NUM" -ne 0 ]; then
          PROCESS_EXIST+=("$i")
          printf "%s\t" "$i"
       fi
    done
    [ "${#PROCESS_EXIST[@]}" -ne 0 ] && printf "PROCESS_EXIST\n"
    if [ "${#PROCESS_EXIST[@]}" -eq 0 ]; then
       for y in "${PROCESS_NAME[@]}"
       do
          GET_PROCESS_RESIDUE_ID=$(pgrep "$y")
          if [ -n "$GET_PROCESS_RESIDUE_ID"  ]; then
              PROCESS_RESIDUE+=("$y")
              printf "%s\t" "$y"
          fi
       done
    [ "${#PROCESS_RESIDUE[@]}" -ne 0 ] && printf ",PROCESS_RESIDUE\n"
    fi
}
function PORT_CHECK() {
    GET_PORT=("$@")
    for i in "${GET_PORT[@]}"
    do
    CHECK_PORT_GET=$(netstat -lnupt | grep -c "$i")
    if [ "$CHECK_PORT_GET" -ne 0 ]; then
        PORT_EXIST+=("$i")
        printf  "%s\t" "$i"
    fi
    done
    [ "${#PORT_EXIST[@]}" -ne 0 ] && printf "：PORT_EXIST\n"
}
function PACKAGE_DOWNLOAD() {
    local ServerName=$1
    shift
    DownloadUrl=("$@")
    [ ! -d "$download_path/$ServerName" ] &&  mkdir -p "$download_path/$ServerName"
    for (( i = 0; i < "${#DownloadUrl[@]}"; i++ )); do
        GET_PackageVersion_1=$(echo "${DownloadUrl[$i]}" | grep -oE '[0-9]+\.[0-9]+\.[0-9]+')
        GET_PackageVersion_2=$(echo "${DownloadUrl[$i]}" | grep -oE '[0-9]+\.[0-9]+\.tar.gz+' | sed 's/\.tar\.gz$//')
        if [ "${#GET_PackageVersion_1}" -ne 0 ]; then
          echo "$i : $GET_PackageVersion_1"
        elif [ "${#GET_PackageVersion_2}" -ne 0  ]; then
          echo "$i : $GET_PackageVersion_2"
        else
          if [ -n "$ServerName"  ] && [ "${#DownloadUrl[@]}" -ne 0 ]; then
              echo "$i : 未识别的版本"
          fi
        fi
    done
     [ -n "$ServerName"  ] && [ "${#DownloadUrl[@]}" -ne 0 ] && read -rp "Enter Your install service version choice：" y
    if [[ "$y" =~ ^[0-9]+$ ]] && [ "$i" -le "${#DownloadUrl[@]}" ] ; then
        wget -nc -P "$download_path/$ServerName" -O "$ServerName" "${DownloadUrl[$y]}"
        [ $? -eq 0 ] || echo "download failed." && return 1
    else
        echo "Input Failed."
        return 1
    fi
}
function check_unpack_file_path() {
    [ ! -d "$config_path"/unpack_file ] && mkdir -p "$config_path"/unpack_file
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
        if [ -d "$config_path/unpack_file/$dir"  ] && [ "$(find $config_path/unpack_file/"$dir" | grep -v $config_path/unpack_file/"$dir" | grep -v "$0" |  wc -l )" -eq 0 ]; then
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
*)
                  echo "failed 404"
                  exit 1;
esac