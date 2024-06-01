#!/bin/bash

config_path=/tools/
config_file=/tools/config.xml
con_branch=$(awk -v RS="</parameters>" '/<parameters>/{gsub(/.*<parameters>[\r\n\t ]*|[\r\n\t ]*$/,"");print}' $config_file | awk -F'[><]' '/<con_branch>/{print $3}')
url_address=$(awk -v RS="</parameters>" '/<parameters>/{gsub(/.*<parameters>[\r\n\t ]*|[\r\n\t ]*$/,"");print}' $config_file | awk -F'[><]' '/<url_address>/{print $3}')
lnmp_package_download_urls=($(awk '/<download_urls>/,/<\/download_urls>/' $config_file | awk '/<lnmp_package_urls>/,/<\/lnmp_package_urls>/' | awk -F '[<>]' '/<url>/{print $3}'))

if [ -n "$GET_missing_dirs_lnmp" ] && [ -f /tools/unpack_file/"$GET_missing_dirs_lnmp"/uninstall.sh ]; then
   cd /tools/unpack_file/"$GET_missing_dirs_lnmp"/ && bash uninstall.sh
else
   echo "选择需要lnmp版本的卸载脚本"
   bash <(curl -sl https://"$url_address"/HiddenScholars/Linux-tools/"$con_branch"/Check/Check.sh) PACKAGE_DOWNLOAD  lnmp  $(for i in "${lnmp_package_download_urls[@]}";do printf "%s " "$i";done)
   GET_missing_dirs_lnmp=$(curl -sl https://"$url_address"/HiddenScholars/Linux-tools/"$con_branch"/Check/Check.sh | bash -s -- check_unpack_file_path)
   echo ""[$(date '+%Y-%m-%d %H:%M:%S')]" Start unzipping."
   tar xvf "$download_path"/lnmp/lnmp -C /tools/unpack_file/"$GET_missing_dirs_lnmp" --strip-components 1 &>/dev/null
   echo ""[$(date '+%Y-%m-%d %H:%M:%S')]" The decompression is complete."
   cd /tools/unpack_file/"$GET_missing_dirs_lnmp"/ && bash uninstall.sh
fi