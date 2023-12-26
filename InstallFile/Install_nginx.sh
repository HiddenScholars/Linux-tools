source /tools/config.sh
select=''
    [ ! -f $download_path/nginx/$1 ] && echo -e "${red}文件不存在${plain}" && exit 0
    echo $release

    if [ "$release" == "centos" ]; then
            $controls install -y gcc gcc-c++ pcre pcre-devel zlib zlib-devel openssl openssl-devel gd gd-devel
    elif [ "$release" == "ubuntu" ]; then
            $controls install -y gcc g++ libpcre3 libpcre3-dev zlib1g zlib1g-dev libssl-dev libgd-dev make
    else
            $controls install -y gcc g++ libpcre3 libpcre3-dev zlib1g zlib1g-dev libssl-dev libgd-dev make
    fi
    [ -d $install_path/nginx/ ] && mv $install_path/nginx/ $install_path/nginx$time
    mkdir -p /tools/unpack_file/
    tar xvf $download_path/nginx/$1 -C /tools/unpack_file/ --strip-components 1
    cd /tools/unpack_file/ && ./configure --prefix=${install_path}/nginx/ \
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
    if [ -z $NGINX_HOME ];then
    echo "export NGINX_HOME=$install_path/nginx/" >>/etc/profile
    echo "export PATH=$PATH:$NGINX_HOME/sbin/" >>/etc/profile
    sed -i 's/#user  nobody/user $nginx_user/g' $install_path/nginx/conf/nginx.conf
    source /etc/profile
    fi
    if [ ! -z $nginx_user ]; then
    id $nginx_user &>/dev/null
    [ $? -ne 0 ] && useradd -s /sbin/nologin $nginx_user
    chown -R $nginx_user:$nginx_user $NGINX_HOME
    fi

    if [ -f $NGINX_HOME/sbin/nginx ]; then
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