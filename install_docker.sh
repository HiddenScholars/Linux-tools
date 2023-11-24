function install() {
    if [ -f /usr/lib/systemd/system/docker.service  ];then
    rm -rf /usr/lib/systemd/system/docker.service
    fi
    tar zxf ${i} -C /opt/
    chown -R root:root /opt/docker/
    ln -s /opt/docker/* /usr/bin/
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
    TimeoutStartSec=0
    Delegate=yes
    KillMode=process
    Restart=on-failure
    StartLimitBurst=3
    StartLimitInterval=60s

    [Install]
    WantedBy=multi-user.target
    " >>/usr/lib/systemd/system/docker.service
    systemctl daemon-reload
    systemctl start docker
    systemctl enable docker
    }
    function dameon() {

    sudo mkdir -p /etc/docker
sudo tee /etc/docker/daemon.json <<-'EOF'
{
  "registry-mirrors": [
    "https://ung2thfc.mirror.aliyuncs.com",
    "https://registry.docker-cn.com",
    "http://hub-mirror.c.163.com",
    "https://docker.mirrors.ustc.edu.cn"
  ]
}
EOF
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
    function ps() {

    docker ps -a &>/dev/null
    if [ $? -eq 0 ];then
    echo "服务安装成功"
    else
    echo "服务安装失败"
    fi
    }

    for i in $1
    do
    if [ ! -f ${DIR}/${i} ];then
    remove_old_docker
    echo "${i} file does not exist"
    else
    install
    dameon
    ps
    fi
    done
