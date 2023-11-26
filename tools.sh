#!/bin/bash

nginx_download_url=
docker_download_url=
config_path=/tools/
config_file=/tools/config.sh
#tools start check ...
[ `whoami` != root ] && echo -e "${red}需要使用root权限${plain}" && exit 1

#config.sh check
#======================================================================
  if [ ! -f ${config_file} ];then
    [ ! -d ${config_path} ] && mkdir ${config_path}
    echo -e "${red}config文件不存在，开始下载...${plain}"
    wget -P ${config_path} https://raw.githubusercontent.com/LGF-LGF/tools/main/config.sh
    [ ! -f ${config_file} ] && echo -e "${red}下载失败，config文件不存在，检查后再次执行脚本!!!${plain}" && exit 0
  fi
source $config_file
#=====================================================================

function manage_download() {
  #server_name下载服务名
  #download_url下载链接
  [ -z $server_name ] && echo -e "$red 禁止server_name为空使用 $plain" && exit
  [ -z $download_url ] && echo -e "$red 禁止download_url为使用 $plain" && exit
  [ ! -d $download_path/$server_name ] &&  mkdir -p $download_path/$server_name
          if [ `ls $download_path/$server_name/ | wc -l` -ne 0 ];then
                echo -e "${red}$download_path/$server_name/中存在文件${plain}"
                echo
                echo
               cd $download_path/$server_name/
                    # 定义一个空数组用于存储符合条件的文件
                    files=()

                    # 获取目录下所有文件，并将符合条件的文件添加到数组中
                    for file in *; do
                      # 过滤文件的条件，可以根据需求进行修改
                      if [[ ! "$file" =~ ^\..* ]]; then
                        files+=("$file")
                      fi
                    done

                    # 对数组进行排序，并打印文件名和数字序号
                    IFS=$'\n' sorted_files=($(sort <<<"${files[*]}"))
                    for i in ${!sorted_files[@]}; do
                      echo -e "${green}$((i)):${sorted_files[$i]}${plain}"
                    done
                echo
                echo
                read -p  "文件夹中存在文件是否继续下载（y/n）(default：n)：" download_select

                if [ "$download_select" == "y" ]; then
                      wget -P $download_path/$server_name/ $download_url
                      cd $download_path/$server_name/
                      # 定义一个空数组用于存储符合条件的文件
                      files=()

                      # 获取目录下所有文件，并将符合条件的文件添加到数组中
                      for file in *; do
                        # 过滤文件的条件，可以根据您的需求进行修改
                        if [[ ! "$file" =~ ^\..* ]]; then
                          files+=("$file")
                        fi
                      done

                      # 对数组进行排序，并打印文件名和数字序号
                      IFS=$'\n' sorted_files=($(sort <<<"${files[*]}"))
                      for i in ${!sorted_files[@]}; do
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
                  # 过滤文件的条件，可以根据您的需求进行修改
                  if [[ ! "$file" =~ ^\..* ]]; then
                    files+=("$file")
                  fi
                done

                # 对数组进行排序，并打印文件名和数字序号
                IFS=$'\n' sorted_files=($(sort <<<"${files[*]}"))
                for i in ${!sorted_files[@]}; do
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
            for pro in ${process[@]}
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
} #check_install_nginx_system
function install_nginx() {
     process=(nginx)
     test_server_port=(80 443)
     check_install_system
    case $select in
          1)
          nginx_download_url=$nginx_download_url_1
          ;;
          *)
            echo "暂无此版本，敬请期待."
            exit 0
            ;;
    esac
    download_select=''
    if_select=''
    $controls install -y wget curl net-tools
    if [ $? -ne 0 ];then
      echo -e "${red}安装失败${plain}" && exit 0
    fi
