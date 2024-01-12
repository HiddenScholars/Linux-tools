#!/bin/bash
source /etc/profile
if [  -f /etc/init.d/tool ]; then
    rm -rf /etc/init.d/tool && [ -L /usr/bin/tool ] && rm -rf /usr/bin/tool
elif [ -L /usr/bin/tool ]; then
    rm -rf /usr/bin/tool
else
  echo -e "${red}tool命令不存在...${plan}"
fi
