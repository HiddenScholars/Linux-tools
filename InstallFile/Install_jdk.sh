#!/bin/bash
source /tools/config
select=''
jdk_install_path=$(echo "$install_path"/jdk/ | tr -s '/')
jdk_download_path=$(echo "$download_path"/jdk/jdk | tr -s '/' )
#解压目录检测
GET_missing_dirs_nginx=$(curl -sl https://"$url_address"/HiddenScholars/Linux-tools/"$con_branch"/Check/Check.sh | bash -s -- check_unpack_file_path)


  bash <(curl -sl https://"$url_address"/HiddenScholars/Linux-tools/"$con_branch"/Check/Check.sh) PACKAGE_DOWNLOAD  jdk  $(for i in "${jdk_download_urls[@]}";do printf "%s " "$i";done)
  echo ""[$(date '+%Y-%m-%d %H:%M:%S')]" Start unzipping."
  tar xvf "$jdk_download_path" -C /tools/unpack_file/"$GET_missing_dirs_nginx" --strip-components 1 &>/dev/null
  echo ""[$(date '+%Y-%m-%d %H:%M:%S')]" The decompression is complete."
    [ -d "$jdk_install_path" ] && rm -rf "$jdk_install_path"
    mkdir -p "$jdk_install_path"
    mv /tools/unpack_file/"$GET_missing_dirs_nginx"/* "$jdk_install_path"
    if [ $? -eq 0 ];then
      echo ""[$(date '+%Y-%m-%d %H:%M:%S')]" 文件复制完成"
      "$controls" remove java* openjdk*  -y &>/dev/null
       set -x
       source /etc/profile
       if ! echo "$PATH" | grep -q "$jdk_install_path";then
         export PATH=$(echo "$PATH" | awk -v RS=: -v ORS=: -v path="$jdk_install_path" '$0 != path' | sed 's/:$//')
       fi
       source /etc/profile
       sed -i "\|$jdk_install_path|d" /etc/profile
       sed -i "\|JAVA_HOME|d" /etc/profile

       echo "export JAVA_HOME=$jdk_install_path" >>/etc/profile
       GET_PATH_PROFILE=$(echo "$PATH" | grep -cw "$jdk_install_path")
       if [ "$GET_PATH_PROFILE" == 0 ]; then
         sed -i "s|PATH=.*|PATH=\$PATH:\$jdk_install_path/bin|g" /etc/profile
         [ $? -eq 0 ] && echo "成功"
       fi
       if [ -n "$CLASSPATH" ]; then
          sed -i "s|CLASSPATH=.*|CLASSPATH=.:$jdk_install_path/lib/dt.jar:$jdk_install_path/lib/tools.jar|g" /etc/profile
       else
          echo "export CLASSPATH=.:$jdk_install_path/lib/dt.jar:$jdk_install_path/lib/tools.jar" >>/etc/profile
       fi
       set +x
          source /etc/profile
          if $(java -version) && $(javac -version) &>/dev/null; then
              echo ""[$(date '+%Y-%m-%d %H:%M:%S')]" 安装成功"
          else
              echo ""[$(date '+%Y-%m-%d %H:%M:%S')]" 安装失败"
          fi
    else
      echo ""[$(date '+%Y-%m-%d %H:%M:%S')]" 文件复制失败"
      echo ""[$(date '+%Y-%m-%d %H:%M:%S')]" 安装失败"
    fi
