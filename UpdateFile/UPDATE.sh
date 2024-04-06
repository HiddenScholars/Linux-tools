#!/bin/bash

function progress_bar() {
    local total_functions=$1  # 总函数数量
    local executed_functions=$2  # 已执行的函数数量
    local progress=$((executed_functions * 100 / total_functions))  # 计算进度百分比
    printf "\r更新: [%-50s] %d%%" $(printf '#%.0s' $(seq 1 $((progress / 2)))) $progress
}
source /tools/config &>/dev/null
     if [ -f /tools/config ]; then
        mv /tools/config /tools/config_bak
        wget -O /tools/config https://"$url_address"/HiddenScholars/Linux-tools/"$con_branch"/Config_file/config_"$country"
        if [ $? -eq 0 ]; then
            sed -i "s/url_address=.*/url_address=$url_address/g" /tools/config #下载完成后修改仓库地址
            sed -i "s/con_branch=.*/con_branch=$con_branch/g" /tools/config #下载完成后修改分支
            sed -i "s/Max_disk_usage=.*/Max_disk_usage=$Max_disk_usage/g" /tools/config #下载完成后修改tools下软件路径和解压路径最大占用空间
            sed -i "s/nginx_user=.*/nginx_user=$nginx_user/g" /tools/config #下载完成后修改nginx用户
            sed -i "s/mysql5_user=.*/mysql5_user=$mysql5_user/g" /tools/config #下载完成后修改mysql5用户
            sed -i "s/mysql5_initial_port=.*/mysql5_initial_port=$mysql5_initial_port/g" /tools/config #下载完成后修改mysql5端口
            sed -i "s/docker_compose_file=.*/docker_compose_file=$docker_compose_file/g" /tools/config #下载完成后修改docker-compose_file存放位置
            sed -i "s/Skip_selecting_version=.*/Skip_selecting_version=$Skip_selecting_version=/g" /tools/config #下载完成后修改保存的选择下载开关

            rm -rf /tools/config_bak
            bash <(curl -sL https://"$url_address"/HiddenScholars/Linux-tools/"$con_branch"/Link_localhost/uninstall.sh) # tool link uninstall.sh
            progress_bar 3 1
            bash <(curl -sL https://"$url_address"/HiddenScholars/Linux-tools/"$con_branch"/Link_localhost/install.sh) # tool link install.sh
            progress_bar 3 2
            bash <(curl -sl https://"$url_address"/HiddenScholars/Linux-tools/"$con_branch"/Check/Check.sh) SET_CONFIG
            progress_bar 3 3
            printf "\n"
            GET_REMOTE_VERSION=$(curl -sl https://"$url_address"/HiddenScholars/Linux-tools/"$con_branch"/version)
            echo "$GET_REMOTE_VERSION" >/tools/version
            echo -e "\033[32m已是最新版本\033[0m"
        else
            mv /tools/config_bak /tools/config
            echo -e "\033[31m更新失败\033[0m"
        fi
    else
       echo "not found config..."
       exit 1
    fi