source /tools/config
# 获取包管理器
GET_PACKAGE_MASTER=$(curl -sl https://"$url_address"/HiddenScholars/Linux-tools/"$con_branch"/Check/Check.sh | bash -s -- PACKAGE_MASTER)
# 获取系统版本
GET_SYSTEM_CHECK=$(curl -sl https://"$url_address"/HiddenScholars/Linux-tools/"$con_branch"/Check/Check.sh | bash -s -- SYSTEM_CHECK)
function delete_docker_docker_compose() {

    # 移除掉旧的版本
    distribution=$GET_SYSTEM_CHECK

    case "$distribution" in
        ubuntu)
            # Ubuntu发行版
             "$GET_PACKAGE_MASTER" -y remove docker-ce docker-ce-cli containerd.io
            ;;

        centos | RedHatEnterpriseServer | OracleServer | 'Anolis OS')
            # CentOS、Red Hat Enterprise Server、Oracle Linux发行版
             "$GET_PACKAGE_MASTER" -y remove docker-ce docker-ce-cli containerd.io
            ;;

        debian)
            # Debian发行版
             "$GET_PACKAGE_MASTER" -y remove docker-ce docker-ce-cli containerd.io
             "$GET_PACKAGE_MASTER" -y autoremove  --purge docker-ce docker-ce-cli containerd.io
            ;;

        *)
            echo "无法确定当前Linux发行版本"
            ;;
    esac
    # 删除所有旧的数据
     rm -rf /var/lib/docker
     rm -rf /etc/docker/daemon.json

    if [ -d /etc/docker/ ];then
    rm -rf /etc/docker/
    fi

    if [ -f /usr/lib/systemd/system/docker.service ];then
    systemctl stop docker.service
    rm -rf /usr/lib/systemd/system/docker.service
    systemctl daemon-reload
    fi

    if [ -f /usr/local/bin/docker-compose ]; then
        rm -rf /usr/local/bin/docker-compose
    fi
    }
    delete_docker_docker_compose

