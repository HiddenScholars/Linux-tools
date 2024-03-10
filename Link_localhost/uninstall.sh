#!/bin/bash
source /etc/profile
red=$(curl -sl https://"$url_address"/HiddenScholars/Linux-tools/"$con_branch"/Check/Check.sh | bash -s -- COLOR red)
green=$(curl -sl https://"$url_address"/HiddenScholars/Linux-tools/"$con_branch"/Check/Check.sh | bash -s -- COLOR green)
plain=$(curl -sl https://"$url_address"/HiddenScholars/Linux-tools/"$con_branch"/Check/Check.sh | bash -s -- COLOR plain)
if [  -f /etc/init.d/tool ]; then
    rm -rf /etc/init.d/tool && [ -L /usr/bin/tool ] && rm -rf /usr/bin/tool
    echo -e "${green}删除tool指令${plan}"
elif [ -f /tools/tool ]; then
    rm -rf /tools/tool && [ -L /usr/bin/tool ] && rm -rf /usr/bin/tool
elif [ -L /usr/bin/tool ]; then
    rm -rf /usr/bin/tool
    echo -e "${green}删除tool软连接${plan}"
else
  echo -e "${red}tool命令不存在...${plan}"
fi
