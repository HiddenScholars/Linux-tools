#!/bin/bash
  source /tools/config
  select=''
  jdk_install_path=$(echo "$install_path"/jdk/ | tr -s '/')
  jdk_download_path=$(echo "$download_path"/jdk/jdk | tr -s '/' )
  #解压目录检测
  GET_missing_dirs_nginx=$(curl -sl https://"$url_address"/HiddenScholars/Linux-tools/"$con_branch"/Check/Check.sh | bash -s -- check_unpack_file_path)


    bash <(curl -sl https://"$url_address"/HiddenScholars/Linux-tools/"$con_branch"/Check/Check.sh) PACKAGE_DOWNLOAD  jdk  $(for i in "${jdk_download_urls[@]}";do printf "%s " "$i";done)
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] Start unzipping."
    tar xvf "$jdk_download_path" -C /tools/unpack_file/"$GET_missing_dirs_nginx" --strip-components 1 &>/dev/null
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] The decompression is complete."
      if [ -d "$jdk_install_path" ];then
        if [ -d "$install_path/BackupJdk$(date '+%Y%m%d')" ]; then
          for (( i = 1; i < 10000; i++ )); do
              if [ ! -d "$install_path/BackupJdk$(date '+%Y%m%d')$i" ]; then
                cd "$install_path" && mv "BackupJdk$(date '+%Y%m%d')" "BackupJdk$i$(date '+%Y%m%d')"
                i=10000
              fi
          done
        fi
        cd "$install_path" && mv jdk "BackupJdk$(date '+%Y%m%d')"
        echo "[$(date '+%Y-%m-%d %H:%M:%S')] 原始路径备份：$install_path/BackupJdk$(date '+%Y%m%d')"
      fi
      mkdir -p "$jdk_install_path"
      mv /tools/unpack_file/"$GET_missing_dirs_nginx"/* "$jdk_install_path"
      if [ $? -eq 0 ];then
         echo ""[$(date '+%Y-%m-%d %H:%M:%S')]" 文件复制完成"
        "$controls" remove java* openjdk*  -y &>/dev/null

         source /etc/profile
         sed -i "\|export JAVA_HOME=$jdk_install_path|d" /etc/profile
         sed -i "\|export PATH=.*|d" /etc/profile
         sed -i "\|export CLASSPATH=.*|d" /etc/profile

         echo "export PATH=$jdk_install_path/bin:$PATH" >>/etc/profile
         echo "export JAVA_HOME=$jdk_install_path" >>/etc/profile
         echo "export CLASSPATH=.:$jdk_install_path/lib/dt.jar:$jdk_install_path/lib/tools.jar" >>/etc/profile
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