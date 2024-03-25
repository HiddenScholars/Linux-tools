#!/bin/bash
source /tools/config
select=''
jdk_install_path=$(echo "$install_path"/jdk/ | tr -s '/')
jdk_download_path=$(echo "$download_path"/jdk/jdk | tr -s '/' )
#解压目录检测
GET_missing_dirs_nginx=$(curl -sl https://"$url_address"/HiddenScholars/Linux-tools/"$con_branch"/Check/Check.sh | bash -s -- check_unpack_file_path)


  bash <(curl -sl https://"$url_address"/HiddenScholars/Linux-tools/"$con_branch"/Check/Check.sh) PACKAGE_DOWNLOAD  jdk  $(for i in "${jdk_download_urls[@]}";do printf "%s " "$i";done)
  echo "Start unzipping."
  tar xvf "$jdk_download_path" -C /tools/unpack_file/"$GET_missing_dirs_nginx" --strip-components 1 &>/dev/null
  echo "The decompression is complete."
    if [ -d "$jdk_install_path" ];then
      rm -rf "$jdk_install_path"
      mkdir -p "$jdk_install_path"
    fi
    if [ -n "$jdk_install_path" ] && [ ! -d "$jdk_install_path" ];then
      mkdir -p "$jdk_install_path"
    fi
    cp -rf  /tools/unpack_file/"$GET_missing_dirs_nginx"/* "$jdk_install_path"
    if [ $? -eq 0 ];then
      echo "文件复制完成"
    else
      echo "文件复制失败"
    fi
    "$controls" remove java* openjdk*  -y

     sed -i "\|$jdk_install_path|d" /etc/profile
     echo "export JAVA_HOME=$jdk_install_path" >>/etc/profile
     echo "export PATH=$JAVA_HOME/bin:$PATH" >>/etc/profile
     echo "export CLASSPATH=.:$JAVA_HOME/lib/dt.jar:$JAVA_HOME/lib/tools.jar" >>/etc/profile
        source /etc/profile
        if $(java -version) && $(javac -version) &>/dev/null; then
            echo "安装成功"
        else
            echo "安装失败"
            sed -i "\|$jdk_install_path|d" /etc/profile
            sed -i "\|JAVA_HOME|d" /etc/profile
        fi