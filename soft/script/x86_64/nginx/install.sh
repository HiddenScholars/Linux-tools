#!/bin/bash
#create time 2024-04-19

function install() {
    local originate_dir=$(pwd | awk -F '/Linux-tools' '{print $1 "/Linux-tools/"}')
    local script_dir=$(pwd | awk -F '/Linux-tools' '{print $1 "/Linux-tools" $2}')
    bash "$originate_dir"/detect/Check.sh clean_tmp
    source "$originate_dir"/install.conf
    bash "$originate_dir"/detect/Check.sh PathCheck "$install_path"/nginx/
    [ $? -ne 0 ] && exit 1
    process=("nginx")
    port=(80)
    bash "$originate_dir"/detect/Check.sh PortCheck "${port[@]}"
    [ $? -ne 0 ] && exit 1
    bash "$originate_dir"/detect/Check.sh ProcessCheck "${process[@]}"
    [ $? -ne 0 ] && exit 1
    # 依赖安装
    ## 循环计数器
    count=0
    # 统计软件包数量
    total=$(find "$originate_dir"/soft/depend/"$os_arch"/"$os"/nginx/ | tail -n +2 | wc -l)
    # 查找软件包并循环安装
    for rpm in $(find "$originate_dir"/soft/depend/"$os_arch"/"$os"/nginx/ | tail -n +2); do
        ((count++))
        # 更新进度条
        progress=$((count * 100 / total))
        echo -ne "依赖安装: $progress%   \r"
        if [ "$os" == "centos_7" ]; then
            rpm -Uvh --force "$rpm" 2>&1 | while IFS= read -r line; do echo "[$(date +'%Y-%m-%d %H:%M:%S')] $line"; done >> "$script_dir"/install.log
        elif [ "$os" == "ubuntu" ]; then
            dpkg -i "$rpm" 2>&1 | while IFS= read -r line; do echo "[$(date +'%Y-%m-%d %H:%M:%S')] $line"; done >> "$script_dir"/install.log
        fi
    done
    printf "\n"
    #解压安装包到tmp临时目录
    bash "$originate_dir"/detect/Check.sh check_package_version nginx
    [ $? -ne 0 ] && exit 1
    cd "$originate_dir"/tmp/
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] Start install... "
    useradd -s /sbin/nologin "$nginx_user"
    nginx_install=$(echo "$install_path"/nginx/ | tr -s '/')
    set -x
    ./configure --prefix="$nginx_install" --user="$nginx_user" --group="$nginx_user" "${nginx_compile_parameter[@]}" && make && make install
    set +x
    if [ $? -eq 0 ]; then
       echo "[$(date '+%Y-%m-%d %H:%M:%S')] The installation is complete"
    else
       echo "[$(date '+%Y-%m-%d %H:%M:%S')] Failed to install"
       exit 1
    fi
    chown -R "$nginx_user":"$nginx_user" "$install_path"/nginx/
    bash "$originate_dir"/detect/Check.sh SetVariables PATH "$install_path"/nginx/sbin/ /etc/profile
    source /etc/profile
    if nginx -v &>/dev/null;then
      echo "安装成功"
      cp -rf "$originate_dir"/soft/systemd/nginx/nginx.service /etc/systemd/system/
      ExecStartPre=$(echo "$install_path"/nginx/sbin/nginx | tr -s '/')
      sed -i "s|ExecStartPre=.*|ExecStartPre=$ExecStartPre -t|g" /etc/systemd/system/nginx.service
      sed -i "s|ExecStart=.*|ExecStart=$ExecStartPre|g" /etc/systemd/system/nginx.service
      sed -i "s|ExecReload=.*|ExecReload=$ExecStartPre -s reload|g" /etc/systemd/system/nginx.service
      sed -i "s|ExecStop=.*|ExecStop=$ExecStartPre -s stop|g" /etc/systemd/system/nginx.service
      systemctl daemon-reload
      systemctl start nginx
      if [ $? -eq 0 ]; then
          echo "启动成功"
          systemctl enable nginx
      fi
    else
      echo "安装失败"
    fi

}
install