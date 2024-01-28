#!/bin/bash
nginx_download_url=
docker_download_url=
select_download_version=
config_path=/tools/
config_file=/tools/config.sh
source $config_file
con_branch_menu=$1

function manage_download() {
  #server_name下载服务名
  #download_url下载链接
  #select_download_version下载版本搜索
  [ -z $server_name ] && echo -e "$red 禁止server_name为空使用 $plain" && exit
  [ -z $download_url ] && echo -e "$red 禁止download_url为使用 $plain" && exit
  [ ! -d $download_path/$server_name ] &&  mkdir -p $download_path/$server_name
          if [ `ls $download_path/$server_name/ | grep $select_download_version | wc -l` -ne 0 ];then
                echo -e "${red}$download_path/$server_name/中存在该版本安装包${plain}"
                echo
               cd $download_path/$server_name/
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
                read -p  "文件夹中存在文件是否继续下载(y/n)(default:n):" download_select

                if [ "$download_select" == "y" ]; then
                      wget -P $download_path/$server_name/ $download_url
                      cd $download_path/$server_name/
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
                wget -P $download_path/$server_name/ $download_url
                cd $download_path/$server_name/
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

              read -p "选择安装包序号：" select
              if [ -z $select ]; then
                  echo -e "${red}未选择安装包，退出脚本${plain}"
                  exit 0
              fi
}
function check_install_system() {
    [ -z $test_server_port ] && [ -z $process ] && echo -e "$red test_server_port与process禁止为空使用 $plain" && exit
    #test_server_port=() 检查此数组中的端口
    netstat -ntpl|grep LISTEN|awk '{print $4}' >/opt/test_sys.txt
    #process=(nginx) 检查此数组中的进程
        num=0
        for line in `cat /opt/test_sys.txt`
        do
            sys_port=${line##*:}
            for i in ${test_server_port[*]}
            do
                if [ $sys_port -eq $i ];then
                    echo -e "\033[31m $sys_port端口已存在，占用服务端口 \033[0m"
                    let  num=$num+1
                fi
            done
        done
        u=0
        if [ $num -eq 0 ]
        then
            for pro in "${process[@]}"
            do
                if [ `ps -ef|grep $pro |grep -v "grep"|wc -l` -ne 0 ]
                then
                    echo "$pro有残余进程，删除后再次执行脚本检测安装环境"
    				countinue=''
                      read -p "是否继续安装，继续安装可能会无法启动（y/n）:" countinue
                        if [ "$countinue" != "y" ]; then
                        exit 1
                        fi
    				return
                    let  u=$u+1
                fi
            done
        else
          countinue=''
          read -p "是否继续安装，继续安装可能会无法启动（y/n）:" countinue
            if [ "$countinue" != "y" ]; then
            exit 1
            fi
        fi
}
function check_unpack_file_path() {
    [ ! -d $config_path/unpack_file ] && mkdir -p $config_path/unpack_file
    if [ `ls -l $config_path/unpack_file/ | wc -l` -gt  11 ];then
      cd $config_path/ && tar cvf unpack_file_bak$(date +%F-%M).tar.gz unpack_file/*
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
        temp_number+=($version)
    fi
let nginx_download_urls_select=$nginx_download_urls_select+1
done
select=''
      read -p "Enther Your install service version choice(0 ...):" select
      [ -z ${nginx_download_urls[$select]} ] && echo -e "${red}暂不支持的版本号${plain}" && exit 0

    download_select=''
    if_select=''
    $controls install -y wget curl net-tools
    if [ $? -ne 0 ];then
      echo -e "${red}安装失败${plain}" && exit 0
    fi
    server_name=nginx
    download_url=${nginx_download_urls[$select]}
    select_download_version=${temp_number[$select]}
    manage_download
    check_unpack_file_path
echo "开始安装Nginx--链接Github获取Nginx安装脚本"
bash <(curl -sL https://$url_address/HiddenScholars/Linux-tools/$con_branch_menu/InstallFile/Install_nginx.sh) ${sorted_files[$select]} $missing_dirs
read -p "按回车键返回主菜单："
}
function setting_ssl() {
echo "开始安装证书--链接Github获取证书安装脚本"
bash <(curl -sL https://$url_address/HiddenScholars/Linux-tools/$con_branch_menu/InstallFile/Install_ssl_acme.sh)
read -p "按回车键返回主菜单："
}
function install_docker() {
  echo "开始安装Docker--链接github获取Docker安装脚本"
  bash <(curl -sL https://$url_address/HiddenScholars/Linux-tools/$con_branch_menu/InstallFile/Install_docker.sh) $filename
  read -p "按回车键返回主菜单："
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
        temp_number+=($version)
    fi
let docker_compose_download_urls_select=$docker_compose_download_urls_select+1
done
select=''
      read -p "Enther Your install service version choice（0）:" select
      [ -z ${docker_compose_download_urls[$select]} ] && echo -e "${red}暂不支持的版本号${plain}" && exit 0
bash <(curl -sL https://$url_address/HiddenScholars/Linux-tools/$con_branch_menu/InstallFile/Install_docker-compose.sh) ${temp_number[$select]} ${select}
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
            temp_number+=($version)
        fi
    let nginx_download_urls_select=$nginx_download_urls_select+1
    done
    select=''
          read -p "Enther Your install service version choice(0 ...):" select
          [ -z ${nginx_download_urls[$select]} ] && echo -e "${red}序号输入错误${plain}" && exit 0

        download_select=''
        if_select=''
        $controls install -y wget curl net-tools
        if [ $? -ne 0 ];then
          echo -e "${red}安装失败${plain}" && exit 0
        fi
        server_name=nginx
        download_url=${nginx_download_urls[$select]}
        select_download_version=${temp_number[$select]}
        manage_download
        check_unpack_file_path
    echo "开始升级Nginx--链接Github获取Nginx升级脚本"
    bash <(curl -sL https://$url_address/HiddenScholars/Linux-tools/$con_branch_menu/Upgrade/Upgrade_smooth_nginx.sh) ${sorted_files[$select]} $missing_dirs
    read -p "按回车键返回主菜单："
}

function uninstall_nginx() {
    echo "开始卸载Nginx--链接Github获取Nginx卸载脚本"
    bash <(curl -sL https://$url_address/HiddenScholars/Linux-tools/$con_branch_menu/UninstallFile/Uninstall_nginx.sh)
    read -p "按回车键返回主菜单："
}
function uninstall_docker() {
    echo "开始安装Docker--链接Github获取Docker卸载脚本"
    bash <(curl -sL https://$url_address/HiddenScholars/Linux-tools/$con_branch_menu/UninstallFile/Uninstall_docker.sh)
    read -p "按回车键返回主菜单："
}
function uninstall_tool() {
    echo "卸载tool命令..."
    bash <(curl -sL https://$url_address/HiddenScholars/Linux-tools/$con_branch_menu/Link_localhost/uninstall.sh)
    read -p "按回车键返回主菜单："
}

#菜单目录显示控制
show_use=("退出脚本" "服务安装" "服务卸载" "服务升级" "acme脚本(搭配cloudflare)")
show_use_function=("exit 1" "show_Soft" "soft_Uninstall" "soft_Upgrade" "setting_ssl")
show_soft=("返回主页面" "Nginx" "Docker" "ocker-compose")
show_soft_function=("return" "install_nginx" "install_docker" "install_docker_compose")
soft_uninstall=("返回主页面" "Nginx卸载" "Docker卸载" "tool命令卸载")
soft_uninstall_function=("return" "uninstall_nginx" "uninstall_docker" "uninstall_tool")
soft_upgrade=("返回主菜单" "Nginx平滑升级")
soft_upgrade_function=("return" "upgrade_smooth_nginx")

function show_Use() {
select=''
clear
echo -e "${green}   _|                          _|${plain}"
echo -e "${green}_|_|_|_|    _|_|      _|_|     _|    _|_|_|${plain}"
echo -e "${green}   _|      _|    _|  _|    _|  _|  _|_|${plain}"
echo -e "${green}   _|      _|    _|  _|    _|  _|      _|_|${plain}"
echo -e "${green}     _|_|    _|_|      _|_|    _|  _|_|_|${plain}"
    select=''
    printf "****************************************************************************\n"
                            printf "\t\t**欢迎使用Linux-tools脚本菜单**\n"
    printf "****************************************************************************\n"
                            for i in "${!show_use[@]}"
                            do
                            printf "\t\t${green}${i}. ${plain}${show_use[$i]}.\n"
                            done
    printf "****************************************************************************\n"
    read -p "输入序号【0-"${#show_use[@]}"】：" select
    if [ ! -z ${show_use_function[$select]} ]; then
       eval  "${show_use_function[$select]}"
    else
       echo "序号输入错误"
       read -p "按回车键返回主菜单"
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
                            printf "\t\t${green}${i}. ${plain}${show_soft[$i]}.\n"
                            done
    printf "****************************************************************************\n"
    read -p   "输入序号【0-"${#show_soft[@]}"】：" select
    if [ ! -z ${show_soft_function[$select]} ]; then
       eval  "${show_soft_function[$select]}"
    else
       echo "序号输入错误"
       read -p "按回车键返回主菜单"
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
                            printf "\t\t${green}${i}. ${plain}${soft_uninstall[$i]}.\n"
                            done
      printf "****************************************************************************\n"
      read -p "输入序号【0-"${#soft_uninstall[@]}"】：" select
    if [ ! -z ${soft_uninstall_function[$select]} ]; then
       eval  "${soft_uninstall_function[$select]}"
    else
       echo "序号输入错误"
       read -p "按回车键返回主菜单"
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
                            printf "\t\t${green}${i}. ${plain}${soft_upgrade[$i]}.\n"
                            done
        printf "****************************************************************************\n"
        read -p "输入序号【0-"${#soft_upgrade[@]}"】：" select
    if [ ! -z ${soft_upgrade_function[$select]} ]; then
       eval  "${soft_upgrade_function[$select]}"
    else
       echo "序号输入错误"
       read -p "按回车键返回主菜单"
    fi
}

while [ true ]; do
    show_Use
done