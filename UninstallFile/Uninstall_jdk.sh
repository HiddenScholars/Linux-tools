#!/bin/bash

echo ""[$(date '+%Y-%m-%d %H:%M:%S')]" 卸载开始"
source /tools/config
source /etc/profile
"$controls" remove java* openjdk*  -y &>/dev/null


if [ -d "$JAVA_HOME" ]; then
    rm -rf "$JAVA_HOME"
fi
sed -i "\|export JAVA_HOME=$jdk_install_path|d" /etc/profile
sed -i "\|export PATH=.*|d" /etc/profile
sed -i "\|export CLASSPATH=.*|d" /etc/profile
echo ""[$(date '+%Y-%m-%d %H:%M:%S')]" 卸载完成"