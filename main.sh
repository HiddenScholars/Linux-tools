#!/bin/bash

#全局变量
## 网络环境 具体地址：url_address 没有网络环境：null
network_env=''
## 系统版本
system=''
## 系统架构
##system_arch=''
## 包管理器
controls=''
## 安装包下载路径
download_path=''
## 存储下载下来的安装包名称,脚本内使用无需配置文件中持久存储
download_package_name=''
## 中间价安装路径
soft_install_path=''
## 内置下载链接使用判断 y: 确认 其他*: 输入的自定义链接
url_address_select=''
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
EOF
fi
if [ -f $config_name ]; then
    source "$config_name"
    printf "\n\n"
    [ -z "$download_path" ] && read -rp "初次使用,定义下载安装包存储路径: " download_path
    printf "安装包存储路径: "
    PathCheck "$download_path"
    printf "\n\n"
    [ -z "$soft_install_path" ] && read -rp "初次使用，定义中间件安装路径: " soft_install_path
    printf "中间件安装路径: "
    PathCheck "$soft_install_path"
    printf "\n\n"
    [ -z "$url_address_select" ] && read -rp "初次使用，设置是否使用内置下载链接(y/n): " url_address_select
    printf "\n"
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
# 检测错误信号
## 定义信号处理函数
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
          for ((pro=0;prot<"${#process[@]}";pro++))
          do
            printf "${process[$pro]} 进程检测...\t\t"
            local check_outcome=($(ps aux | grep "${process[$pro]}" | grep -v grep |  awk '{print $2}'))
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
                         echo "[$(date '+%Y-%m-%d %H:%M:%S')] 进程已存在"
                         return 1
                      else
                         printf "\033[0;32m[ok]\033[0m\n"
                      fi
                  fi
                else
                  printf "\033[0;31m[✘]\033[0m\n"
                  echo "[$(date '+%Y-%m-%d %H:%M:%S')] 进程已存在"
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
    echo "使用方法："
    printf "\t - SetVariables - 作用：设置环境变量，参数：[变量名] [路径] [写入的文件]\n"
    printf "\t - PathCheck - 作用：检测路径是否存在，参数：[路径] ...\n"
    printf "\t - PortCheck - 作用：检测端口占用情况，参数：[端口 端口 端口]，最少有一个参数，多个参数时通过使用数组的方式传入变量\n"
    printf "\t - ProcessCheck - 作用：检测进程是否存在，参数：[进程 进程 进程]，最少有一个参数，多个参数时通过使用数组的方式传入变量\n"
    printf "\t - Download - 作用：安装包下载，参数：[下载路径] [下载链接] ...\n"
    printf "\t - ConfigOutput -作用： 输出默认程序配置文件，将文件重定向到新的文件中使用\n"
    printf "\t - PathBackup - 作用：备份路径，参数：[备份路径] [备份文件]\n"
    printf "\t - InstallJdk -作用：安装jdk环境\n"
    printf "\t - menu - 作用：控制台输出菜单，通过菜单调用功能\n"
    printf "\n\n"
    ;;
  *)
    echo "缺少菜单级别参数"
    ;;
  esac
}
# 配置文件输出、重定向新文件直接使用、备忘录
function DefaultConfigOutput() {
    case $1 in
    nginx.conf|nginx)
cat << EOF
#user  nobody;
worker_processes  1;

#error_log  logs/error.log;
#error_log  logs/error.log  notice;
#error_log  logs/error.log  info;

#pid        logs/nginx.pid;


events {
    worker_connections  1024;
}


