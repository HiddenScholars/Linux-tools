#!/bin/bash
source /tools/config.sh
if [ -d /etc/init.d/ ] && [ ! -f /etc/init.d/tool ];then
echo -e "${green}是否添加本地软连接，添加后可以直接通过tool命令直接调用菜单${plain}"
read -p "回车确定安装，输入n不安装：" link_select
[ "$link_select" == "n" ] && return
cat >> /etc/init.d/tool << EOF
bash <(curl -Ls https://raw.githubusercontent.com/HiddenScholars/Linux-tools/main/tools.sh)
EOF
chmod +x /etc/init.d/tool
  if [ ! -L /etc/init.d/tool ]; then
     ln -s /etc/init.d/tool /usr/bin/
  else
      echo -e "${red}软连接已存在，不再添加${plain}"
  fi
echo -e "${green}tool指令已添加，后续可通过tool命令直接调用菜单，不需要后可直接通过[ -f /etc/init.d/tool] && rm -rf /etc/init.d/tool && [ -L /usr/bin/tool ] && rm -rf /usr/bin/tool删除${plain}"
else
  echo -e "tool指令不添加"

fi