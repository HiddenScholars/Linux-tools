select=''
    echo -E ""
       echo "******使用说明******"
       echo "该脚本将使用Acme脚本申请证书,使用时需保证:"
       echo "1.知晓Cloudflare 注册邮箱"
       echo "2.知晓Cloudflare Global API Key"
       echo "3.域名已通过Cloudflare进行解析到当前服务器"
       echo "4.该脚本申请证书默认安装路径为/root/cert目录"
       read -p "我已确认以上内容[y/n] 默认：y：" select
    [ -z $select ] && select=y
       if [ $select == 'y' ]; then
           cd ~
           echo "安装Acme脚本"
           curl https://get.acme.sh | sh
           if [ $? -ne 0 ]; then
               echo "安装acme脚本失败"
               exit 1
           fi
           CF_Domain=""
           CF_GlobalKey=""
           CF_AccountEmail=""
           certPath=""
    	shellcmd=""
    	if [ -z $certPath ];then
    	read -p "请输入证书存储路径(默认：/root/cert)：" certPath
    	fi
    	[ -z $certPath ] && certPath=/root/cert
    	echo "certPath=$certPath"
           if [ ! -d "$certPath" ]; then
               mkdir -p $certPath
           else
               rm -rf $certPath
               mkdir -p $certPath
           fi
           echo "请设置域名:"
           read -p "Input your domain here:" CF_Domain
           echo "你的域名设置为:${CF_Domain}"
           echo "请设置API密钥:"
           read -p "Input your key here:" CF_GlobalKey
           echo "你的API密钥为:${CF_GlobalKey}"
           echo "请设置注册邮箱:"
           read -p "Input your email here:" CF_AccountEmail
           echo "你的注册邮箱为:${CF_AccountEmail}"
           ~/.acme.sh/acme.sh --set-default-ca --server letsencrypt
           if [ $? -ne 0 ]; then
               echo "修改默认CA为Lets'Encrypt失败,脚本退出"
               exit 1
           fi
           export CF_Key="${CF_GlobalKey}"
           export CF_Email=${CF_AccountEmail}
           ~/.acme.sh/acme.sh --issue --dns dns_cf -d ${CF_Domain} -d *.${CF_Domain} --log --force
           if [ $? -ne 0 ]; then
               echo "证书签发失败,脚本退出"
               exit 1
           else
               echo "证书签发成功,安装中..."
           fi
    	read -p "请输入证书签发后执行命令，无执行命令直接回车：" shellcmd
    	if [ -z "$shellcmd" ]; then
           ~/.acme.sh/acme.sh --installcert -d ${CF_Domain} -d *.${CF_Domain} --ca-file $certPath/ca.cer \
           --cert-file $certPath/${CF_Domain}.cer --key-file $certPath/${CF_Domain}.key \
           --fullchain-file $certPath/fullchain.cer
    	else
    	~/.acme.sh/acme.sh --installcert -d ${CF_Domain} -d *.${CF_Domain} --ca-file $certPath/ca.cer \
           --cert-file $certPath/${CF_Domain}.cer --key-file $certPath/${CF_Domain}.key \
           --fullchain-file $certPath/fullchain.cer --reloadcmd "$shellcmd"
    	fi

           if [ `ls -l $certPath` -le 1 ]; then
               echo "证书安装失败,脚本退出"
               exit 1
           else
               echo "证书安装成功,开启自动更新..."
           fi
           ~/.acme.sh/acme.sh --upgrade --auto-upgrade
           if [ $? -ne 0 ]; then
               echo "自动更新设置失败,脚本退出"
               ls -lah $certPath
               chmod 700 $certPath
               exit 1
           else
               echo "证书已安装且已开启自动更新,具体信息如下"
               ls -lah $certPath
               chmod 700 $certPath
           fi
           select_pem=''
           read -p "是否生成pem证书(y/n) default:n：" select_pem
           if [ ! -z $select_pem ];then
           acme.sh --install-cert -d ${CF_Domain} --key-file /privkey.pem --fullchain-file //$certPath/fullchain.pem
           crontab -l | grep ".acme.sh" | awk '{print $1,$2,$3,$4,$5}' | awk "NR==1" acme.sh --install-cert -d ${CF_Domain} --key-file /$certPath/privkey.pem --fullchain-file //$certPath/fullchain.pem >>/var/spool/cron/crontabs/root
           service cron restart
           echo "证书生成完成,具体信息如下："
           ls -lah $certPath
           fi

    else
    exit 0
    fi