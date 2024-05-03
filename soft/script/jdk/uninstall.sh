#!/bin/bash

config_path=/tools/
config_file=/tools/config.xml
controls=$(awk -v RS="</system>" '/<system>/{gsub(/.*<system>[\r\n\t ]*|[\r\n\t ]*$/,"");print}' $config_file | awk -F'[><]' '/<controls>/{print $3}')
source /etc/profile
"$controls" remove java* openjdk*  -y &>/dev/null

if [ -d "$JAVA_HOME" ]; then
    rm -rf "$JAVA_HOME"
fi
sed -i "\|export JAVA_HOME=.*|d" /etc/profile
sed -i "\|export PATH=.*|d" /etc/profile
sed -i "\|export CLASSPATH=.*|d" /etc/profile