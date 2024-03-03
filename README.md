# Linux-tools

> 介绍： 通过在linux界面输入序号选择对服务的安装，卸载和升级

配置变量由config.sh文件获取，要修改变量提前下载config.sh配置文件修改后再执行脚本
注：config.sh存储位置都放在/tools/目录下，目前不支持自定义存储路径，使用时请勿移动文件！！！

> 目前项目分为 main 和 TestMain 两个项目分支 可通过调整con_branch参数进行选择

如遇中国境内网络环境无法访问到Github，手动替换url_address地址
例如：
```shell
con_branch=main url_address=raw.yzuu.cf bash <(curl -Ls https://${url_address}/HiddenScholars/Linux-tools/${con_branch}/tools.sh)
``` 

通用运行脚本
```shell
 con_branch=main url_address=raw.githubusercontent.com bash <(curl -Ls https://${url_address}/HiddenScholars/Linux-tools/${con_branch}/tools.sh)
```

config.sh下载
```shell
 con_branch=main url_address=raw.githubusercontent.com bash <(curl -Ls https://${url_address}/HiddenScholars/Linux-tools/${con_branch}/tools.sh) -d config.sh
```

