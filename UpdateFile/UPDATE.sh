#!/bin/bash
source /tools/config &>/dev/null
     if [ -f /tools/config ]; then
        mv /tools/config /tools/config_bak
        wget -P "$config_path" https://"$url_address"/HiddenScholars/Linux-tools/"$con_branch"/config
        if [ $? -eq 0 ]; then
            sed -i "s/url_address=.*/url_address=$url_address/g" /tools/config #下载完成后修改仓库地址
            sed -i "s/con_branch=.*/con_branch=$con_branch/g" /tools/config #下载完成后修改分支
            rm -rf /tools/config_bak
        fi
    else
       echo "not found config."
       exit 0
    fi
    bash <(curl -sL https://"$url_address"/HiddenScholars/Linux-tools/"$con_branch"/Link_localhost/uninstall.sh) # tool link uninstall.sh
    bash <(curl -sL https://"$url_address"/HiddenScholars/Linux-tools/"$con_branch"/Link_localhost/install.sh) # tool link install.sh
    bash <(curl -sl https://"$url_address"/HiddenScholars/Linux-tools/"$con_branch"/Check/Check.sh) SET_CONFIG