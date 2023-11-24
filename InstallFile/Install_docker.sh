source /tools/soft/config
echo 11111
function install() {
echo $download_path
echo $docker_file
cd $download_path/docker && tar -xf $docker_file
cp -r $download_path/docker/docker/* /usr/bin

## 创建配置文件
mkdir /etc/docker

## 配置国内的镜像源，加速镜像拉取
cat > /etc/docker/daemon.json << EOF
{
  "registry-mirrors": ["https://b9pmyelo.mirror.aliyuncs.com"]
}
EOF
if [ `cat /etc/docker_daemon.json | wc -l` -ne 0 ];then
    echo "加速镜像写入完成"
    else
    echo "加速镜像写入失败"
fi

## 生成systemd配置文件
cat > /usr/lib/systemd/system/docker.service << EOF
[Unit]
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
WantedBy=multi-user.target
EOF

## 启动并设置开启自启
systemctl daemon-reload
systemctl start docker
systemctl enable docker
docker --version
}

    function remove_old_docker() {

    # 移除掉旧的版本

    # 删除所有旧的数据
    sudo rm -rf /var/lib/docker
    sudo rm -rf /etc/docker/daemon.json

    if [ -d /etc/docker/ ];then
    rm -rf /etc/docker/
    fi

    if [ -f /usr/lib/systemd/system/docker.service ];then
    systemctl stop docker.service
    rm -rf /usr/lib/systemd/system/docker.service
    systemctl daemon-reload
    fi

    }
    function check_install_status() {

    docker ps -a &>/dev/null
    if [ $? -eq 0 ];then
    echo -e "${green}服务安装成功 ${plain}"
    else
    echo  -e "${green}服务安装失败 ${plain}"
    fi
    }

    remove_old_docker
    install
    check_install_status
