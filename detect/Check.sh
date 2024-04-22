#!/bin/bash

script_dir=$(cd "$(dirname "$0")" && pwd)
source "$script_dir"/install.conf

function ProcessCheck() {
    local process=("$@")
    if [ "${#process[@]}" -ne 0 ];then
        for pro in "${process[@]}"
        do
          printf "残留进程检测\t\t"
          local check_outcome=($("$script_dir"/Command/"$os_arch"/"$os"/pgrep "$pro"))
          if [ "${check_outcome[@]}" -ne 0 ]; then
              if docker info &>/dev/null; then
                for docker_pid in $(docker ps -qa)
                do
                    GET_DockerServicePID+=("$docker_pid")
                done
                if [ "${#GET_DockerServicePID[@]}" -ne 0 ]; then
                    for ((i=0;i < "${#GET_DockerServicePID[@]}";i++))
                    do
                       DockerCheckOutcome=$(docker inspect --format '{{ .State.Pid }}' "${GET_DockerServicePID[$i]}")
                       if [ "$DockerCheckOutcome" != "$pro" ];then
                          unset "GET_DockerServicePID[$i]"
                       fi
                    done
                    if [ "${#GET_DockerServicePID[@]}" == 0 ];then
                       printf "\033[0;31m[✘]\033[0m\n"
                       echo "[$(date '+%Y-%m-%d %H:%M:%S')] 有残留进程卸载后再次执行脚本"
                       exit 1
                    else
                       printf "\033[0;32m[✔]\033[0m\n"
                    fi
                fi
              else
                printf "\033[0;31m[✘]\033[0m\n"
                echo "[$(date '+%Y-%m-%d %H:%M:%S')] 有残留进程卸载后再次执行脚本"
                exit 1
              fi
          else
              printf "\033[0;32m[✔]\033[0m\n"
          fi
        done
    fi
}
function PortCheck() {
    local ports=("$@")
    if [ "${#ports[@]}" -ne 0 ]; then
        for port in "${ports[@]}"
        do
          printf "端口占用检测\t\t"
          local PortCheckOutcome=($("$script_dir"/Command/"$os_arch"/"$os"/netstat -anp | grep "$port" | grep -v grep))
          if [ "${#check_outcome[@]}" -ne 0 ]; then
              printf "\033[0;31m[✘]\033[0m\n"
              echo "[$(date '+%Y-%m-%d %H:%M:%S')] 端口被占用检查后再次执行脚本"
              exit 1
          else
              printf "\033[0;32m[✔]\033[0m\n"
          fi
        done
    fi
}
function PathCheck() {
    local paths=("$@")
    for i in "${paths[@]}"
    do
      printf "$i\t\t"
      if [ -d "$i" ]; then
         printf "\033[0;31m[✘]\033[0m\n"
         echo "[$(date '+%Y-%m-%d %H:%M:%S')] 使用的目录已存在，请提前备份或执行卸载脚本清除环境"
      elif [ ! -d "$i" ]; then
          mkdir -p "$i"
          printf "\033[0;32m[✔]\033[0m\n"
      fi
    done
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
    for ((i=1; i<=1000; i++)); do
        dir=$i
        if [ -d "$config_path/unpack_file/$dir"  ] && [ "$(find $config_path/unpack_file/"$dir" |  wc -l )" -eq 1 ]; then
            missing_dirs=$dir
            let i+=1000
        elif [ ! -d "$config_path/unpack_file/$dir" ]; then
            mkdir "$config_path/unpack_file/$dir"
            missing_dirs=$dir
            let i+=1000
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
check_unpack_file_path)
                  shift
                  check_unpack_file_path
                  echo "$missing_dirs"
                  ;;
COLOR)
                 shift
                 COLOR "$1"
                 ;;
SetVariables)
                  shift
                  SetVariables "$@"
                  ;;
*)
                  echo "failed 404"
                  exit 1;
esac