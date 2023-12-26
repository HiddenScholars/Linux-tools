# tools

介绍：

配置变量由config.sh获取，要修改变量提前下载config.sh配置文件修改后在执行脚本





运行脚本

CentOS/Redhat

```shell
yum -y install wget curl && bash <(curl -Ls https://raw.githubusercontent.com/LGF-LGF/tools/main/tools.sh)
```

Ubuntu/Debian

```
apt -y install wget curl && bash <(curl -Ls https://raw.githubusercontent.com/LGF-LGF/tools/main/tools.sh)
```



config.sh下载

CentOS/Redhat

```shell
yum -y install wget curl && bash <(curl -Ls https://raw.githubusercontent.com/LGF-LGF/tools/main/tools.sh) -d config.sh
```

Ubuntu/Debian

```
apt -y install wget curl && bash <(curl -Ls https://raw.githubusercontent.com/LGF-LGF/tools/main/tools.sh) -d config.sh
```



