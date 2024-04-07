#!/bin/bash
config_path=/tools/
config_file=/tools/config
source /tools/config &>/dev/null
red=$(curl -sl https://"$url_address"/HiddenScholars/Linux-tools/"$con_branch"/Check/Check.sh | bash -s -- COLOR red)
green=$(curl -sl https://"$url_address"/HiddenScholars/Linux-tools/"$con_branch"/Check/Check.sh | bash -s -- COLOR green)
plain=$(curl -sl https://"$url_address"/HiddenScholars/Linux-tools/"$con_branch"/Check/Check.sh | bash -s -- COLOR plain)
# 进程检测
GET_PROCESS_CHECK=($(curl -sl https://"$url_address"/HiddenScholars/Linux-tools/"$con_branch"/Check/Check.sh | bash -s -- PROCESS_CHECK nginx))
# 端口检测
GET_PORT_CHECK=($(curl -sl https://"$url_address"/HiddenScholars/Linux-tools/"$con_branch"/Check/Check.sh | bash -s -- PORT_CHECK 80))
if [ -n "$GET_PROCESS_CHECK" ] && [ -n "$GET_PORT_CHECK" ] && [ "${#GET_PROCESS_CHECK[@]}" -ne 0 ]  && [ "${#GET_PORT_CHECK[@]}" -ne 0 ]; then
    read -rp "nginx程序已存在是否继续安装（y/n）：" select
    [ "$select" != "y" ] && exit 0
elif [ -n "$GET_PROCESS_CHECK" ] &&[ "${#GET_PROCESS_CHECK[@]}" -ne 0 ] ; then
    echo "nginx有残留进程，尝试执行卸载脚本后再次执行"
    exit 1
elif [ -n "$GET_PORT_CHECK" ] &&[ "${#GET_PORT_CHECK[@]}" -ne 0 ]; then
    for i in "${GET_PORT_CHECK[@]}"
    do
        printf "%s\t" "$i"
    done
     read -rp "被占用是否继续安装（y/n）：" select
    [ "$select" != "y" ] && exit 0
fi
bash <(curl -sl https://"$url_address"/HiddenScholars/Linux-tools/"$con_branch"/Check/Check.sh) PACKAGE_DOWNLOAD  nginx  $(for i in "${nginx_download_urls[@]}";do printf "%s " "$i";done)
  if [ "$SystemVersion" == "centos" ] || [ "$SystemVersion" == "Anolis OS" ]; then
      yum_package=(gcc gcc-c++ zlib zlib-devel pcre-devel openssl openssl-devel gd-devel)
      for i in "${yum_package[@]}"
      do
       "$controls" -y install  "$i"
      done
  elif [ "$SystemVersion" == "ubuntu" ] || [ "$SystemVersion" == "debian" ]; then
       apt_package=(build-essential gcc gcc-c++ zlib1g zlib1g-dev libpcre3-dev libssl-dev libgd-dev)
       for y in "${apt_package[@]}"
       do
          "$controls" -y install "$y"
       done
  else
    echo "未支持的系统版本"
    exit 1
  fi

#解压目录检测
GET_missing_dirs_nginx=$(curl -sl https://"$url_address"/HiddenScholars/Linux-tools/"$con_branch"/Check/Check.sh | bash -s -- check_unpack_file_path)

        if [ -d "$install_path/BackupNginx$(date '+%Y%m%d')" ]; then
          for (( i = 1; i < 10000; i++ )); do
              if [ ! -d "$install_path/BackupNginx$(date '+%Y%m%d')$i" ]; then
                cd "$install_path" && mv "BackupNginx$(date '+%Y%m%d')" "BackupNginx$(date '+%Y%m%d')$i"
                i=10000
              fi
          done
        fi
        cd "$install_path" && mv nginx "BackupJdk$(date '+%Y%m%d')"
    bak_path=$(echo "$install_path"/BackupNginx$(date '+%Y%m%d') | tr -s '/')
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] 原始路径备份：$bak_path"
    echo ""[$(date '+%Y-%m-%d %H:%M:%S')]" Start unzipping."
    tar xvf "$download_path"/nginx/nginx -C /tools/unpack_file/"$GET_missing_dirs_nginx" --strip-components 1 &>/dev/null
    echo ""[$(date '+%Y-%m-%d %H:%M:%S')]" The decompression is complete."
    cd /tools/unpack_file/"$GET_missing_dirs_nginx" && ./configure --prefix="${install_path}"/nginx/ \
                                                --with-pcre \
                                                --with-http_ssl_module \
                                                --with-http_v2_module \
                                                --with-http_realip_module \
                                                --with-http_addition_module \
                                                --with-http_sub_module \
                                                --with-http_dav_module \
                                                --with-http_flv_module \
                                                --with-http_mp4_module \
                                                --with-http_gunzip_module \
                                                --with-http_gzip_static_module \
                                                --with-http_random_index_module \
                                                --with-http_secure_link_module \
                                                --with-http_stub_status_module \
                                                --with-http_auth_request_module \
                                                --with-http_image_filter_module \
                                                --with-http_slice_module \
                                                --with-mail \
                                                --with-threads \
                                                --with-file-aio \
                                                --with-stream \
                                                --with-mail_ssl_module \
                                                --with-stream_ssl_module && make && make install
    if [ -f "$install_path"/nginx/sbin/nginx ]; then
        echo -e "${green}安装完成...${plain}"
        curl -sl https://"$url_address"/HiddenScholars/Linux-tools/"$con_branch"/Check/Check.sh | bash -s SetVariables NGINX_HOME "$install_path"/nginx /etc/profile
        source /etc/profile
        if [ -f "$install_path"/nginx/conf/nginx.conf ]; then
            sed -i "s/#user  nobody/user $nginx_user/g" "$install_path"/nginx/conf/nginx.conf
            if [ -n "$nginx_user" ]; then
               id "$nginx_user" &>/dev/null
               if [ $? -ne 0 ];then
                   useradd -s /sbin/nologin "$nginx_user"
               fi
               source /etc/profile &>/dev/null
               chown -R "$nginx_user":"$nginx_user" "$NGINX_HOME"
           fi
        fi
if [ ! -f /usr/lib/systemd/system/nginx.service ]; then
  touch /usr/lib/systemd/system/nginx.service
fi
cat <<EOF > /usr/lib/systemd/system/nginx.service
[Unit]
Description=The Nginx HTTP Server
After=network.target remote-fs.target nss-lookup.target

[Service]
Type=forking
PIDFile=$NGINX_HOME/logs/nginx.pid
ExecStart=$NGINX_HOME/sbin/nginx
ExecReload=$NGINX_HOME/sbin/nginx -s reload
ExecStop=$NGINX_HOME/sbin/nginx -s stop
PrivateTmp=true

[Install]
WantedBy=multi-user.target
EOF

chmod +x /usr/lib/systemd/system/nginx.service
systemctl daemon-reload
systemctl start nginx.service
else
      echo -e "${red}安装失败...${plain}"
      exit 1
    fi