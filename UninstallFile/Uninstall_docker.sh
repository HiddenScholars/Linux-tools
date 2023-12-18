source /tools/config.sh

function remove_old_docker() {

    # 移除掉旧的版本
    distribution=$release

    case "$distribution" in
        ubuntu)
            # Ubuntu发行版
             apt-get remove docker-ce docker-ce-cli containerd.io
            ;;

        centos | RedHatEnterpriseServer | OracleServer)
            # CentOS、Red Hat Enterprise Server、Oracle Linux发行版
             yum remove docker-ce docker-ce-cli containerd.io
            ;;

        Fedora)
            # Fedora发行版
             dnf remove docker-ce docker-ce-cli containerd.io
            ;;

        debian)
            # Debian发行版
             apt-get remove docker-ce docker-ce-cli containerd.io
             apt-get autoremove -y --purge docker-ce docker-ce-cli containerd.io
            ;;

        FreeBSD)
            # FreeBSD发行版
             pkg remove -y docker
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

    }
    remove_old_docker
