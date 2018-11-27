#!/bin/bash
##@description 生成软链 @author wushaoming@ucse.net @date 2018-04-17
www_path='/var/www';
cd ${www_path}
for dir_path in `ls`;
do
    #软链判断
    if [ -L $dir_path ];then
        continue;
    else
        if [[ ${dir_path} == *'.ucse.net' || ${dir_path} == *'.xuemao.com' ]];then
            OLD_IFS="$IFS"
            IFS='.';
            arr=($dir_path);
            IFS="$OLD_IFS";
            #域名结尾
            end_str='';
            end_str=${arr[${#arr[*]}-1]};
            #删除元素
            unset arr[${#arr[*]}-1];
            unset arr[${#arr[*]}-1];
            #目录前缀
            link_path_pre='';
            #遍历
            for i in ${arr[*]};
            do
                link_path_pre=${link_path_pre}${i}'.';
            done
            #软链目录
            link_path='';
            if [ ${end_str} == 'net' ];then
                link_path=${link_path_pre}'xuemao.com';
            else
                link_path=${link_path_pre}'ucse.net';
            fi
            #生成软链
            #if [ -d ${link_path} ];then
            #    rm -fr ${link_path}
            #fi
            ln -sf ${dir_path}'/' ${link_path};
        else
            continue;
        fi
    fi
done