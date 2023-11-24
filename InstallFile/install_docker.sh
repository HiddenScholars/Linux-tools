function install() {
tar -xf $download_path/${sorted_files[$select]}
cp $download_path/docker/* /usr/bin

## 创建配置文件
mkdir /etc/docker

## 配置国内的镜像源，加速镜像拉取
cat > /etc/docker/daemon.json << EOF
{
  "registry-mirrors": ["https://b9pmyelo.mirror.aliyuncs.com"]
}
EOF

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
    sudo systemctl daemon-reload
    sudo systemctl start docker
    if [ $? -eq 0 ];then
    echo "加速镜像写入完成"
    else
    echo "加速镜像写入失败"
    fi
    systemctl daemon-reload
    systemctl restart docker
    }

    function remove_old_docker() {

    # 移除掉旧的版本
    rm -rf DOCKEROLD
    rpm -qa | grep docker > DOCKEROLD
    for i in `cat ./DOCKEROLD`
    do
    rpm -e $i --nodeps
    done
    rm -rf DOCKEROLD

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
    systemctl status docker.service
