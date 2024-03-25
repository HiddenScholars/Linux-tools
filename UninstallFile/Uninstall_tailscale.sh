#!/bin/bash

source /tools/config

"$controls" remove tailscale

if [ -f /var/lib/tailscale/tailscaled.state ]; then
    rm -rf /var/lib/tailscale/tailscaled.state
    echo "删除完成"
fi
echo "卸载完成"