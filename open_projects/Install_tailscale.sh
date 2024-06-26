#!/bin/bash
echo "如果网络环境较差，脚本会自动循环安装10次，确保完成安装。"
config_path=/tools/
config_file=/tools/config.xml
con_branch=$(awk -v RS="</parameters>" '/<parameters>/{gsub(/.*<parameters>[\r\n\t ]*|[\r\n\t ]*$/,"");print}' $config_file | awk -F'[><]' '/<con_branch>/{print $3}')
url_address=$(awk -v RS="</parameters>" '/<parameters>/{gsub(/.*<parameters>[\r\n\t ]*|[\r\n\t ]*$/,"");print}' $config_file | awk -F'[><]' '/<url_address>/{print $3}')
for (( i = 0; i < 11; i++ )); do
  GET_DIRECTIVES_CHECK=$(curl -sl https://"$url_address"/HiddenScholars/Linux-tools/"$con_branch"/Check/Check.sh | bash -s -- DIRECTIVES_CHECK tailscale)
  if [ "${#GET_DIRECTIVES_CHECK[@]}" -eq 0 ]; then
      echo "[$(date '+%Y-%m-%d %H:%M:%S')] tailscale 安装成功"
  fi
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] 第 $i 次循环"
  set -x
  curl -fsSL https://tailscale.com/install.sh | sh
  set +x
  if [ "${#GET_DIRECTIVES_CHECK[@]}" -eq 10 ]; then
     echo "[$(date '+%Y-%m-%d %H:%M:%S')] 安装失败"
  fi
done

