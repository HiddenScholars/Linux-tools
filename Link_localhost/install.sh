#!/bin/bash
source /tools/config.sh
#修改tool更新内容
function setTool(){
  cat > /etc/init.d/tool << 'EOF'
  source /tools/config.sh &>/dev/null
  if [ ! -z $url_address ];then
  bash <(curl -Ls https://$url_address/HiddenScholars/Linux-tools/main/tools.sh)
  elif [ ! -f /tools/config.sh ];then
      url_address_numbers=("raw.githubusercontent.com" "raw.yzuu.cf")

            for i in "${!url_address_numbers[@]}"
            do
                echo "$i：${url_address_numbers[$i]}"
            done
      read -p  "config.sh配置文件不存在,请选择或输入临时下载地址用于访问github仓库：" url_address_select
      if [[ $url_address_select =~ ^[0-9]+$ ]];then
          if [ ! -z  ${url_address_numbers[$url_address_select]} ];then
             bash <(curl -Ls https://${url_address_numbers[$url_address_select]}/HiddenScholars/Linux-tools/main/tools.sh)
          else
             echo "不存在的地址"
             exit 0
          fi
      elif [[ $url_address_select =~ [a-zA-Z0-9]+\.[a-zA-Z]{2,3}(/\S*)?$ ]];then
           bash <(curl -Ls https://$url_address_select/HiddenScholars/Linux-tools/main/tools.sh)
      else
          echo "参数错误"
      fi
  else
      echo -e "${red}url_address不得为空请检查config.sh配置文件${plain}"

  fi
EOF
  chmod +x /etc/init.d/tool

}

if [ -d /etc/init.d/ ] && [ ! -f /etc/init.d/tool ];then
echo -e "${green}是否添加本地软连接，添加后可以直接通过tool命令直接调用菜单${plain}"
read -p "回车确定安装，输入n不安装：" link_select
[ "$link_select" == "n" ] && return
cat > /etc/init.d/tool << 'EOF'
setTool
  if [ ! -L /etc/init.d/tool ]; then
     ln -s /etc/init.d/tool /usr/bin/
  else
      echo -e "${red}软连接已存在，不再添加${plain}"
  fi
echo -e "${green}tool指令已添加，后续可通过tool命令直接调用菜单，不需要后可直接通过[ -f /etc/init.d/tool] && rm -rf /etc/init.d/tool && [ -L /usr/bin/tool ] && rm -rf /usr/bin/tool删除${plain}"

else
  echo -e "tool指令不再添加"
setTool
fi