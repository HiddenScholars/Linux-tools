#!/bin/bash

config_path=/tools/
config_file=/tools/config.xml
con_branch=$(awk -v RS="</parameters>" '/<parameters>/{gsub(/.*<parameters>[\r\n\t ]*|[\r\n\t ]*$/,"");print}' $config_file | awk -F'[><]' '/<con_branch>/{print $3}')
url_address=$(awk -v RS="</parameters>" '/<parameters>/{gsub(/.*<parameters>[\r\n\t ]*|[\r\n\t ]*$/,"");print}' $config_file | awk -F'[><]' '/<url_address>/{print $3}')
download_path=$(awk -v RS="</paths>" '/<paths>/{gsub(/.*<paths>[\r\n\t ]*|[\r\n\t ]*$/,"");print}' $config_file | awk -F'[><]' '/<download_path>/{print $3}')
install_path=$(awk -v RS="</paths>" '/<paths>/{gsub(/.*<paths>[\r\n\t ]*|[\r\n\t ]*$/,"");print}' $config_file | awk -F'[><]' '/<install_path>/{print $3}')
lnmp_package_download_urls=($(awk '/<download_urls>/,/<\/download_urls>/' $config_file | awk '/<lnmp_package_urls>/,/<\/lnmp_package_urls>/' | awk -F '[<>]' '/<url>/{print $3}'))
function download_lnmp_package() {
  echo "选择lnmp安装包版本"
  for (( i = 0; i < "${#lnmp_package_urls[@]}"; i++ )); do
      bash <(curl -sl https://"$url_address"/HiddenScholars/Linux-tools/"$con_branch"/Check/Check.sh) PACKAGE_DOWNLOAD  lnmp  $(for i in "${lnmp_package_download_urls[@]}";do printf "%s " "$i";done)
  done
  #解压目录检测
  GET_missing_dirs_lnmp=$(curl -sl https://"$url_address"/HiddenScholars/Linux-tools/"$con_branch"/Check/Check.sh | bash -s -- check_unpack_file_path)
  echo ""[$(date '+%Y-%m-%d %H:%M:%S')]" Start unzipping."
  tar xvf "$download_path"/lnmp/lnmp -C /tools/unpack_file/"$GET_missing_dirs_lnmp" --strip-components 1 &>/dev/null
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