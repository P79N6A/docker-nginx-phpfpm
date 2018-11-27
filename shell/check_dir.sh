#!/usr/bin/env bash
year=`date "+%Y"`
month=`date "+%m"`
day=`date "+%d"`
ago_day=$((`date "+%d"`+1))
#echo "${year} ${month} ${day} ${ago_day}"
LOG_PATH="/var/log/nginx/${year}${month}${day}"
[ ! -d "$LOG_PATH" ] && mkdir -p ${LOG_PATH}

if [ 2 -eq `echo ${#ago_day}` ]; then
    LOG_PATH2="/var/log/nginx/${year}${month}${ago_day}"
else
    LOG_PATH2="/var/log/nginx/${year}${month}0${ago_day}"
fi

[ ! -d "$LOG_PATH2" ] && mkdir -p ${LOG_PATH2}

# 切割error filebeat是增量发送，这个脚本没必要了
# NGINX_LOG=/var/log/nginx/error.log
# mv ${NGINX_LOG} "${LOG_PATH}/error.log"
# echo "" > ${NGINX_LOG}
