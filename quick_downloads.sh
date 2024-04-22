#!/bin/bash

source ./download/download.env
function download() {
  download_path=$1
  DownloadUrl=("$@")
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] $download_path"
      for (( i = 0; url < "${#DownloadUrl[@]}"; i++ )); do
          GET_PackageVersion_1=$(echo "${DownloadUrl[$url]}" | grep -oE '[0-9]+\.[0-9]+\.[0-9]+')
          GET_PackageVersion_2=$(echo "${DownloadUrl[$url]}" | grep -oE '[0-9]+\.[0-9]+\.tar.gz+' | sed 's/\.tar\.gz$//')
          GET_PackageVersion_3=$(echo "${DownloadUrl[$url]}" | sed 's/.*\(jdk.*tar\.gz\)/\1/')
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
      if  [ "${#DownloadUrl[@]}" -ne 0 ];then
          read -rp "[$(date '+%Y-%m-%d %H:%M:%S')] Enter Your install service version choice：" y
      fi
      if [[ "$y" =~ ^[0-9]+$ ]] && [ -n "$url" ] ; then
          wget -P "$download_path" "${DownloadUrl[$y]}"
           if [ $? -eq 0 ];then
            echo "[$(date '+%Y-%m-%d %H:%M:%S')] 下载成功."
           else
            echo "[$(date '+%Y-%m-%d %H:%M:%S')] 下载失败."
            return 1
          fi
      else
          echo "[$(date '+%Y-%m-%d %H:%M:%S')] 输入错误."
          echo "[$(date '+%Y-%m-%d %H:%M:%S')] 下载失败."
          return 1
      fi
}
function download_menu() {
    while true; do
    clear
    echo "Download Menu"
    printf "%-20s %-20s\n" "1. nginx" "2. mysql5"
    printf "%-20s %-20s\n" "3. jdk" "4. docker"
    printf "%-20s %-20s\n" "5. docker_compose" "6. exit"

    read -rp "Enter your choice: " choice

    case $choice in
        1)
            shift
            download nginx_download_path "${nginx_download_url[@]}"
            ;;
        2)
            shift
            download mysql_download_path "${mysql_download_url[@]}"
            ;;
        3)
            shift
            download jdk_download_path "${jdk_download_url[@]}"
            ;;
        4)
            shift
            download docker_download_path "${docker_download_url[@]}"
            ;;
        5)
            shift
            download docker_compose_download_path "${docker_compose_download_url[@]}"
            ;;
        6)
           exit 0
           ;;
        *)
            echo "Invalid option. Please choose again."
            ;;
    esac
done
}

case $1 in
download)
   shift
   download "$@"
   ;;
 *)
   download_menu
   ;;
esac