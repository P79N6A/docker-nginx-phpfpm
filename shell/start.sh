#!/bin/bash
# 自动下载sina_include包
[ ! -d /var/www/sina_include ] && bash /shell/deploy.sh master sina_include git@code.ucse.net:xuemao_php/sina_include.git

# 自动下载framework包
[ ! -d /var/www/ucse_admin_framework ] && bash /shell/deploy.sh develop ucse_admin_framework git@code.ucse.net:xuemao_php/ucse_admin_framework.git

# 自动下载framework包
[ ! -d /var/www/ucse_framework ] && bash /shell/deploy.sh develop ucse_framework git@code.ucse.net:xuemao_php/ucse_framework.git

# 软链
bash /shell/link.sh
# 执行一遍脚本
bash /shell/check_dir.sh
# 启动redis 后台模式
redis-server /etc/redis.conf --daemonize yes
# 启动nginx
nginx
# root 启动php-fpm
php-fpm5 -R
echo "0 3 * * * /bin/bash /shell/check_dir.sh" > /var/spool/cron/crontabs/root
#启动定时任务
crond
# 日志同步
filebeat -c /etc/filebeat/filebeat.yml
tail -f /dev/null