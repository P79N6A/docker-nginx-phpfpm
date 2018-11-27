#!/bin/bash
# 使用语法：/bin/bash /shell/deploy.sh 分支名 文件夹名 仓库地址
# 举例：/bin/bash /shell/deploy.sh develop ucse_framework git@code.ucse.net:xuemao_php/ucse_framework.git

#部署日志
LOG_PATH=/var/log/deploy
[ ! -d "$LOG_PATH" ] && mkdir -p ${LOG_PATH}
NOW_DATE=`date "+%Y-%m-%d"`
LOG_NAME=${LOG_PATH}/${NOW_DATE}.log

date "+%Y-%m-%d %H:%M:%S">>${LOG_NAME}
echo "${USER}进入脚本" >> ${LOG_NAME}


#变量设置，后期可以外部扩展
GIT_BRANCH=$1
GIT_REPO_NAME=$2
GIT_REPO=$3
GIT_EMAIL="duanxuqiang@ucse.net"
GIT_NAME="dxq"
RSA="-----BEGIN RSA PRIVATE KEY-----
MIIEogIBAAKCAQEA5Gss0agiZtpFHrb4ePl9VPcbm0LVwQ+PZac0E/tNHL8ZxJ2G
IA+f9d3Ys3B1DbZbq/vbPTYaxxrCrYkaPnrO3Qu/6eF4ogkhCE4gFoubCH184aYM
TTBRj9ucZqdcNRov3RxVsQw3iJAMW1U5jnUuX1Liv/Q1PJNgG+UwgOY/O9jobGFX
fWEIfA+lV/oz2DvngOwjxnbuG2S1LuEp6KdhTSRKEBkAEiizb3GDYaDvZJw6GotH
MJYhP55fnFhIPRRw5WB9ejnMToWmvMsPhz0Wwbdb0QVLDBikpsgogV/lxqyp7PN5
kOevk7aEMtVdhir2J1YfCcJAQAKRE9HLXE5uqwIDAQABAoH/Qga47eGsEA8H69j3
+gAkOmszj63CHAxjZv7uDtiVcbnLuQnPu3TIyElYWoYnT89msFAdD5SUKPmTTJZU
/7qAEWVUFEcYl74LzlrG671vEwUzFAbrh2RwLyVMEGBQRwlKzJ9kJcliRBdfewcn
nAZDYUqUQOhWeywem/GkE556qNF+hzbh9s4+uT+RhIgOhi+j0IhMd4Jqn1zj37Py
nwkqn0hnakinDFuNYCUJYTXWbHebdXVWh3YVPK/sRm01XF5hB2QBgYUWpy9WgTp2
ViXCIDQf3/pc6w372pBBGz1UpqlLPOsqZ6sIteNgxRk5EIJAbaKHwRRDQwr4zL3Y
IAjhAoGBAPeKIEwfvLODz61eTWGXR6ZoVrG0TZvVPzRNL1QnHbaSE2oO9Z2Z1KU6
lhIbhBnIuV+04xgJwHngwGLH4f0eEwCEAkGu3/6jvP6L6KZQgL7KHt0KfTwmXf2C
XjGkmdBtRfOnGWE6147qedqD7XS0a7aQX6b+HlGsBv7IBnP+RoqjAoGBAOw5v5+B
UJTeU7cOFhPKfhCpSPIS0z0Pjvkk1Qv8Z86CKQAvMPz/Nk1mVo6YSQ4594C0/1+g
nC9VSK1kjNY8JO8BTNDoqsYmYOeI3xDF7HKyicqcqdRyH1D5Ac59qOVLl1XBqEQw
lYcilk115+8snwT/I5XVo9+Pd02mu0aH9pRZAoGBAL6MBPCUPZ2yCVtbDBXjbbQa
/SEtudALBuwrvhL5SVYQfAFYIpl+oMHPp1Wo+LcgXBHgHC+U0iT/bRic5MkDLX1o
IJSPGL3bLNCEwkHEFlbHH5rnSB/VKOTMRdXQ7tYSR5aXOmIt+WB5/fLHOzJq779I
w1i4pH4Z/giB0PXY9lQhAoGBALYaxqhV7iL1SaACke5r2cdKWVuUO5gE2HkkdcCp
sfS2zpi/yIogzGHalLuUli0LbsufvIahsAWlP0O8Ef5Nm0NMw0UBODVM/MNA9oVd
ryu0ixjQsPN/jrjDXSssH/mzzlRj2C3JLlxgw3GvhT8SLPyTG4G0koITfSs1b4Wt
5t7xAoGANFgKfjvJ0XtQk49ouczwxeyyfbrzpZF4yPEVZc0a9RqjktL8EDKi0KUy
LUeYPraapSHbiUcnxeoExq/U+8pkEtyEgmv7EgwO6juiKwppA/NzG0hZXJ/IZCOr
oMKkmFP68G9RPkh0pCTCltc8EcoKarJaDZW/WpUPJiE2gVlWb/0=
-----END RSA PRIVATE KEY-----"
ALIYUN="code.ucse.net,47.93.177.100 ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBNuBs1jD3Q8wS8EVILhzevL9sZ1kPawaCAUppYaoEEVR3uxoGjK0QOuSo/Kh4HWT7wK5jc4dqNYOlbTMu16raLE="
RSA_PUB="ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCxfYnV2gBrlynQgKnUWz2Cv3d9PQvBxe/t7BdZUnKayLdQIAVEzHQ7c+Xic6AaUWVVvlTMWs2aKvTWk7ml1MZSxba9M0vR2SHHGtv6i3ppgvBmuhuDUbD8V673Z3W6lFv3yG8Yoapjgtq9rv0Qg7OrdhJbRjW/xPjya2QJ9E3YrGO5ROvhuPg1M3pg3muDFOhqwyi7WJ/NuYqOBhSeMZmqp574MOy6louBxB95QVvXKLjvNyuO0HCWUsbutwXaGeiyERJi94mXWsQk3wNlVWByBnTWdK/ku+W6SlxieIHL0uiUAyiaoJO9u+BgVnUkHOIdRWosEGdIxtNPcow3OFPR duanxuqiang@ucse.net"
# 一些环境变量的检测和设置
[ -z "$WORKDIR" ] && WORKDIR=/var
[ -z "$WEB_DIR" ] && WEB_DIR=${WORKDIR}/www
[ -z "$IS_LOCAL" ] && IS_LOCAL=0

