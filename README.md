# Linux-tools

介绍：
通过在linux界面输入序号选择对服务的安装，卸载和升级，解决手动安装的烦恼。

配置变量由config.sh获取，要修改变量提前下载config.sh配置文件修改后在执行脚本
注：config.sh存储位置都放在/tools/目录下，目前不支持自定义存储路径，使用时请勿移动文件！！！





运行脚本

CentOS/Redhat

```shell
yum -y install wget curl net-tools && bash <(curl -Ls https://raw.githubusercontent.com/HiddenScholars/Linux-tools/main/tools.sh)
```

Ubuntu/Debian

```
apt -y install wget curl  net-tools && bash <(curl -Ls https://raw.githubusercontent.com/HiddenScholars/Linux-tools/main/tools.sh)
```



config.sh下载

CentOS/Redhat

```shell
yum -y install wget curl  net-tools && bash <(curl -Ls https://raw.githubusercontent.com/HiddenScholars/Linux-tools/main/tools.sh) -d config.sh
```

Ubuntu/Debian

```
apt -y install wget curl  net-tools && bash <(curl -Ls https://raw.githubusercontent.com/HiddenScholars/Linux-tools/main/tools.sh) -d config.sh
```



