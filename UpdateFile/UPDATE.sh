#!/bin/bash
    if [ -f /tools/config.sh ]; then
        source /tools/config.sh
        mv /tools/config.sh /tools/config.sh_bak
        wget -P "${config_path}" https://"$url_address"/HiddenScholars/Linux-tools/"$con_branch"/config.sh
        if mycmd; then
            sed -i "s/url_address=.*/url_address=$url_address/g" "$config_file" #下载完成后修改仓库地址
            sed -i "s/con_branch=.*/con_branch=$con_branch/g" "$config_file" #下载完成后修改分支
            rm -rf /tools/config.sh_bak
        fi
    else
       echo "not found config.sh."
    fi
    bash <(curl -sL https://"$url_address"/HiddenScholars/Linux-tools/"$con_branch"/Link_localhost/uninstall.sh) # tool link uninstall.sh
    bash <(curl -sL https://"$url_address"/HiddenScholars/Linux-tools/"$con_branch"/Link_localhost/install.sh) # tool link install.sh
