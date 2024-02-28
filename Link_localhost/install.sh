#!/bin/bash
source /tools/config.sh
#修改tool更新内容
function setTool(){
  cat > /tools/tool << 'EOF'
  source /tools/config.sh &>/dev/null
  if [ ! -z $url_address ];then
  bash <(curl -Ls https://$url_address/HiddenScholars/Linux-tools/$con_branch/tools.sh)
  else
      echo -e "${red}url_address不得为空请检查config.sh配置文件${plain}"
  fi
EOF
  chmod +x /tools/tool
}

if [ -d /tools/tool ] && [ ! -f /tools/tool ];then
echo -e "${green}是否添加本地软连接，添加后可以直接通过tool命令直接调用菜单${plain}"
read -p "回车确定安装，输入n不安装：" link_select
[ "$link_select" == "n" ] && return
cat > /tools/tool << 'EOF'
setTool
  if [ ! -L /tools/tool ]; then
     ln -s /tools/tool /usr/bin/
  else
      echo -e "${red}软连接已存在，不再添加${plain}"
  fi
echo -e "${green}tool指令已添加，后续可通过tool命令直接调用菜单，不需要后可直接通过[ -f /tools/tool] && rm -rf /tools/tool && [ -L /usr/bin/tool ] && rm -rf /usr/bin/tool删除${plain}"

else
  echo -e "tool指令不再添加"
setTool
EOF
fi