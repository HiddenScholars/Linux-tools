#!/bin/bash

# 功能1: 检测网络
# 访问国内网站
check_china_network() {
  local china_time=$(curl -s -w "%{time_total}\n" -o /dev/null https://www.baidu.com)
  echo "访问淘宝的时间: $china_time秒"

  # 假设如果访问淘宝的时间小于访问Google的时间，则认为在国内
  return $((china_time < foreign_time))
}
# 访问国外网站
check_foreign_network() {
  local foreign_time=$(curl -s -w "%{time_total}\n" -o /dev/null https://www.google.com)
  echo "访问Google的时间: $foreign_time秒"
}
check_network() {
  check_foreign_network
  check_china_network

  if [ $? -eq 0 ]; then
    echo "看起来您在国内网络下。"
  else
    echo "看起来您在国外网络下。"
  fi
}

# 功能2: 检测包管理器
detect_package_manager() {
  if command -v apt-get &> /dev/null; then
    echo "使用的是APT包管理器 (Debian/Ubuntu)"
  elif command -v yum &> /dev/null; then
    echo "使用的是YUM包管理器 (CentOS/RHEL)"
  elif command -v dnf &> /dev/null; then
    echo "使用的是DNF包管理器 (Fedora/CentOS 8+)"
  elif command -v zypper &> /dev/null; then
    echo "使用的是ZYPPER包管理器 (openSUSE/SUSE)"
  else
    echo "无法识别包管理器"
  fi
}

# 功能3: 检测docker和docker-compose
check_docker_tools() {
  if command -v docker &> /dev/null; then
    echo "Docker 已安装"
  else
    echo "Docker 未安装"
  fi

  if command -v docker-compose &> /dev/null; then
    echo "docker-compose 已安装"
  else
    echo "docker-compose 未安装"
  fi
}

# 功能4: 查看本地IP并让用户选择
show_server_ips() {
  local ip_list=()
  ip_list+=($(ip addr show | grep 'inet ' | awk '{print $2}' | cut -d/ -f1))

  echo "请选择服务器IP:"
  for ((i=0; i<${#ip_list[@]}; i++)); do
    echo "$((i+1)). ${ip_list[$i]}"
  done

  read -p "输入序号: " choice
  if [[ $choice =~ ^[0-9]+$ && $choice -le ${#ip_list[@]} ]]; then
    echo "您选择的IP是: ${ip_list[$choice-1]}"
  else
    echo "无效的选择！"
  fi
}

# 执行各个功能
check_network
detect_package_manager
check_docker_tools
show_server_ips