server_name=nginx
download_url=$nginx_download_url
manage_download
echo "开始安装Nginx--链接Github获取Nginx安装脚本"
bash <(curl -L https://raw.githubusercontent.com/LGF-LGF/tools/main/InstallFile/Install_nginx.sh) ${sorted_files[$select]}
read -p "按回车键返回主菜单："
} #install_nginx
function setting_ssl() {
echo "开始安装证书--链接Github获取证书安装脚本"
bash <(curl -L https://raw.githubusercontent.com/LGF-LGF/tools/main/InstallFile/Install_ssl_acme.sh)
read -p "按回车键返回主菜单："
}
function install_docker() {
  process=(docker)
  check_install_system
  case $select in
        1)
        docker_download_url=$docker_download_url_1
        ;;
        *)
          echo "暂无此版本，敬请期待."
          exit 0
        ;;
  esac
        #manager_download_END
        server_name=docker
        download_url=$docker_download_url
        manage_download
        #manager_download_END
        filename=$(basename $docker_download_url)
  echo "开始安装Docker--链接github获取Docker安装脚本"
  bash <(curl -L https://raw.githubusercontent.com/LGF-LGF/tools/main/InstallFile/Install_docker.sh) $filename
  read -p "按回车键返回主菜单："
}

function uninstall_nginx() {
    echo "开始卸载Nginx--链接github获取Nginx卸载脚本"
    bash <(curl -L https://raw.githubusercontent.com/LGF-LGF/tools/main/UninstallFile/Uninstall_nginx.sh)
    read -p "按回车键返回主菜单："
}
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
                            printf "\t\t**欢迎使用tools脚本菜单**\n"
    printf "****************************************************************************\n"
                            printf "\t\t${green}0. ${plain}退出脚本.\n"
                            printf "\t\t${green}1. ${plain}服务安装.\n"
                            printf "\t\t${green}2. ${plain}服务卸载.\n"
                            printf "\t\t${green}3. ${plain}acme脚本(搭配cloudflare).\n"
    printf "****************************************************************************\n"
    read -p "输入序号【0-3】：" select
    case $select in
    0)
    exit 1
      ;;
    1)
    show_soft
      ;;
    2)
    soft_uninstall
      ;;
    3)
    setting_ssl
      ;;
    *)
      echo "输入错误"
      exit 1
      ;;
    esac
}
function show_soft() {
#安装软件进程和端口检查，调用函数check_install_system,调用前设置
#    #process=() 检查此数组中的进程
#    #test_server_port=() 检查此数组中的端口
    process=()
    test_server_port=()
    select=''
    if [ $? -eq 0 ];then
      echo -e "${green}变量初始化完成${plain}"
    fi
    clear
    printf "****************************************************************************\n"
                        printf "\t\t**欢迎使用tools软件安装脚本菜单**\n"
    printf "****************************************************************************\n"
                        printf "\t\t${green}0. ${plain}返回主页面.\n"
                        printf "\t\t${green}1. ${plain}Nginx.\n"
                        printf "\t\t${green}2. ${plain}Docker.\n"
    printf "****************************************************************************\n"
    read -p   "输入序号【0-2】：" select
    case $select in
    0)
     return
      ;;
    1)
      printf "\t\t${green}1. ${plain}Nginx${nginx_download_url_1##*/nginx-}\n"
      read -p "Enther Your install service version choice（1）:" select
      install_nginx
      ;;
    2)
      echo
      printf "\t\t${green}1. ${plain}Docker${docker_download_url_1##*/docker-}\n"
      read -p "Enther Your install service version choice（1）:" select
      install_docker
      ;;
    *)
      echo "输入序号不存在"
      ;;
    esac
} #show_soft
function soft_uninstall() {
      clear
      select=''
      printf "****************************************************************************\n"
                              printf "\t\t**欢迎使用tools脚本菜单**\n"
      printf "****************************************************************************\n"
                              printf "\t\t${green}0. ${plain}返回主页面.\n"
                              printf "\t\t${green}1. ${plain}Nginx卸载.\n"
      printf "****************************************************************************\n"
      read -p "输入序号【0-1】：" select
      case $selet in
      0)
        return
        ;;
      1)
        uninstall_nginx
        ;;
      *)
        echo "序号输入错误"
        ;;
      esac
}



case $1 in
-d)
  case $2 in
  config.sh)
          wget -P ${config_path} https://raw.githubusercontent.com/LGF-LGF/tools/main/config.sh
          [ ! -f ${config_file} ] && echo -e "${red}下载失败，config文件不存在，检查后再次执行脚本!!!${plain}" && exit 0
          ;;
  *)
  echo -e "${red}参数错误${plain}"
    ;;
  esac
;;
*)
  while [ true ]; do
  show_Use
  done
  ;;
esac