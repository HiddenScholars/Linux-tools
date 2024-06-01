#!/bin/bash
DIR=$(cd $(dirname $0) && pwd)


if [ -f $DIR/env/config.yaml ];then
  source $DIR/env/config.yaml
else
  echo "未找到config.yaml"
  exit 1
fi
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
                         echo "进程已存在"
                         exit 1
                      else
                         printf "\033[0;32m[ok]\033[0m\n"
                      fi
                  else
                    printf "\033[0;32m[ok]\033[0m\n"
                  fi
                else
                  printf "\033[0;31m[✘]\033[0m\n"
                  echo "进程已存在"
                  exit 1
                  if [ "$pro" == "$((${#process[@]}-1))" ];then
                     exit 1
                  fi
                fi
          else
                printf "\033[0;32m[ok]\033[0m\n"
            fi
          done
      else
        echo "未检测到进程参数"
      fi
}
function PortCheck() {
    local ports=("$@")
    if [ "${#ports[@]}" -ne 0 ]; then
        for (( p=0;p < ${#ports[@]};p++))
        do
          printf "${ports[$p]} 端口检测...\t\t"
          local PortCheckOutcome=($(netstat -tuln | grep ":${ports[$p]}")) # netstat -p参数非root下无法使用
          if [ "${#PortCheckOutcome[@]}" -ne 0 ]; then
              printf "\033[0;31m[✘]\033[0m\n"
              echo "端口已占用"
              exit
          else
              printf "\033[0;32m[ok]\033[0m\n"
          fi
        done
    else
      echo "未检测到端口参数"
    fi
}
function SetVariables() {
  variables_name=$1 #PATH_NAME
  variables_path=$2 #/usr/local/sbin/
  variables_file=$3 #file.txt
  if [ -n "$variables_name" ] && [ -n "$variables_path" ] && [ -n "$variables_file" ]; then
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
                 echo "variables PATH not found"
            fi
         else
            echo "$variables_name=$variables_path" >>"$variables_file"
         fi
     elif [ -z "$variables_name" ];then
          echo "$variables_name=$variables_path" >>"$variables_file"
     fi
  fi
}
function CreateNoLoginUserGroup() {
# 获取传入的用户名和组名
username=$1
groupname=$2
if [ -z "$username" ] || [ -z "$groupname" ]; then
    exit 1
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
function install() {
    if [ -z "$nginx_install_package_path" ] || [ ! -f "$nginx_install_package_path" ]; then
        if [ -z "$network_type"  ] || [ "$network_type" == "NULL" ]; then
           echo "安装包异常"
           exit 1
        fi
        NGINX_URL_FILE="url_address.txt"
        # 读取文件并提取版本信息
        declare -a urls
        declare -a versions
        index=1
        while IFS= read -r url; do
          urls[$index]="$url"
          version=$(echo "$url" | grep -oP 'nginx-\K[0-9]+\.[0-9]+\.[0-9]+')
          versions[$index]="$version"
          echo "$index) $version"
          ((index++))
        done < "$NGINX_URL_FILE"
        # 提示用户选择版本
        echo "请输入要下载的Nginx版本的序号："
        read -r selection
        # 检查用户输入是否有效
        if ! [[ "$selection" =~ ^[0-9]+$ ]] || [ "$selection" -lt 1 ] || [ "$selection" -ge "$index" ]; then
          echo "无效的选择"
          exit 1
        fi
        # 获取选择的URL
        selected_url="${urls[$selection]}"
        selected_version="${versions[$selection]}"
        # 下载选择的Nginx版本
        echo "正在下载Nginx $selected_version ..."
        wget -P "$download_dest_path" "$selected_url"
        if [ $? -eq 0 ]; then
          echo "下载完成，文件保存到 $download_dest_path"
          # !这里重要修改,这里若不修改 当中间件安装包保存路径和中间件安装包下载路径不一致时 会导致找不到安装包
          nginx_install_package_path=$download_dest_path/$(echo "$selected_url" | awk -F '/' '{print $NF}')
        else
          echo "下载失败"
          exit 1
        fi
    fi
    echo "开始安装"
    # 检测是否占用默认端口
    PortCheck 80
    # 检查是否占用默认进程名
    ProcessCheck nginx
    # 使用包管理器卸载nginx环境
    if [ "$controls" == "yum" ]; then
        if rpm -qa | grep nginx &>/dev/null; then
           rpm -e $(rpm -qa | grep nginx)
        fi
    else
        $controls remove -y "nginx*"
    fi
    # 依赖安装
    if [ "$nginx_depend_install" == "network" ];then
        if [ "$controls" == "yum" ]; then
            $controls install -y "${nginx_yum_depend_name[@]}"
        elif [ "$controls" == "apt" ]; then
            $controls install -y "${nginx_apt_depend_name[@]}"
        fi
    elif [ "$nginx_depend_install" == "local" ]; then
      if [ -n "$nginx_depend_path" ] && [ -d "$nginx_depend_path" ] && [ -n "$(ls -A $nginx_depend_path)" ]; then
         if [ "$controls" == "yum" ]; then
            $controls install -y "$nginx_depend_path"/*.rpm
         elif [ "$controls" == "apt" ];then
            $controls install -y "$nginx_depend_path"/*.deb
         fi
      fi
    fi
    # 检测安装路径处是否需要备份
    if [ -d "$soft_install_path/nginx/" ];then
        tar cf "$backup_path/$(date +"%Y%m%d_%H%M%S")nginx" $soft_install_path/nginx/
    fi
    # 检测用户和用户组是否存在,不存在则创建
    CreateNoLoginUserGroup $nginx_user $nginx_group
    # 前置准备完成开始操作安装包
    # 解压后进入安装目录开始编译安装
    local GET_NGINX_PATH_NAME=$(tar -tf "$nginx_install_package_path" | awk -F '/' '{print $1}' | awk NR==1)
    set -x
    sh -c "tar xf $nginx_install_package_path -C $soft_save_path"
    set +x
    cd "$soft_save_path/$GET_NGINX_PATH_NAME" || exit 1
    ./configure --prefix=$soft_install_path/nginx --user=$nginx_user --group=$nginx_group "${nginx_configure_option[@]}" && make && make install
    if [ $? -eq 0 ]; then
        echo "安装成功"
    else
        echo "安装失败"
        exit 1
    fi
    # 写入环境变量
    SetVariables PATH $soft_install_path/nginx/sbin/ /etc/profile
    source /etc/profile
    # 赋予目录权限
    chown -R $nginx_user:$nginx_group $soft_install_path/nginx/
    # 修改默认配置文件中启动用户
    sed -i "s/#user  nobody;/user $nginx_user;/" $soft_install_path/nginx/conf/nginx.conf
# 创建systemd服务文件
if [ -d /etc/systemd/system/ ];then
   mkdir -p /etc/systemd/system/
fi
cat <<EOF > /etc/systemd/system/nginx.service
[Unit]
Description=The NGINX HTTP and reverse proxy server
After=network.target

[Service]
Type=forking
ExecStart=$soft_install_path/nginx/sbin/nginx
ExecReload=$soft_install_path/nginx/sbin/nginx -s reload
ExecStop=$soft_install_path/nginx/sbin/nginx -s stop
PrivateTmp=true

[Install]
WantedBy=multi-user.target
EOF
# 启动nginx服务
if [ -f /etc/systemd/system/nginx.service ];then
    systemctl daemon-reload
    systemctl start nginx
    if [ $? -eq 0 ];then
        echo "nginx启动完成 nginx管理命令：systemctl start|stop|restart|status|enable|disable nginx"
        systemctl enable nginx

    else
        echo "nginx启动失败"
        exit 1
    fi
else
   echo "nginx.service 启动文件不存在"
   exit 1
fi
# 删除解压的目录
[ -d "$soft_save_path/$GET_NGINX_PATH_NAME" ] && rm -rf "$soft_save_path/$GET_NGINX_PATH_NAME"
}
function uninstall() {
echo "卸载开始"
if [ -f "/etc/systemd/system/nginx.service" ];then
   systemctl stop nginx &>/dev/null
   system disable nginx &>/dev/null
   systemctl daemon-reload
   rm -rf /etc/systemd/system/nginx.service
fi
pkill -f nginx
# 全盘搜索nginx目录并删除
find / -type d -name nginx | grep -v $DIR | xargs rm -rf
# 清除PATH中包含nginx的路径
source /etc/profile
original_PATH="$PATH"
new_PATH=""
IFS=: read -ra path_elements <<< "$PATH"
for element in "${path_elements[@]}"; do
  # 检查元素是否包含"nginx"，如果不包含，则添加到新的PATH中
  if [[ ! "$element" =~ .*nginx.* ]]; then
    new_PATH+=":$element"
  fi
done
new_PATH="${new_PATH#:}"
sed -i "s|PATH=.*|PATH=$new_PATH|" /etc/profile
source /etc/profile
# 删除创建的用户和用户组
RemoveNoLoginUserGroup $nginx_user $nginx_group
echo "卸载完成"
}

case $1 in
install|Install|INSTALL)
  shift 
  install "$@"
  ;;
uninstall|Uninstall|UNINSTALL)
  shift 
  uninstall "$@"
  ;;
*)
  echo "Usage: $0 {install|Install|INSTALL}"
  exit 1
  ;;
esac