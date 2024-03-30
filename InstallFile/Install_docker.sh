echo "当操作系统为官网脚本支持的操作系统时，直接执行官网脚本，在config中配置的docker源码下载链接不生效。"
config_path=/tools/
config_file=/tools/config
function setting_docker_daemon_json() {
if [ "$country" == "CN" ]; then
cat > /etc/docker/daemon.json <<EOF
{
  "data-root": "/var/lib/docker",
  "live-restore": true,
  "log-driver": "json-file",
  "log-opts": {
    "max-file": "3",
    "max-size": "10m"
  },
  "registry-mirrors": ["https://f2k3b83v.mirror.aliyuncs.com"]
}
EOF
fi
}
source $config_file
if [ "SystemVersion" == "centos" ] || [ "SystemVersion" == "ubuntu" ] || [ "SystemVersion" == "debian" ]; then
   set -x
   sudo curl -sSL https://get.docker.com | sh
   set +x
   setting_docker_daemon_json
else
    GET_missing_dirs_docker=$(curl -sl https://"$url_address"/HiddenScholars/Linux-tools/"$con_branch"/Check/Check.sh | bash -s -- check_unpack_file_path)
    #Docker下载
    bash <(curl -sl https://"$url_address"/HiddenScholars/Linux-tools/"$con_branch"/Check/Check.sh) PACKAGE_DOWNLOAD  docker $(for i in "${docker_download_urls[@]}";do printf "%s " "$i";done)
    tar -xzvf "$download_path/docker/docker" -C  "/tools/unpack_file/$GET_missing_dirs_docker" --strip-components 1
      if $(cp -rf /tools/unpack_file/"$GET_missing_dirs_docker"/* /usr/bin/); then
        echo "复制完成"
      fi
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
    systemctl start docker && echo "启动失败"
    systemctl enable docker
    if $(docker info &>/dev/null); then
        setting_docker_daemon_json
        echo "Docker安装成功"
    else
        echo "Docker安装失败"
    fi
fi
