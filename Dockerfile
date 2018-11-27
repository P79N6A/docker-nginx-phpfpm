# ucse php_test
FROM alpine:edge
LABEL author=duanxuqiang@ucse.net

# base 镜像
ENV TIMEZONE Asia/Shanghai
# 一些工作目录准备
RUN mkdir -p /var/log/nginx && \
    mkdir -p /var/tmp/client_body_temp && \
    mkdir -p /var/www/html && \
    mkdir -p /var/lib/nginx && \
    mkdir -p /ucse/web && \
    # 修改镜像源为国内ustc.edu.cn(中科大)／aliyun.com(阿里云)／tuna.tsinghua.edu.cn（清华）
    # 近期阿里云不稳定，更换镜像为清华
    # main官方仓库，community社区仓库
    echo http://mirrors.aliyun.com/alpine/edge/main > /etc/apk/repositories && \
    echo http://mirrors.aliyun.com/alpine/edge/community >> /etc/apk/repositories && \
    # 更新系统和修改时区以及一些扩展apk update && apk upgrade -a &&  busybox-extras libc6-compat
    apk update && apk upgrade -a && apk add --no-cache tzdata curl wget bash git vim openssh && \
    # 配置ll alias 命令
    echo "alias ll='ls -l --color=tty'" >> /etc/profile && \
    echo "source /etc/profile " >> ~/.bashrc && \
    # -X获取指定仓库的包
    apk add --no-cache -X http://mirrors.aliyun.com/alpine/edge/community neofetch && \
    cp /usr/share/zoneinfo/${TIMEZONE} /etc/localtime && \
    echo "${TIMEZONE}" > /etc/timezone && \
    # 创建www用户组 alpine中 -D:不创建密码
    #adduser -D www www && \
    #chown -R www:www /ucse && \
    #chown -R www:www /var/log && \
    #chown -R www:www /var/www/html && \
    #chown -R www:www /var/lib/nginx && \
    #chown -R www:www /var/tmp/client_body_temp && \
    chmod -R 777 /var/tmp/client_body_temp

# nginx 镜像
RUN apk add --no-cache nginx-mod-http-echo

# redis 镜像
RUN apk add --no-cache redis && \
    # 去掉安全模式
    sed -i "s|protected-mode yes|protected-mode no|" /etc/redis.conf && \
    # 支持远端连接
    sed -i "s|bind 127.0.0.1|# bind 127.0.0.1|" /etc/redis.conf

# PHP5 镜像
# 运行amqp需要rabbitmq-c库
RUN apk add --no-cache rabbitmq-c php5-fpm php5-common php5-pdo php5-pdo_mysql php5-mysqli php5-curl php5-gd php5-mcrypt php5-openssl php5-json php5-pear php5-phar php5-ctype php5-zip php5-zlib php5-iconv
# composer 中国镜像
RUN ln -s /usr/bin/php5 /usr/bin/php && \
    php -r "copy('https://install.phpcomposer.com/installer', 'composer-setup.php');" && \
    php composer-setup.php && \
    php -r "unlink('composer-setup.php');" && \
    mv composer.phar /usr/local/bin/composer && \
    # 设置中国镜像源
    composer config -g repo.packagist composer https://packagist.phpcomposer.com
#安装ffmpeg
RUN apk add yasm ffmpeg && \
    mkdir -p /usr/local/ffmpeg/bin && \
    ln -s /usr/bin/ffmpeg /usr/local/ffmpeg/bin
#日志输出
RUN apk add --no-cache -X http://mirrors.aliyun.com/alpine/edge/testing filebeat
#开放端口
EXPOSE 9000 6379 80 443 8181
#外部配置
COPY nginx_config /etc/nginx/
COPY php_config/conf /etc/php5/
COPY php_config/modules /usr/lib/php5/modules/
COPY web_code /ucse/web/
COPY shell /shell
RUN cd /shell && chmod -R 777 /shell
COPY filebeat_config /etc/filebeat/

# 健康检查 --interval检查的间隔 超时timeout retries失败次数
HEALTHCHECK --interval=30s --timeout=3s --retries=3 \
    CMD curl --fail http://localhost || exit 1
# 启动
CMD ["/shell/start.sh"]
