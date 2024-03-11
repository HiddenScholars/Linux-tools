config_path=/tools/
config_file=/tools/config
source /tools/config
GET_missing_dirs_docker=$(curl -sl https://"$url_address"/HiddenScholars/Linux-tools/"$con_branch"/Check/Check.sh | bash -s -- check_unpack_file_path)
#Docker下载
bash <(curl -sl https://"$url_address"/HiddenScholars/Linux-tools/"$con_branch"/Check/Check.sh) PACKAGE_DOWNLOAD  docker  $(for i in "${docker_urls[@]}";do printf "$i ";done)
tar -xzvf "$download_path"/docker/docker -C  /tools/unpack_file/"$GET_missing_dirs_docker" --strip-components 1
cd /tools/unpack_file/"$GET_missing_dirs_docker" && cp -rf * /usr/bin/*

echo "[Unit]
Description=Docker Application Container Engine
Documentation=https://docs.docker.com
After=network-online.target firewalld.service
Wants=network-online.target

[Service]
Type=notify
ExecStart=/usr/bin/dockerd
ExecReload=/bin/kill -s HUP $MAINPID
LimitNOFILE=infinity
LimitNPROC=infinity
LimitCORE=infinity
TimeoutStartSec=0
Delegate=yes
KillMode=process
Restart=on-failure
StartLimitBurst=3
StartLimitInterval=60s

[Install]
WantedBy=multi-user.target" > /etc/systemd/system/docker.service
sudo chmod a+x /etc/systemd/system/docker.service
systemctl daemon-reload
systemctl start docker

if $(docker info &>/dev/null); then
    echo "安装成功"
else
    echo "安装失败"
fi


