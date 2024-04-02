#!/bin/bash

if [ -f /tools/unpack_file/"$GET_missing_dirs_nginx"/uninstall.sh ]; then
  bash /tools/unpack_file/"$GET_missing_dirs_nginx"/uninstall.sh
else
  echo "使用lnmp2.0版本的卸载脚本"
   bash <(curl -sl https://"$url_address"/HiddenScholars/Linux-tools/"$con_branch"/Check/Check.sh) PACKAGE_DOWNLOAD  lnmp2.0  https://soft.lnmp.com/lnmp/lnmp2.0.tar.gz
   GET_missing_dirs_lnmp=$(curl -sl https://"$url_address"/HiddenScholars/Linux-tools/"$con_branch"/Check/Check.sh | bash -s -- check_unpack_file_path)
   bash /tools/unpack_file/"$GET_missing_dirs_lnmp"/uninstall.sh
fi