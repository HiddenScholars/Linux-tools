#! /bin/bash

function install() {
    local GET_RPM_PACKAGE_NAME=($(find . -name "*.rpm" --type f))
    for (( local i = 0; local i < ${#GET_RPM_PACKAGE_NAME[@]}; local i++ )); do
        echo "选择要安装的rpm包"
        printf "$i : ${GET_RPM_PACKAGE_NAME[$i]}"
        while true; do
              read -rp "请输入序号: " local num
              if [ -n "$num" ] && [ -n ${#GET_RPM_PACKAGE_NAME[$num]} ]; then
                 rpm -ivh ${GET_RPM_PACKAGE_NAME[$num]}
                 break
              else
                 echo "序号数据错误,重新输入"
              fi
        done
    done
 }

case $i in
install|INSTALL|Install)
   install
  ;;
esac