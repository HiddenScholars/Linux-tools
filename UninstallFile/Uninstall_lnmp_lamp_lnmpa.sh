#!/bin/bash

if [ -f /tools/unpack_file/"$GET_missing_dirs_nginx"/uninstall.sh ]; then
  bash /tools/unpack_file/"$GET_missing_dirs_nginx"/uninstall.sh
else
  echo "使用lnmp2.0版本的卸载脚本"
   bash <(curl -sl https://"$url_address"/HiddenScholars/Linux-tools/"$con_branch"/Check/Check.sh) PACKAGE_DOWNLOAD  lnmp2.0  "$lnmp_package_urls"
   GET_missing_dirs_lnmp=$(curl -sl https://"$url_address"/HiddenScholars/Linux-tools/"$con_branch"/Check/Check.sh | bash -s -- check_unpack_file_path)
   cd /tools/unpack_file/"$GET_missing_dirs_lnmp"/ && bash uninstall.sh
fi