http {
    include       mime.types;
    default_type  application/octet-stream;

    #log_format  main  '$remote_addr - $remote_user [$time_local] "$request" '
    #                  '$status $body_bytes_sent "$http_referer" '
    #                  '"$http_user_agent" "$http_x_forwarded_for"';

    #access_log  logs/access.log  main;

    sendfile        on;
    #tcp_nopush     on;

    #keepalive_timeout  0;
    keepalive_timeout  65;

    #gzip  on;

    server {
        listen       80;
        server_name  localhost;

        #charset koi8-r;

        #access_log  logs/host.access.log  main;

        location / {
            root   html;
            index  index.html index.htm;
        }

        #error_page  404              /404.html;

        # redirect server error pages to the static page /50x.html
        #
        error_page   500 502 503 504  /50x.html;
        location = /50x.html {
            root   html;
        }

        # proxy the PHP scripts to Apache listening on 127.0.0.1:80
        #
        #location ~ \.php$ {
        #    proxy_pass   http://127.0.0.1;
        #}

        # pass the PHP scripts to FastCGI server listening on 127.0.0.1:9000
        #
        #location ~ \.php$ {
        #    root           html;
        #    fastcgi_pass   127.0.0.1:9000;
        #    fastcgi_index  index.php;
        #    fastcgi_param  SCRIPT_FILENAME  /scripts$fastcgi_script_name;
        #    include        fastcgi_params;
        #}

        # deny access to .htaccess files, if Apache's document root
        # concurs with nginx's one
        #
        #location ~ /\.ht {
        #    deny  all;
        #}
    }


    # another virtual host using mix of IP-, name-, and port-based configuration
    #
    #server {
    #    listen       8000;
    #    listen       somename:8080;
    #    server_name  somename  alias  another.alias;

    #    location / {
    #        root   html;
    #        index  index.html index.htm;
    #    }
    #}


    # HTTPS server
    #
    #server {
    #    listen       443 ssl;
    #    server_name  localhost;

    #    ssl_certificate      cert.pem;
    #    ssl_certificate_key  cert.key;

    #    ssl_session_cache    shared:SSL:1m;
    #    ssl_session_timeout  5m;

    #    ssl_ciphers  HIGH:!aNULL:!MD5;
    #    ssl_prefer_server_ciphers  on;

    #    location / {
    #        root   html;
    #        index  index.html index.htm;
    #    }
    #}

}
EOF
      ;;
   *)
      echo "缺少配置文件参数"
      ;;
    esac
}
# 目录检测，目录存在的进行重命名备份
function DirBackupCheck() {
  local dir_path=$1 #备份目录名
  local soft_name=$2 #软件名
  if [ -z "$dir_path" ];then
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] 缺少备份目录参数"
     return 1
  elif [ -z "$soft_name" ]; then
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] 缺少服务名称参数"
    return 1
  elif [ -z "$soft_install_path" ]; then
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] 缺少安装路径参数"
    while true; do
        read -rp "输入安装路径即检测路径(default: /usr/local/soft/): " path
        if [ -z "$path" ]; then
            path=/usr/local/soft/
        fi
        if [ -d "$path" ];then
          soft_install_path=$path
          break
        else
          echo "[$(date '+%Y-%m-%d %H:%M:%S')] 目录不存在"
        fi
    done
  fi
     if [ -d "$soft_install_path/$dir_path" ];then
        if [ -d "$soft_install_path/Backup$soft_name$(date '+%Y%m%d')" ]; then
          for (( i = 1; i < 10000; i++ )); do
              if [ ! -d "$soft_install_path/Backup$soft_name$(date '+%Y%m%d')$i" ]; then
                cd "$soft_install_path" && mv "Backup$soft_name$(date '+%Y%m%d')" "Backup$soft_name$(date '+%Y%m%d')$i"
                i=10000
              fi
          done
        fi
        cd "$soft_install_path" && mv "$dir_path" "Backup$soft_name$(date '+%Y%m%d')"
        bak_path=$(echo "$soft_install_path"/"Backup$soft_name"$(date '+%Y%m%d') | tr -s '/')
        echo "[$(date '+%Y-%m-%d %H:%M:%S')] 原始路径备份：$bak_path"
     elif [ ! -d "$soft_install_path/$dir_path" ]; then
        echo "[$(date '+%Y-%m-%d %H:%M:%S')] 目录不存在无需备份"
     fi
}
# 安装包下载
function Download() {
  trap 'handle_error $LINENO' ERR
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
          trap 'handle_error $LINENO' ERR
          if [ -n "$GET_PackageVersion_1"  ];then
            echo "$url : $GET_PackageVersion_1"
          elif [ -n "$GET_PackageVersion_2" ];then
            echo "$url : $GET_PackageVersion_2"
          elif [ -n "$GET_PackageVersion_3"  ];then
            echo "$url : $GET_PackageVersion_3"
          else
            echo "[$(date '+%Y-%m-%d %H:%M:%S')] 链接识别失败"
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
                download_package_name=$(echo "${DownloadUrl[$y]}" | awk -F'/' '{print $NF}')
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
      printf "https://nginx.org/download/nginx-1.22.1.tar.gz\n"
      printf "https://nginx.org/download/nginx-1.24.0.tar.gz\n"
      ;;
    jdk)
      printf "https://repo.huaweicloud.com/java/jdk/8u152-b16/jdk-8u152-linux-x64.tar.gz\n"
      ;;
    docker)
      printf "https://mirrors.tuna.tsinghua.edu.cn/docker-ce/linux/static/stable/x86_64/docker-17.03.0-ce.tgz\n"
      ;;
    docker-compose)
      printf "https://github.com/docker/compose/releases/download/v2.23.3/docker-compose-Linux-x86_64\n"
      ;;
    mysql)
      printf "https://downloads.mysql.com/archives/get/p/23/file/mysql-5.7.44-linux-glibc2.12-X86.tar.gz\n"
      printf "https://downloads.mysql.com/archives/get/p/23/file/mysql-5.7.43-linux-glibc2.12-x86.tar.gz\n"
      ;;
    *)
      echo "[$(date '+%Y-%m-%d %H:%M:%S')] 缺少参数"
      ;;
    esac
}
# 内置nginx安装脚本
function InstallNginx() {
    trap 'handle_error $LINENO' ERR
    [ -z "$url_address_select" ] && read -rp "是否使用脚本内置下载链接(y/n) (default: y): " url_address_select
    [ -z "$download_path" ] && read -rp "指定下载路径 (default: ./): " download_path
    [ -z "$url_address_select" ] && url_address_select=y
    if [ -z "$downloadPath" ];then
      downloadPath=$(dirname "$0")
    else
      download_path=$downloadPath
    fi
    case $url_address_select in
      y|Y)
        Download $(PackageDownloadUrl nginx)
        ;;
      *)
        read -rp "请输入下载链接-UrlAddress: " url_address_select
        Download "$url_address_select"
        ;;
    esac
}
# 内置jdk安装脚本
function InstallJdk() {
    trap 'handle_error $LINENO' ERR
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
    if [ -n "$package_name" ]; then
       download_package_name=$package_name
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
    $controls remove -y java* openjdk* &>/dev/null
    local GET_JDK_PATH_NAME=$(tar -tf "$download_package_name" | awk -F '/' '{print $1}' | awk NR==1)
    DirBackupCheck "$GET_JDK_PATH_NAME" jdk
    set -x
    cd "$download_path" && sh -c "tar xf $download_path/$download_package_name -C $soft_install_path"
    set +x
    SetVariables JAVA_HOME "$soft_install_path$GET_JDK_PATH_NAME" /etc/profile
    SetVariables PATH "$soft_install_path$GET_JDK_PATH_NAME/bin/" /etc/profile
    SetVariables CLASSPATH "$soft_install_path$GET_JDK_PATH_NAME/lib/dt.jar:$soft_install_path$GET_JDK_PATH_NAME/lib/tools.jar" /etc/profile
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
  InstallNginx)
    ArgsSet
    shift
    InstallNginx "$@"
    ;;
  InstallJdk|install_jdk)
    ArgsSet
    shift
    InstallJdk "$@"
    ;;
  UninstallJdk|uninstall_jdk)
    ArgsSet
    shift
    UninstallJdk "$@"
    ;;
  menu)
    shift
    ArgsSet
    ;;
  -h|-help|--help|help)
    Readme level_1
    ;;
  *)
    ArgsSet
    ;;
esac



#set +x