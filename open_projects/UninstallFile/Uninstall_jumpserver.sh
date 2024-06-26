#!/bin/bash

jmsctl_path=$(find / -name jmsctl.sh)
if [ -f "$jmsctl_path" ]; then
    $jmsctl_path uninstall
else
  echo "jmsctl.sh not found"
fi
if [ -d /opt/jumpserver/ ]; then
    rm -rf /opt/jumpserver-*
fi