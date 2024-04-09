#!/bin/bash

function progress_bar() {
    local total_functions=$1  # 总函数数量
    local executed_functions=$2  # 已执行的函数数量
    local progress=$((executed_functions * 100 / total_functions))  # 计算进度百分比
    printf "\r更新: [%-50s] %d%%" $(printf '#%.0s' $(seq 1 $((progress / 2)))) $progress
}
config_path=/tools/
config_file=/tools/config.xml
con_branch=$(awk -v RS="</parameters>" '/<parameters>/{gsub(/.*<parameters>[\r\n\t ]*|[\r\n\t ]*$/,"");print}' $config_file | awk -F'[><]' '/<con_branch>/{print $3}')
url_address=$(awk -v RS="</parameters>" '/<parameters>/{gsub(/.*<parameters>[\r\n\t ]*|[\r\n\t ]*$/,"");print}' $config_file | awk -F'[><]' '/<url_address>/{print $3}')
country=$(awk -v RS="</parameters>" '/<parameters>/{gsub(/.*<parameters>[\r\n\t ]*|[\r\n\t ]*$/,"");print}' $config_file | awk -F'[><]' '/<country>/{print $3}')
     if [ -f /tools/config.xml ]; then
        mv /tools/config.xml /tools/config_bak
        config_file_bak=/tools/config_bak
        con_branch=$(awk -v RS="</parameters>" '/<parameters>/{gsub(/.*<parameters>[\r\n\t ]*|[\r\n\t ]*$/,"");print}' $config_file_bak | awk -F'[><]' '/<con_branch>/{print $3}')
        url_address=$(awk -v RS="</parameters>" '/<parameters>/{gsub(/.*<parameters>[\r\n\t ]*|[\r\n\t ]*$/,"");print}' $config_file_bak | awk -F'[><]' '/<url_address>/{print $3}')
        download_path=$(awk -v RS="</paths>" '/<paths>/{gsub(/.*<paths>[\r\n\t ]*|[\r\n\t ]*$/,"");print}' $config_file_bak | awk -F'[><]' '/<download_path>/{print $3}')
        install_path=$(awk -v RS="</paths>" '/<paths>/{gsub(/.*<paths>[\r\n\t ]*|[\r\n\t ]*$/,"");print}' $config_file_bak | awk -F'[><]' '/<install_path>/{print $3}')
        Max_disk_usage=$(awk -v RS="</parameters>" '/<parameters>/{gsub(/.*<parameters>[\r\n\t ]*|[\r\n\t ]*$/,"");print}' $config_file_bak | awk -F'[><]' '/<Max_disk_usage>/{print $3}')
        Skip_selecting_version=$(awk -v RS="</parameters>" '/<parameters>/{gsub(/.*<parameters>[\r\n\t ]*|[\r\n\t ]*$/,"");print}' $config_file | awk -F'[><]' '/<Skip_selecting_version>/{print $3}')
        nginx_user=$(awk -v RS="</parameters>" '/<parameters>/{gsub(/.*<parameters>[\r\n\t ]*|[\r\n\t ]*$/,"");print}' $config_file_bak | awk -F'[><]' '/<nginx_user>/{print $3}')
        mysql5_user=$(awk -v RS="</parameters>" '/<parameters>/{gsub(/.*<parameters>[\r\n\t ]*|[\r\n\t ]*$/,"");print}' $config_file_bak | awk -F'[><]' '/<mysql5_user>/{print $3}')
        mysql5_initial_port=$(awk -v RS="</parameters>" '/<parameters>/{gsub(/.*<parameters>[\r\n\t ]*|[\r\n\t ]*$/,"");print}' $config_file_bak | awk -F'[><]' '/<mysql5_initial_port>/{print $3}')
        docker_compose_file_path=$(awk -v RS="</paths>" '/<paths>/{gsub(/.*<paths>[\r\n\t ]*|[\r\n\t ]*$/,"");print}' $config_file_bak | awk -F'[><]' '/<docker_compose_file_path>/{print $3}')
        wget -O /tools/config.xml https://"$url_address"/HiddenScholars/Linux-tools/"$con_branch"/Config_file/config_"$country"
        if [ -f /tools/config.xml ]; then
            sed -i "s|<url_address>.*</url_address>|<url_address>$url_address</url_address>|g" $config_file
            sed -i "s|<con_branch>.*</con_branch>|<con_branch>$con_branch</con_branch>|g" $config_file
            sed -i "s|<Max_disk_usage>.*</Max_disk_usage>|<Max_disk_usage>$Max_disk_usage</Max_disk_usage>|g" $config_file
            sed -i "s|<nginx_user>.*</nginx_user>|<nginx_user>$nginx_user</nginx_user>|g" $config_file
            sed -i "s|<mysql5_user>.*</mysql5_user>|<mysql5_user>$mysql5_user</mysql5_user>|g" $config_file
            sed -i "s|<mysql5_initial_port>.*</mysql5_initial_port>|<mysql5_initial_port>$mysql5_initial_port</mysql5_initial_port>|g" $config_file
            sed -i "s|<docker_compose_file_path>.*</docker_compose_file_path>|<docker_compose_file_path>$docker_compose_file_path</docker_compose_file_path|g" $config_file
            sed -i "s|<Skip_selecting_version>.*</Skip_selecting_version>|<Skip_selecting_version>$Skip_selecting_version</Skip_selecting_version>|g" $config_file
            rm -rf /tools/config_bak
            progress_bar 2 1
            bash <(curl -sl https://"$url_address"/HiddenScholars/Linux-tools/"$con_branch"/Check/Check.sh) SET_CONFIG
            progress_bar 2 2
            printf "\n"
            echo -e "\033[32m已是最新版本\033[0m"
        else
            mv /tools/config_bak /tools/config
            echo -e "\033[31m更新失败\033[0m"
        fi
    else
       echo "not found config..."
       exit 1
    fi