#!/bin/bash
source /tools/config.sh &>/dev/null

function setTool(){
  cat > /tools/tool << 'EOF'
  source /tools/config.sh &>/dev/null
  if [ -z $url_address ];then
  set -x
  url_address=raw.githubusercontent.com
  set +x
  fi
  if [ -z $con_branch ];then
   set -x
   con_branch=main
   set +x
  fi
  bash <(curl -Ls https://$url_address/HiddenScholars/Linux-tools/$con_branch/tools.sh)
EOF
  chmod +x /tools/tool
}

if  [  ! -f /tools/tool ];then
  setTool
fi
if [ ! -L /usr/bin/tool ]; then
  ln -s /tools/tool /usr/bin/
fi