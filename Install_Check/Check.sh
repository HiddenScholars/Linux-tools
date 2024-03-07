#!/bin/bash


SystemCategory=''
SystemVersion=''
CPUArchitecture=''
controls=''
config_file=/tools/config

SET_CONFIG=$1 #$1==0

function PACKAGE_MASTER() {
if command -v apt-get &> /dev/null; then
    controls='apt-get'
elif command -v yum &> /dev/null; then
    controls='yum'
else
    controls=-1
fi
}
function SYSTEM_CHECK() {
CPUArchitecture=$(uname -m)
SystemCategory=$(awk -F= '/^NAME/{print $2}' /etc/os-release)
if [  "$SystemCategory" == '"CentOS Linux"' ];then
SystemVersion="centos"
elif [ "$SystemCategory" == '"Ubuntu"' ];then
SystemVersion="ubuntu"
elif [ "$SystemCategory" == '"Debian GNU/Linux"' ];then
SystemVersion="debian"
else
SystemVersion=-1
fi
}
#DIRECTIVES_CHECK
DIRECTIVES=() #install list
NOTFONUDDIRECTIVES=() #install faliled
function DIRECTIVES_CHECK() {
    NOTFONUDDIRECTIVES_EXEC=$1 #$1==0 repo install
    GET_WHICH=$(command -v which | wc -l)
    if [ "${GET_WHICH}" != 0 ]; then
        for i in "${DIRECTIVES[@]}"
        do
          which "$i"
          if [ $? -ne 0  ]; then
              NOTFONUDDIRECTIVES+=("$i")
          fi
        done
    fi
    if [ -n "$NOTFONUDDIRECTIVES_EXEC" ] && [ "$NOTFONUDDIRECTIVES_EXEC" -eq 0 ]; then
        for (( i = 0; i < "${#NOTFONUDDIRECTIVES[@]}"; i++ )); do
               $controls -y install "$y"
               if [ $? -eq 0  ]; then
                   unset "${NOTFONUDDIRECTIVES[$i]}"
               fi
        done
        if [ "${#NOTFONUDDIRECTIVES[@]}" -ne 0 ]; then
              for (( i = 0; i < "${#NOTFONUDDIRECTIVES[@]}"; i++ )); do
                  printf "$i\t"
              done
              echo "install failed!"
        fi
    fi

}
PACKAGE_MASTER
SYSTEM_CHECK
if [ "$SET_CONFIG" == 0 ];then
   if [ "$controls" != "-1" ] && [ "$SystemVersion" != "-1" ] && [ "$CPUArchitecture" == "x86_64" ] && [ -f "$config_file" ]; then
        GET_CONTROLS=$(cat "$config_file" | grep controls= | wc -l)
        if [ "$GET_CONTROLS" == "1" ]; then
           sed -i "s/controls=.*/controls=$controls/g" $config_file
        else
           echo "controls=$controls" >> "$config_file"
        fi
        GET_CPUArchitecture=$(cat "$config_file" | grep CPUArchitecture= | wc -l)
        if [ "$GET_CPUArchitecture" == "1" ]; then
            sed -i "s/CPUArchitecture=.*/CPUArchitecture=$GET_CPUArchitecture/g" $config_file
        else
            echo "CPUArchitecture=$GET_CPUArchitecture" >> $config_file
        fi
        GET_SystemVersion=$(cat "$config_file" | grep SystemVersion= | wc -l)
        if [ "$GET_SystemVersion" == "1" ]; then
            sed -i "s/SystemVersion=.*/SystemVersion=$SystemVersion/g" $config_file
        else
            echo "SystemVersion=$SystemVersion" >> $config_file
        fi
   else
     if [ -f "$config_file" ]; then
        echo "不支持的版本"
        echo "软件包管理器：$controls"
        echo "Linux系统版本：$SystemVersion"
        echo "CPU架构：$CPUArchitecture"
        exit 0
    else
        echo "$config_file not found."
     fi
   fi

fi