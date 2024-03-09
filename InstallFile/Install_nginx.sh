config_path=/tools/
config_file=/tools/config
source /tools/config
# 获取包管理器
GET_PACKAGE_MASTER=$(curl -sl https://$url_address/HiddenScholars/Linux-tools/$con_branch/Check/Check.sh | bash -s -- PACKAGE_MASTER)
# 获取系统版本
GET_SYSTEM_CHECK=$(curl -sl https://$url_address/HiddenScholars/Linux-tools/$con_branch/Check/Check.sh | bash -s -- SYSTEM_CHECK)
#依赖检测
GET_DIRECTIVES_CHECK=$(curl -sl https://"$url_address"/HiddenScholars/Linux-tools/"$con_branch"/Check/Check.sh | bash -s -- DIRECTIVES_CHECK  "gcc" "make" "openssl" "pcre" "zlib")
for i in "${GET_DIRECTIVES_CHECK[@]}"
do
    if [ "$i" == "gcc" ]; then
       "$GET_PACKAGE_MASTER" install -y gcc && echo "安装成功"
    elif [ "$i" == "make" ]; then
       curl -sl https://"$url_address"/HiddenScholars/Linux-tools/"$con_branch"/Check/Check.sh | bash -s -- PACKAGE_DOWNLOAD make $(for i in "${make[@]}";do printf "$i";done)
       tar xvf "$download_path"/make/make -C "$config_path"/unpack_file/"$GET_missing_dirs" --strip-components 1 &>/dev/null
       cd "$config_path"/unpack_file/"$GET_missing_dirs" && ./configure make && make install && echo "安装成功"
    elif [ "$i" == "openssl" ]; then
       curl -sl https://"$url_address"/HiddenScholars/Linux-tools/"$con_branch"/Check/Check.sh | bash -s -- PACKAGE_DOWNLOAD openssl $(for i in "${openssl[@]}";do printf "$i";done)
       tar xvf "$download_path"/openssl/openssl -C "$config_path"/unpack_file/"$GET_missing_dirs" --strip-components 1 &>/dev/null
       cd "$config_path"/unpack_file/"$GET_missing_dirs" && ./configure make && make install && echo "安装成功"
    elif [ "$i" == "pcre" ]; then
       curl -sl https://"$url_address"/HiddenScholars/Linux-tools/"$con_branch"/Check/Check.sh | bash -s -- PACKAGE_DOWNLOAD pcre $(for i in "${pcre[@]}";do printf "$i";done)
       tar xvf "$download_path"/pcre/pcre -C "$config_path"/unpack_file/"$GET_missing_dirs" --strip-components 1 &>/dev/null
       cd "$config_path"/unpack_file/"$GET_missing_dirs" && ./configure make && make install && echo "安装成功"
    elif [ "$i" == "zlib" ]; then
       curl -sl https://"$url_address"/HiddenScholars/Linux-tools/"$con_branch"/Check/Check.sh | bash -s -- PACKAGE_DOWNLOAD zlib $(for i in "${zlib[@]}";do printf "$i";done)
       tar xvf "$download_path"/zlib/zlib -C "$config_path"/unpack_file/"$GET_missing_dirs" --strip-components 1 &>/dev/null
       cd "$config_path"/unpack_file/"$GET_missing_dirs" && ./configure make && make install && echo "安装成功"
    fi

done

#安装包下载
curl -sl https://"$url_address"/HiddenScholars/Linux-tools/"$con_branch"/Check/Check.sh | bash -s -- PACKAGE_DOWNLOAD  nginx  $(for i in "${nginx_download_urls[@]}";do printf "$i";done)
#解压目录检测
GET_missing_dirs=$(curl -sl https://"$url_address"/HiddenScholars/Linux-tools/"$con_branch"/Check/Check.sh | bash -s -- check_unpack_file_path)

    [ -d "$install_path"/nginx/ ] && mv "$install_path"/nginx/ "$install_path"/nginx"$time"
    tar xvf "$download_path"/nginx/nginx -C /tools/unpack_file/"$GET_missing_dirs" --strip-components 1 &>/dev/null
    cd /tools/unpack_file/"$GET_missing_dirs" && ./configure --prefix="${install_path}"/nginx/ \
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
    source /etc/profile
    if [ -z "$NGINX_HOME" ];then
    echo "export NGINX_HOME=$install_path/nginx/" >>/etc/profile
    echo "export PATH=$PATH:$NGINX_HOME/sbin/" >>/etc/profile
    sed -i "s/#user  nobody/user $nginx_user/g" "$install_path"/nginx/conf/nginx.conf
    source /etc/profile
    fi
    if [ ! -z "$nginx_user" ]; then
    id "$nginx_user" &>/dev/null
    [ $? -ne 0 ] && useradd -s /sbin/nologin "$nginx_user"
    # shellcheck disable=SC2086
    chown -R "$nginx_user":"$nginx_user" $NGINX_HOME
    fi

    if [ -f "$NGINX_HOME"/sbin/nginx ]; then
        echo -e "${green}安装完成...${plain}"
        else
        echo -e "${red}安装失败...${plain}"
        exit 0
    fi

echo "[Unit]
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
WantedBy=multi-user.target" > /usr/lib/systemd/system/nginx.service

chmod +x /usr/lib/systemd/system/nginx.service
systemctl daemon-reload
systemctl start nginx.service
systemctl enable nginx.service
ps -ef | grep nginx
[ $? -ne 0 ] && exit 0

echo -e "设置防火墙..."

    if [ `ps -ef | grep firewalld | wc -l ` -gt 1 ];then
        firewall-cmd --permanent --add-port=80/tcp
        firewall-cmd --permanent --add-port=443/tcp
        firewall-cmd --reload
    elif [ `ps -ef  | grep ufw | wc -l` -gt 1 ]; then
        ufw allow 80/tcp
        ufw allow 443/tcp
        ufw reload
    else
    echo -e "${red}未检测到防火墙进程，不做更改${plain}"
fi