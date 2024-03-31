# Linux-tools

感谢您选择使用我们的开源项目！在开始之前，请务必仔细阅读以下使用须知：

该开源项目提供的脚本仅供个人学习、研究和在自身可以负责的测试环境中使用。

请不要将该项目用于公司内部或生产环境，因为我们无法对其在商业环境下的稳定性和安全性提供保证。

在使用该开源项目时，建议您在了解项目功能和代码结构的基础上进行适当的定制和调整，以符合您的实际需求。

如果在使用过程中出现任何问题或损失，使用者需自行承担责任，开发团队不承担任何形式的责任和义务。

我们欢迎您向我们反馈使用过程中的问题、建议和改进建议，帮助我们不断完善和优化这个开源项目。

Thank you for choosing to use our open-source project! Before you get started, please read the following instructions carefully:

The scripts provided by this open-source project are intended for personal learning, research, and use in testing environments where you can take responsibility.

Please refrain from using this project in a corporate or production environment, as we cannot guarantee its stability and security in a commercial setting.

When using this open-source project, we recommend customizing and adjusting it based on your actual needs after understanding its features and code structure.

If any issues or losses occur during use, the user is responsible for them, and the development team assumes no liability or obligation in any form.

We welcome your feedback on any issues, suggestions, or improvement ideas during your use of the project to help us continuously enhance and optimize this open-source project.

Thank you for your cooperation and understanding!

配置变量由config文件获取，要修改变量提前下载config配置文件修改后再执行脚本
注：config存储位置都放在/tools/目录下，不支持自定义存储路径，使用时请勿移动文件！！！

> 目前项目分为 main 和 TestMain 两个项目分支，main为主分支 可通过调整con_branch参数进行选择
> 根据country选择国家，加快config中链接的访问速度


中国大陆执行脚本
```shell
export con_branch=main export url_address=raw.yzuu.cf export country=CN && bash <(curl -L https://${url_address}/HiddenScholars/Linux-tools/${con_branch}/tools.sh)
``` 

通用运行脚本
```shell
export con_branch=main export url_address=raw.githubusercontent.com export && bash <(curl -L https://${url_address}/HiddenScholars/Linux-tools/${con_branch}/tools.sh)
```

config下载
```shell
export con_branch=main export url_address=raw.githubusercontent.com  export  && bash <(curl -L https://${url_address}/HiddenScholars/Linux-tools/${con_branch}/tools.sh) -d config
```
config 修改注释
```text
download_path= #下载路径
install_path= #安装路径  如：$install_path/soft/serverName
country=  #国家代码 如：CN 选择config配置文件，使用较快的下载链接
url_address= # github仓库raw访问链接
con_branch= # github仓库 项目分支
Max_disk_usage= # $download_path 和 /tools//unpack_file/占用最磁盘空间 kb
nginx_user= #nginx 用户
mysql5_user= # mysql5 用户
mysql5_initial_port=  #mysql5数据库端口
nginx_download_urls=() # nginx下载链接
docker_download_urls=() #docker下载链接
docker_compose_download_urls=() #docker-compose 下载链接
jdk_download_urls=() #jdk下载链接
mysql5_download_urls=() #mysql5下载链接
```