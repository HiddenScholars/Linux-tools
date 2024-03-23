# Linux-tools

> 介绍： 通过在linux界面输入序号选择对服务的安装，卸载和升级

配置变量由config文件获取，要修改变量提前下载config配置文件修改后再执行脚本
注：config存储位置都放在/tools/目录下，目前不支持自定义存储路径，使用时请勿移动文件！！！

> 目前项目分为 main 和 TestMain 两个项目分支 可通过调整con_branch参数进行选择

> 根据country选择国家，加快config中链接的访问速度

如遇中国境内网络环境无法访问到Github，手动替换url_address地址
例如：
```shell
export con_branch=main export url_address=raw.yzuu.cf export country=CN && bash <(curl -L https://${url_address}/HiddenScholars/Linux-tools/${con_branch}/tools.sh)
``` 

通用运行脚本
```shell
export con_branch=main export url_address=raw.githubusercontent.com export country=CN && bash <(curl -L https://${url_address}/HiddenScholars/Linux-tools/${con_branch}/tools.sh)
```

config下载
```shell
export con_branch=main export url_address=raw.githubusercontent.com  export country=CN && bash <(curl -L https://${url_address}/HiddenScholars/Linux-tools/${con_branch}/tools.sh) -d config
```

config配置信息
```text
download_path=/tools/soft/
install_path=/usr/local/soft/
country=
url_address=raw.githubusercontent.com
con_branch=main
nginx_user=nginx
mysql5_user=mysql
mysql5_initial_port=3306
nginx_download_urls=(
https://nginx.org/download/nginx-1.24.0.tar.gz
https://nginx.org/download/nginx-1.22.1.tar.gz
)
docker_download_urls=(https://mirrors.tuna.tsinghua.edu.cn/docker-ce/linux/static/stable/`uname -m`/docker-17.03.0-ce.tgz)
docker_compose_download_urls=(https://github.com/docker/compose/releases/download/v2.23.3/docker-compose-`uname -s`-`uname -m`)
jdk_download_urls=(https://repo.huaweicloud.com/java/jdk/8u152-b16/jdk-8u152-linux-x64.tar.gz)
mysql5_download_urls=(
https://downloads.mysql.com/archives/get/p/23/file/mysql-5.7.44-linux-glibc2.12-`uname -m`.tar.gz
https://downloads.mysql.com/archives/get/p/23/file/mysql-5.7.43-linux-glibc2.12-`uname -m`.tar.gz)
```