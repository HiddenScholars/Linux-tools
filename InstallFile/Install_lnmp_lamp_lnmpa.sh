#!/bin/bash

source /tools/config &>/dev/null
function download_lnmp_package() {
  bash <(curl -sl https://"$url_address"/HiddenScholars/Linux-tools/"$con_branch"/Check/Check.sh) PACKAGE_DOWNLOAD  lnmp2.0  "$lnmp_package_urls"
  #解压目录检测
  GET_missing_dirs_lnmp=$(curl -sl https://"$url_address"/HiddenScholars/Linux-tools/"$con_branch"/Check/Check.sh | bash -s -- check_unpack_file_path)
  echo ""[$(date '+%Y-%m-%d %H:%M:%S')]" Start unzipping."
  tar xvf "$download_path"/lnmp2.0/lnmp2.0 -C /tools/unpack_file/"$GET_missing_dirs_lnmp" --strip-components 1 &>/dev/null
  echo ""[$(date '+%Y-%m-%d %H:%M:%S')]" The decompression is complete."
}
case $1 in
lnmp)
  download_lnmp_package
  cd /tools/unpack_file/"$GET_missing_dirs_lnmp"/ && bash install.sh lnmp
  ;;
lnmpa)
  download_lnmp_package
  cd /tools/unpack_file/"$GET_missing_dirs_lnmp"/ && bash install.sh lnmpa
  ;;
lamp)
  download_lnmp_package
  cd /tools/unpack_file/"$GET_missing_dirs_lnmp"/ && bash install.sh lamp
  ;;
nginx)
  download_lnmp_package
  cd /tools/unpack_file/"$GET_missing_dirs_lnmp"/ && bash install.sh nginx
  ;;
db)
  download_lnmp_package
  cd /tools/unpack_file/"$GET_missing_dirs_lnmp"/ && bash install.sh db
  ;;
mphp)
  download_lnmp_package
  cd /tools/unpack_file/"$GET_missing_dirs_lnmp"/ && bash install.sh mphp
  ;;
*)
  echo "not found"
  ;;
esac