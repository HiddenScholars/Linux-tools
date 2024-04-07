#!/bin/bash
source /tools/config &>/dev/null

function SetTool(){
  cat > /tools/tool << 'EOF'
  source /tools/config &>/dev/null
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
SetTool
curl -sl https://"$url_address"/HiddenScholars/Linux-tools/"$con_branch"/Check/Check.sh | bash -s SetVariables PATH /tools/ /etc/profile