config_path=/tools/
config_file=/tools/config.xml
con_branch=$(awk -v RS="</parameters>" '/<parameters>/{gsub(/.*<parameters>[\r\n\t ]*|[\r\n\t ]*$/,"");print}' $config_file | awk -F'[><]' '/<con_branch>/{print $3}')
url_address=$(awk -v RS="</parameters>" '/<parameters>/{gsub(/.*<parameters>[\r\n\t ]*|[\r\n\t ]*$/,"");print}' $config_file | awk -F'[><]' '/<url_address>/{print $3}')
controls=$(awk -v RS="</system>" '/<system>/{gsub(/.*<system>[\r\n\t ]*|[\r\n\t ]*$/,"");print}' $config_file | awk -F'[><]' '/<controls>/{print $3}')
# 获取系统版本
SystemVersion=$(awk -v RS="</system>" '/<system>/{gsub(/.*<system>[\r\n\t ]*|[\r\n\t ]*$/,"");print}' $config_file | awk -F'[><]' '/<SystemVersion>/{print $3}')
function delete_docker_docker_compose() {

    # 移除掉旧的版本
    distribution=$SystemVersion

    case "$distribution" in
        ubuntu)
            # Ubuntu发行版
             "$controls" -y remove docker-ce docker-ce-cli containerd.io
            ;;

        centos | RedHatEnterpriseServer | OracleServer | 'Anolis OS')
            # CentOS、Red Hat Enterprise Server、Oracle Linux发行版
             "$controls" -y remove docker-ce docker-ce-cli containerd.io
            ;;

        debian)
            # Debian发行版
             "$controls" -y remove docker-ce docker-ce-cli containerd.io
             "$controls" -y autoremove  --purge docker-ce docker-ce-cli containerd.io
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

