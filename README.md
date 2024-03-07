# Linux-tools

> 介绍： 通过在linux界面输入序号选择对服务的安装，卸载和升级

配置变量由config文件获取，要修改变量提前下载config配置文件修改后再执行脚本
注：config存储位置都放在/tools/目录下，目前不支持自定义存储路径，使用时请勿移动文件！！！

> 目前项目分为 main 和 TestMain 两个项目分支 可通过调整con_branch参数进行选择

如遇中国境内网络环境无法访问到Github，手动替换url_address地址
例如：
```shell
export con_branch=main export url_address=raw.yzuu.cf && bash <(curl -Ls https://${url_address}/HiddenScholars/Linux-tools/${con_branch}/tools.sh)
``` 

通用运行脚本
```shell
export con_branch=main export url_address=raw.githubusercontent.com && bash <(curl -Ls https://${url_address}/HiddenScholars/Linux-tools/${con_branch}/tools.sh)
```

config下载
```shell
export con_branch=main export url_address=raw.githubusercontent.com && bash <(curl -Ls https://${url_address}/HiddenScholars/Linux-tools/${con_branch}/tools.sh) -d config
```

config配置信息
```text
#统一配置变量，不清楚原理保持默认
#安装包下载路径，例如下载nginx，nginx安装包路径：$download_path/nginx/
download_path=/tools/soft
#注：这里为所有安装软件的统一路径，任何软件都会以软件名在这个路径下创建路径安装，路径重复根据软件情况通过date +%Y%m%d进行备份
install_path=/usr/local/soft

time=$(date +%Y%m%d)
#国内github无法访问时替换该参数，例如：raw.yzuu.cf，等镜像站
url_address=raw.githubusercontent.com
#项目分支
con_branch=main
#服务安装配置
nginx_download_urls=(
"https://nginx.org/download/nginx-1.24.0.tar.gz"
"https://nginx.org/download/nginx-1.22.1.tar.gz")
nginx_user=nginx
docker_compose_download_urls=(
"https://github.com/docker/compose/releases/download/v2.23.3/docker-compose-linux-x86_64")
#输出颜色
red='\033[31m'
green='\033[32m'
yellow='\033[33m'
plain='\033[0m'
```