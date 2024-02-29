#!/bin/bash
nginx_download_url=
docker_download_url=
select_download_version=
config_path=/tools/
config_file=/tools/config.sh
version_file=$config_path/version
source $config_file &>/dev/null

function manage_download() {
  #server_name下载服务名
  #download_url下载链接
  #select_download_version下载版本搜索
  [ -z "$server_name" ] && echo -e "${red} 禁止server_name为空使用 ${plain}" && exit
  [ -z "$download_url" ] && echo -e "${red} 禁止download_url为使用 ${plain}" && exit
  [ ! -d "$download_path"/"$server_name" ] &&  mkdir -p "$download_path"/"$server_name"
  getDownloadFileNumber=$(find "$download_path/$server_name" -maxdepth 1 -type f -o -type d -name "*$select_download_version*" | wc -l)
          if [ "${getDownloadFileNumber}" -ne 0 ];then
                echo -e "${red}$download_path/$server_name/中存在该版本安装包${plain}"
                echo
               cd "$download_path"/"$server_name"/ || exit
                    # 定义一个空数组用于存储符合条件的文件
                    files=()

                    # 获取目录下所有文件，并将符合条件的文件添加到数组中
                    for file in *; do
                      # 过滤文件的条件，可以根据需求进行修改
                      if [[  "$file" =~ .*${select_download_version}.*  ]]; then
                        files+=("$file")
                      fi
                    done

                    # 对数组进行排序，并打印文件名和数字序号
                    IFS=$'\n' sorted_files=($(sort <<<"${files[*]}"))
                    for i in "${!sorted_files[@]}"
                    do
                      echo -e "${green}$((i)):${sorted_files[$i]}${plain}"
                    done
                echo
                echo
                read -rp  "文件夹中存在文件是否继续下载(y/n)(default:n):" download_select

                if [ "$download_select" == "y" ]; then
                      wget -P "$download_path"/"$server_name"/ "$download_url"
                      cd "$download_path"/"$server_name"/ || exit
                      # 定义一个空数组用于存储符合条件的文件
                      files=()

                      # 获取目录下所有文件，并将符合条件的文件添加到数组中
                      for file in *; do
                        # 过滤文件的条件，可以根据您的需求进行修改
                        if [[  "$file" =~ .*${select_download_version}.*  ]]; then
                          files+=("$file")
                        fi
                      done

                      # 对数组进行排序，并打印文件名和数字序号
                      IFS=$'\n' sorted_files=($(sort <<<"${files[*]}"))
                      for i in "${!sorted_files[@]}"; do
                        echo -e "${green}$((i)):${sorted_files[$i]}${plain}"
                      done
                      #标记执行过下载安装包命令
                      if_select=0
                else
                      #标记不执行
                      if_select=1
                fi
              fi
              if [ "$if_select" != 1 ] && [ "$if_select" != 0 ]; then
                wget -P "$download_path"/"$server_name"/ "$download_url"
                cd "$download_path"/"$server_name"/ || exit
                # 定义一个空数组用于存储符合条件的文件
                files=()

                # 获取目录下所有文件，并将符合条件的文件添加到数组中
                for file in *; do
                  # 过滤文件的条件，可以根据需求进行修改
                  if [[  "$file" =~ .*${select_download_version}.*  ]]; then
                    files+=("$file")
                  fi
                done

                # 对数组进行排序，并打印文件名和数字序号
                IFS=$'\n' sorted_files=($(sort <<<"${files[*]}"))
                for i in "${!sorted_files[@]}"; do
                  echo -e "${green}$((i)):${sorted_files[$i]}${plain}"
                done
              fi

              read -rp "选择安装包序号：" select
              if [ -z "$select" ]; then
                  echo -e "${red}未选择安装包，退出脚本${plain}"
                  exit 0
              fi
}
function check_install_system() {
    [ -z "$test_server_port" ] && [ -z "$process" ] && echo -e "$red test_server_port与process禁止为空使用 $plain" && exit
    #test_server_port=() 检查此数组中的端口
    netstat -ntpl|grep LISTEN|awk '{print $4}' >/opt/test_sys.txt
    #process=(nginx) 检查此数组中的进程
        num=0
        for line in $(cat /tools/test_sys.txt)
        do
            sys_port=${line##*:}
            for i in ${test_server_port[*]}
            do
                if [ "$sys_port" -eq "$i" ];then
                    echo -e "\033[31m $sys_port端口已存在，占用服务端口 \033[0m"
                    let  num=$num+1
                fi
            done
        done
        u=0
        if [ "$num" -eq 0 ]
        then
            for pro in "${process[@]}"
            do
                getProcessNumber=$(pgrep "$pro" | wc -l)
                if [ "$getProcessNumber" -ne 0 ]
                then
                    echo "$pro有残余进程，删除后再次执行脚本检测安装环境"
    				continue=''
                      read -rp "是否继续安装，继续安装可能会无法启动（y/n）:" continue
                        if [ "$continue" != "y" ]; then
                        exit 1
                        fi
    				return
                    let  u=$u+1
                fi
            done
        else
          continue=''
          read -rp "是否继续安装，继续安装可能会无法启动（y/n）:" continue
            if [ "$continue" != "y" ]; then
            exit 1
            fi
        fi
}
function check_unpack_file_path() {
    [ ! -d $config_path/unpack_file ] && mkdir -p $config_path/unpack_file
    getUnpackNumber=$(find "$config_path/unpack_file/" -maxdepth 1 -type f -o -type d | wc -l)
    if [ "$getUnpackNumber" -gt  11 ];then
      source $config_file &>/dev/null
      cd $config_path/ && tar cvf unpack_file_bak"$time".tar.gz unpack_file/*
      rm -rf unpack_file/*
      mv $config_path/unpack_file_bak* unpack_file/
    fi
    # 存放不存在的目录的变量
    missing_dirs=""
    # 检测并创建目录
    for ((i=1; i<=100; i++)); do
        dir=$i
        if [ ! -d "$config_path/unpack_file/$dir" ]; then
            mkdir "$config_path/unpack_file/$dir"
            missing_dirs=$dir
            let i+=100
        fi
    done
}
function check_update() {
  GET_REMOTE_VERSION=$(curl -s https://"$url_address"/HiddenScholars/Linux-tools/"$con_branch"/version)
  GET_LOCAL_VERSION=$(cat $version_file)
          if [[ "$GET_LOCAL_VERSION" =~ ^[0-9]+$ ]] && [ "$GET_REMOTE_VERSION"  -ne "$GET_LOCAL_VERSION" ];then
             # shellcheck disable=SC2086
             bash <(curl -sL https://$url_address/HiddenScholars/Linux-tools/$con_branch/UpdateFile/UPDATE.sh)
             if mycmd; then
             echo "GET_REMOTE_VERSION" >$version_file
             fi
             echo -e"${green}已是最新版本${plain}"
          else
             echo -e "${red} 版本参数错误 ${plain}"
          fi
}
function install_nginx() {
     #check pid port
     process=(nginx)
     test_server_port=(80 443)
     check_install_system
     #check END
regex="nginx-([0-9]+\.[0-9]+\.[0-9]+)"
nginx_download_urls_select=0
temp_number=()
url=''
for url in "${nginx_download_urls[@]}"
do
    if [[ $url =~ $regex ]]; then
        version="${BASH_REMATCH[1]}"
        echo -e "${green}$nginx_download_urls_select：$version${plain}"
        temp_number+=("$version")
    fi
let nginx_download_urls_select=$nginx_download_urls_select+1
done
select=''
      read -rp "Enter Your install service version choice(0 ...):" select
      [ -z "${nginx_download_urls[$select]}" ] && echo -e "${red}暂不支持的版本号${plain}" && exit 0

    download_select=''
    if_select=''
    $controls install -y wget curl net-tools
    if mycmd;then
      echo -e "${red}安装失败${plain}" && exit 0
    fi
    server_name=nginx
    download_url=${nginx_download_urls[$select]}
    select_download_version=${temp_number[$select]}
    manage_download
    check_unpack_file_path
echo "开始安装Nginx--链接Github获取Nginx安装脚本"
bash <(curl -sL https://"$url_address"/HiddenScholars/Linux-tools/"$con_branch"/InstallFile/Install_nginx.sh) "${sorted_files[$select]}" "$missing_dirs"
}
function setting_ssl() {
echo "开始安装证书--链接Github获取证书安装脚本"
bash <(curl -sL https://"$url_address"/HiddenScholars/Linux-tools/"$con_branch"/InstallFile/Install_ssl_acme.sh)
}
function install_docker() {
  echo "开始安装Docker--链接github获取Docker安装脚本"
  bash <(curl -sL https://"$url_address"/HiddenScholars/Linux-tools/"$con_branch"/InstallFile/Install_docker.sh) "$filename"
}
function install_docker_compose() {
regex="v([0-9]+\.[0-9]+\.[0-9]+)"
docker_compose_download_urls_select=0
temp_number=()
url=''
for url in "${docker_compose_download_urls[@]}"
do
    if [[ $url =~ $regex ]]; then
        version="${BASH_REMATCH[1]}"
        echo -e "${green}$docker_compose_download_urls_select：$version${plain}"
        temp_number+=("$version")
    fi
let docker_compose_download_urls_select=$docker_compose_download_urls_select+1
done
select=''
      read -rp "Enter Your install service version choice（0）:" select
      [ -z "${docker_compose_download_urls[$select]}" ] && echo -e "${red}暂不支持的版本号${plain}" && exit 0
bash <(curl -sL https://"$url_address"/HiddenScholars/Linux-tools/"$con_branch"/InstallFile/Install_docker-compose.sh) "${temp_number[$select]}" "${select}"
}

function upgrade_smooth_nginx() {
    regex="nginx-([0-9]+\.[0-9]+\.[0-9]+)"
    nginx_download_urls_select=0
    temp_number=()
    url=''
    for url in "${nginx_download_urls[@]}"
    do
        if [[ $url =~ $regex ]]; then
            version="${BASH_REMATCH[1]}"
            echo -e "${green}$nginx_download_urls_select：$version${plain}"
            temp_number+=("$version")
        fi
    let nginx_download_urls_select=$nginx_download_urls_select+1
    done
    select=''
          read -rp "Enter Your install service version choice(0 ...):" select
          [ -z "${nginx_download_urls[$select]}" ] && echo -e "${red}序号输入错误${plain}" && exit 0

        download_select=''
        if_select=''
        $controls install -y wget curl net-tools
        if mycmd;then
          echo -e "${red}安装失败${plain}" && exit 0
        fi
        server_name=nginx
        download_url=${nginx_download_urls[$select]}
        select_download_version=${temp_number[$select]}
        manage_download
        check_unpack_file_path
    bash <(curl -sL https://"$url_address"/HiddenScholars/Linux-tools/"$con_branch"/Upgrade/Upgrade_smooth_nginx.sh) "${sorted_files[$select]}" "$missing_dirs"
}

function uninstall_nginx() {
    bash <(curl -sL https://"$url_address"/HiddenScholars/Linux-tools/"$con_branch"/UninstallFile/Uninstall_nginx.sh)
}
function uninstall_docker() {
    bash <(curl -sL https://"$url_address"/HiddenScholars/Linux-tools/"$con_branch"/UninstallFile/Uninstall_docker.sh)
}
function uninstall_tool() {
    bash <(curl -sL https://"$url_address"/HiddenScholars/Linux-tools/"$con_branch"/Link_localhost/uninstall.sh)

}

#菜单目录显示控制
show_use=("退出脚本" "安装" "卸载" "升级" "acme脚本(搭配cloudflare)" "检查更新")
show_use_function=("exit 1" "show_Soft" "soft_Uninstall" "soft_Upgrade" "setting_ssl" "check_update")
show_soft=("返回主页面" "nginx" "docker" "docker-compose")
show_soft_function=("return" "install_nginx" "install_docker" "install_docker_compose")
soft_uninstall=("返回主页面" "Nginx卸载" "Docker卸载" "tool命令卸载")
soft_uninstall_function=("return" "uninstall_nginx" "uninstall_docker" "uninstall_tool")
soft_upgrade=("返回主菜单" "Nginx平滑升(降)级")
soft_upgrade_function=("return" "upgrade_smooth_nginx")



#该参数请勿修改
temp_return_select=0
function show_Use() {
[ $temp_return_select -ne 0 ] && read -rp "回车返回主菜单"
let temp_return_select++
select=''
clear
echo -e "${green}   _|                          _|${plain}"
echo -e "${green}_|_|_|_|    _|_|      _|_|     _|    _|_|_|${plain}"
echo -e "${green}   _|      _|    _|  _|    _|  _|  _|_|${plain}"
echo -e "${green}   _|      _|    _|  _|    _|  _|      _|_|${plain}"
echo -e "${green}     _|_|    _|_|      _|_|    _|  _|_|_|${plain}"
curl -s https://"$url_address"/HiddenScholars/Linux-tools/"$con_branch"/version
    select=''
    printf "****************************************************************************\n"
                            printf "\t\t**欢迎使用Linux-tools脚本菜单**\n"
    printf "****************************************************************************\n"
                            for i in "${!show_use[@]}"
                            do
                            printf "\t\t${green}%s. ${plain}${show_use[$i]}.\n" "${i}"
                            done
    printf "****************************************************************************\n"
    read -rp "输入序号【0-"$((${#show_use[@]}-1))"】：" select
    if [ -n "$select" ] ;then
        if [[ "$select" =~ ^[0-9]+$ ]] && [ -n "${show_use_function[$select]}" ]  ; then
            eval  "${show_use_function[$select]}"
        else
           echo "不存在的功能"
        fi
    else
       echo "输入序号才能执行"
    fi
}
function show_Soft() {
    select=''
    clear
    printf "****************************************************************************\n"
                        printf "\t\t**欢迎使用Linux-tools软件安装脚本菜单**\n"
    printf "****************************************************************************\n"
                            for i in "${!show_soft[@]}"
                            do
                            printf "\t\t${green}%s. ${plain}${show_soft[$i]}.\n" "${i}"
                            done
    printf "****************************************************************************\n"
    read -rp   "输入序号【0-"$((${#show_soft[@]}-1))"】：" select
    if [ -n "$select" ] ;then
            if [[ "$select" =~ ^[0-9]+$ ]] && [ -n "${show_soft_function[$select]}" ]  ; then
                eval  "${show_soft_function[$select]}"
            else
               echo "不存在的功能"
            fi
    else
           echo "输入序号才能执行"
    fi

}
function soft_Uninstall() {
      select=''
      clear
      printf "****************************************************************************\n"
                              printf "\t\t**欢迎使用Linux-tools脚本菜单**\n"
      printf "****************************************************************************\n"
                            for i in "${!soft_uninstall[@]}"
                            do
                            printf "\t\t${green}%s. ${plain}${soft_uninstall[$i]}.\n" "${i}"
                            done
      printf "****************************************************************************\n"
      read -rp "输入序号【0-"$((${#soft_uninstall[@]}-1))"】：" select
      if [ -n "$select" ] ;then
            if [[ "$select" =~ ^[0-9]+$ ]] && [ -n "${soft_uninstall_function[$select]}" ]  ; then
                eval  "${soft_uninstall_function[$select]}"
            else
               echo "不存在的功能"
            fi
      else
           echo "输入序号才能执行"
      fi

}
function soft_Upgrade() {
    select=''
    clear
    printf "****************************************************************************\n"
                                printf "\t\t**欢迎使用Linux-tools脚本菜单**\n"
        printf "****************************************************************************\n"
                            for i in "${!soft_upgrade[@]}"
                            do
                            printf "\t\t${green}%s. ${plain}${soft_upgrade[$i]}.\n" "${i}"
                            done
        printf "****************************************************************************\n"
        read -rp "输入序号【0-"$((${#soft_upgrade[@]}-1))"】：" select
    if [ -n "$select" ] ;then
            if [[ "$select" =~ ^[0-9]+$ ]] && [ -n "${soft_upgrade_function[$select]}" ]  ; then
                eval  "${soft_upgrade_function[$select]}"
            else
               echo "不存在的功能"
            fi
    else
           echo "输入序号才能执行"
    fi
}

while  true ; do
    show_Use
done