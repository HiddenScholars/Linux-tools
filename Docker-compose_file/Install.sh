#!/bin/bash

source /tools/config
echo "[$(date '+%Y-%m-%d %H:%M:%S')] 开始检测环境"
CHECK_DOCKER_PROFILE=($(curl -sl https://"$url_address"/HiddenScholars/Linux-tools/"$con_branch"/Check/Check.sh | bash -s -- DIRECTIVES_CHECK docker docker-compose))
for i in "${CHECK_DOCKER_PROFILE[@]}"
do
if [ "$i" == "docker" ]; then
   echo "[$(date '+%Y-%m-%d %H:%M:%S')] 开始安装Docker"
   bash <(curl -sL https://"$url_address"/HiddenScholars/Linux-tools/"$con_branch"/InstallFile/Install_docker.sh)
    if [ "$i" == "docker-compose" ]; then
       echo "[$(date '+%Y-%m-%d %H:%M:%S')] 开始安装docker-compose"
       bash <(curl -sL https://"$url_address"/HiddenScholars/Linux-tools/"$con_branch"/InstallFile/Install_docker-compose.sh)
    fi
elif [ "$i" == "docker-compose" ]; then
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] 开始安装docker-compose"
    bash <(curl -sL https://"$url_address"/HiddenScholars/Linux-tools/"$con_branch"/InstallFile/Install_docker-compose.sh)
fi
done
echo "[$(date '+%Y-%m-%d %H:%M:%S')] 检测环境完成"

echo "[$(date '+%Y-%m-%d %H:%M:%S')] docker-compose文件路径：$docker_compose_file_path"
case $1 in
bitwareden)
  wget -P "$docker_compose_file_path" https://"$url_address"/HiddenScholars/Linux-tools/"$con_branch"/Docker-compose_file/bitwarden.yaml
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] 该docker-compose.yaml为模板需修改参数后 执行docker-compose -f bitwarden.yaml up -d"
  #cd "$docker_compose_file_path" && docker-compose -f bitwarden.yaml up -d
  ;;
firefox)
  wget -P "$docker_compose_file_path" https://"$url_address"/HiddenScholars/Linux-tools/"$con_branch"/Docker-compose_file/firefox.yaml
  cd "$docker_compose_file_path" && docker-compose -f firefox.yaml up -d
  ;;
*)
  echo "not found."
esac