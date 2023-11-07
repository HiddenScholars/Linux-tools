# tools

安装脚本集合

```shell
bash <(curl -Ls https://raw.githubusercontent.com/LGF-LGF/tools/main/tools.sh)
```





## 脚本扩展时可调用变量函数
| 变量                                                         | 默认值                                         | 作用                                                         | 备注           |
| ------------------------------------------------------------ | ---------------------------------------------- | ------------------------------------------------------------ | -------------- |
| controls                                                     | apt                                            | 使用什么安装包管理器                                         | （待优化）     |
| release                                                      | 空                                             | 系统版本                                                     |                |
| download_path                                                | /tools/soft/                                   | 安装包下载统一路径                                           |                |
| install_path                                                 | /usr/local/soft/                               | 安装路径                                                     |                |
| time                                                         | date +%Y%m%d                                   | 当前时间，准确到日期                                         |                |
| nginx_download_url                                           | https://nginx.org/download/nginx-1.24.0.tar.gz | nginx安装包下载路径                                          |                |
| nginx_user                                                   | nginx                                          | nginx目录所属权，该账户为程序用户不可登陆                    | 不填写则不创建 |
| red='\033[31m'<br/>green='\033[32m'<br/>yellow='\033[33m'<br/>plain='\033[0m' |                                                | 输出时颜色调用，red：红色，green：绿色，yellow：黄色，plain：白色 |                |



| 函数                 | 调用参数                                                     | 作用                                     | 备注 |
| -------------------- | ------------------------------------------------------------ | ---------------------------------------- | ---- |
| check_install_system | 使用前需要设置参数：<br/>#process=() 检查此数组中的进程 <br/> #test_server_port=() 检查此数组中的端口<br/>使用哪个就在哪个数组中放入数据后调用check_install_system | 检测要安装服务器的端口和进程是否已经存在 |      |
| show_Use             | 主菜单                                                       | 菜单                                     |      |
| show_soft            | 软件安装菜单                                                 | 菜单                                     |      |
| install_nginx        | Nginx安装                                                    | 安装Nginx中间件                          |      |
|                      |                                                              |                                          |      |



