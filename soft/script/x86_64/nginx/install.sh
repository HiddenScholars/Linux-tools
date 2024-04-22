#!/bin/bash
#create time 2024-04-19

function install() {
    script_dir=$(cd "$(dirname "$0")" && pwd)
    source "$script_dir"/install.conf
    process=("nginx")
    prot=(80)
    bash "$script_dir"/detect/Check.sh PortCheck "${port[@]}"
    bash "$script_dir"/detect/Check.sh ProcessCheck "${process[@]}"
      if [ "$SystemVersion" == "centos" ] || [ "$SystemVersion" == "Anolis OS" ]; then
      yum_package=(gcc gcc-c++ zlib zlib-devel pcre-devel openssl openssl-devel gd-devel)
      for i in "${yum_package[@]}"
      do
       "$controls" -y install  "$i"
      done
  elif [ "$SystemVersion" == "ubuntu" ] || [ "$SystemVersion" == "debian" ]; then
       apt_package=(build-essential gcc gcc-c++ zlib1g zlib1g-dev libpcre3-dev libssl-dev libgd-dev)
       for y in "${apt_package[@]}"
       do
          "$controls" -y install "$y"
       done
  else
    echo "未支持的系统版本"
    exit 1
  fi
}
install