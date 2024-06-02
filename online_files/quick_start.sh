#! /bin/bash

echo "version: 2024.6.2"
DIR=$(cd "$(dirname "$0")" && pwd)
if [ -f $DIR/env/config.yaml ];then
  source $DIR/env/config.yaml
else
  echo "未找到config.yaml"
  exit 1
fi

url=$(echo $get_url_address:$get_port/$get_path | tr -s '/')

#!/bin/bash

# 定义菜单选项
menu() {
  echo "请选择一个选项:"
  echo "1. 安装"
  echo "2. 检测包管理器"
  echo "3. 检查Docker和Docker Compose"
  echo "4. 查看本机服务器IP"
  echo "0. 退出"
  read -p "输入数字选择: " choice
  case $choice in
    1) check_network ;;
    2) detect_package_manager ;;
    3) check_docker_tools ;;
    4) show_server_ips ;;
    0) echo "退出程序。"; exit ;;
    *) echo "无效的选项，请重新选择。"; menu ;;
  esac
}

# 功能定义与之前相同，略去以保持示例简洁

# 主程序
main() {
  echo "欢迎使用网络与系统检测工具！"
  menu
}

# 确保脚本可执行后，运行main函数
main


