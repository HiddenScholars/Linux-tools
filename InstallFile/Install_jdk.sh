#!/bin/bash


#! /bin/bash

config_path=/tools/
config_file=/tools/config.xml
con_branch=$(awk -v RS="</parameters>" '/<parameters>/{gsub(/.*<parameters>[\r\n\t ]*|[\r\n\t ]*$/,"");print}' $config_file | awk -F'[><]' '/<con_branch>/{print $3}')
url_address=$(awk -v RS="</parameters>" '/<parameters>/{gsub(/.*<parameters>[\r\n\t ]*|[\r\n\t ]*$/,"");print}' $config_file | awk -F'[><]' '/<url_address>/{print $3}')
download_path=$(awk -v RS="</paths>" '/<paths>/{gsub(/.*<paths>[\r\n\t ]*|[\r\n\t ]*$/,"");print}' $config_file | awk -F'[><]' '/<download_path>/{print $3}')
install_path=$(awk -v RS="</paths>" '/<paths>/{gsub(/.*<paths>[\r\n\t ]*|[\r\n\t ]*$/,"");print}' $config_file | awk -F'[><]' '/<install_path>/{print $3}')
jdk_download_urls=($(awk '/<download_urls>/,/<\/download_urls>/' $config_file | awk '/<jdk_download_urls>/,/<\/jdk_download_urls>/' | awk -F '[<>]' '/<url>/{print $3}'))
controls=$(awk -v RS="</system>" '/<system>/{gsub(/.*<system>[\r\n\t ]*|[\r\n\t ]*$/,"");print}' $config_file | awk -F'[><]' '/<controls>/{print $3}')
  select=''
  jdk_install_path=$(echo "$install_path"/jdk/ | tr -s '/')
  jdk_download_path=$(echo "$download_path"/jdk/jdk | tr -s '/' )
  #解压目录检测
  GET_missing_dirs_jdk=$(curl -sl https://"$url_address"/HiddenScholars/Linux-tools/"$con_branch"/Check/Check.sh | bash -s -- check_unpack_file_path)

    bash <(curl -sl https://"$url_address"/HiddenScholars/Linux-tools/"$con_branch"/Check/Check.sh) PACKAGE_DOWNLOAD  jdk  $(for i in "${jdk_download_urls[@]}";do printf "%s " "$i";done)
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] Start unzipping."
    tar xvf "$jdk_download_path" -C /tools/unpack_file/"$GET_missing_dirs_jdk" --strip-components 1 &>/dev/null
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] The decompression is complete."
      if [ -d "$jdk_install_path" ];then
        if [ -d "$install_path/BackupJdk$(date '+%Y%m%d')" ]; then
          for (( i = 1; i < 10000; i++ )); do
              if [ ! -d "$install_path/BackupJdk$(date '+%Y%m%d')$i" ]; then
                cd "$install_path" && mv "BackupJdk$(date '+%Y%m%d')" "BackupJdk$(date '+%Y%m%d')$i"
                i=10000
              fi
          done
        fi
        cd "$install_path" && mv jdk "BackupJdk$(date '+%Y%m%d')"
        bak_path=$(echo "$install_path"/BackupJdk$(date '+%Y%m%d') | tr -s '/')
        echo "[$(date '+%Y-%m-%d %H:%M:%S')] 原始路径备份：$bak_path"
      fi
      mkdir -p "$jdk_install_path"
      mv /tools/unpack_file/"$GET_missing_dirs_jdk"/*  "$jdk_install_path"
      if [ $? -eq 0 ];then
         echo ""[$(date '+%Y-%m-%d %H:%M:%S')]" 文件复制完成"
        "$controls" remove java* openjdk*  -y &>/dev/null
         jdk_install_path_bin=$(echo "$jdk_install_path"/bin | tr -s '/')
         jdk_install_path_lib_dt=$(echo "$jdk_install_path"/lib/dt.jar | tr -s '/')
         jdk_install_path_lib_tools=$(echo "$jdk_install_path"/lib/tools.jar | tr -s '/')
         curl -sl https://"$url_address"/HiddenScholars/Linux-tools/"$con_branch"/Check/Check.sh | bash -s SetVariables JAVA_HOME "$jdk_install_path" /etc/profile
         curl -sl https://"$url_address"/HiddenScholars/Linux-tools/"$con_branch"/Check/Check.sh | bash -s SetVariables PATH "$jdk_install_path_bin" /etc/profile
         curl -sl https://"$url_address"/HiddenScholars/Linux-tools/"$con_branch"/Check/Check.sh | bash -s SetVariables CLASSPATH "$jdk_install_path_lib_dt:$jdk_install_path_lib_tools" /etc/profile
            source /etc/profile
            if $(java -version);then
              if $(javac -version);then
                echo ""[$(date '+%Y-%m-%d %H:%M:%S')]" 安装成功"
              fi
            else
                echo ""[$(date '+%Y-%m-%d %H:%M:%S')]" 安装失败"
            fi
      else
        echo ""[$(date '+%Y-%m-%d %H:%M:%S')]" 文件复制失败"
        echo ""[$(date '+%Y-%m-%d %H:%M:%S')]" 安装失败"
      fi