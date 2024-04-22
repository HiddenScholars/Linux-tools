#!/bin/bash

config_path=/tools/
config_file=/tools/config.xml
controls=$(awk -v RS="</system>" '/<system>/{gsub(/.*<system>[\r\n\t ]*|[\r\n\t ]*$/,"");print}' $config_file | awk -F'[><]' '/<controls>/{print $3}')

"$controls" remove tailscale

if [ -f /var/lib/tailscale/tailscaled.state ]; then
    rm -rf /var/lib/tailscale/tailscaled.state
    echo "删除完成"
fi
echo "卸载完成"