#开发环境，不再继续
[ "$IS_LOCAL" = 1 ] && exit 0

#开始服务器部署逻辑
[ -z "$APP_DIR" ] && APP_DIR=${WEB_DIR}/"$GIT_REPO_NAME"
[ ! -d "$APP_DIR" ] && mkdir -p ${APP_DIR}
BRANCH_DIR=${APP_DIR}
#chown www.www ${APP_DIR} -R
#[ -z "$BRANCH_DIR" ] && BRANCH_DIR=${APP_DIR}/${GIT_BRANCH}
#echo "$BRANCH_DIR">>${LOG_NAME}

#新机器初始化密钥
if [ ! -z "$RSA" ] && [ ! -f ~/.ssh/id_rsa ]; then
    echo "初始化机器">>${LOG_NAME}
    [ ! -d ~/.ssh ] && mkdir -p ~/.ssh
    chmod 700 ~/.ssh
    #这里linux只需要私钥，而mac下需要公钥私钥
    #echo "$RSA_PUB" > ~/.ssh/id_rsa.pub
    echo "$RSA" > ~/.ssh/id_rsa
    echo "$ALIYUN" >> ~/.ssh/known_hosts
    chmod 644 ~/.ssh/*
    chmod 600 ~/.ssh/id_rsa

    [ ! -z "$GIT_EMAIL" ] && git config --global user.email "$GIT_EMAIL"
    [ ! -z "$GIT_NAME" ] && git config --global user.name "$GIT_NAME"
fi

#更新代码
if [ ! -d "${BRANCH_DIR}/.git" ]; then
    #新部署
    echo "开始部署" >> ${LOG_NAME}
    if [ ! -z "$GIT_REPO" ]; then
        echo "开始克隆" >> ${LOG_NAME}
        rm -Rf ${BRANCH_DIR}/*
        cd ${BRANCH_DIR}
        LOG1=$(git clone -b ${GIT_BRANCH} ${GIT_REPO} ./ 2>&1)
        echo "$LOG1" >> ${LOG_NAME}
    fi
else
    #已部署过
    echo "开始更新" >> ${LOG_NAME}
    [ -z "$GIT_BRANCH" ] && GIT_BRANCH="develop"

    GIT_PULL_BRANCH="git pull origin ${GIT_BRANCH}"
    cd ${BRANCH_DIR}
    GIT_RESULT=`${GIT_PULL_BRANCH}`
    echo "$GIT_RESULT">>${LOG_NAME}
# `echo ${#XX}`打印出XX的长度
    if [ 25 -eq `echo ${#GIT_RESULT}` ]; then
        git reset --hard HEAD
        "执行了reset">>${LOG_NAME}
        GIT_RESULT=`${GIT_PULL_BRANCH}`
        echo "$GIT_RESULT">>${LOG_NAME}
    fi
fi

if [ ! -d "$BRANCH_DIR/framework" ] && [[ ! ${GIT_REPO_NAME} =~ "framework" ]]; then
    cd ${BRANCH_DIR}
    if [[ ${GIT_REPO_NAME} =~ "admin" ]]
    then
        echo "新建ucse_admin_framework软链" >> ${LOG_NAME}
        ln -s ../ucse_admin_framework ./framework
    else
        echo "新建ucse_framework软链" >> ${LOG_NAME}
        ln -s ../ucse_framework ./framework
    fi
fi

echo -e "end\n" >> ${LOG_NAME}

#把目录归属
#chown www.www ${BRANCH_DIR} -R
