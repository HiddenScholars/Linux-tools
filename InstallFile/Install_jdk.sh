#!/bin/bash
source /tools/config
select=''
jdk_path=$(echo "$install_path"/jdk/ | tr -s '/')
#解压目录检测
GET_missing_dirs_nginx=$(curl -sl https://"$url_address"/HiddenScholars/Linux-tools/"$con_branch"/Check/Check.sh | bash -s -- check_unpack_file_path)
# 获取包管理器
GET_PACKAGE_MASTER=$(curl -sl https://"$url_address"/HiddenScholars/Linux-tools/"$con_branch"/Check/Check.sh | bash -s -- PACKAGE_MASTER)
read -rp "使用本地安装包直接输入文件所在绝对路径，回车进行网络安装：" select
if [ -n "$select" ] && [ -f "$select" ]; then
  tar xvf "$select" -C /tools/unpack_file/"$GET_missing_dirs_nginx" --strip-components 1
else
  bash <(curl -sl https://"$url_address"/HiddenScholars/Linux-tools/"$con_branch"/Check/Check.sh) PACKAGE_DOWNLOAD  jdk  $(for i in "${jdk_download_urls[@]}";do printf "%s " "$i";done)
  tar xvf "$download_path"/jdk/jdk -C /tools/unpack_file/"$GET_missing_dirs_nginx" --strip-components 1
fi
    if [ -d "$jdk_path" ];then
      mv "$jdk_path" "$install_path/jdk$(date +%Y%m%d)_bak"
    fi
    if [ ! -d "$jdk_path" ];then
      mkdir -p "$jdk_path"
    fi
    if $(cp -rf  /tools/unpack_file/"$GET_missing_dirs_nginx"/* "$jdk_path");then
      echo "文件复制完成"
    else
      echo "文件复制失败"
    fi
    "$GET_PACKAGE_MASTER" remove -y '*openjdk*' java*

     sed -i "\|$jdk_path|d" /etc/profile
cat << EOF >> /etc/profile
export JAVA_HOME=$install_path/jdk1.8/
export PATH=\$JAVA_HOME/bin:\$PATH
export CLASSPATH=.:\$JAVA_HOME/lib/dt.jar:\$JAVA_HOME/lib/tools.jar
EOF
        source /etc/profile
        if $(java -version) &>/dev/null && $(javac -version) &>/dev/null; then
            echo "安装成功"
        else
            echo "安装失败"
            sed -i "\|$jdk_path|d" /etc/profile
            rm -rf "$jdk_path" "$install_path/jdk$(date +%Y%m%d)_bak"
        fi