#!/usr/bin/env bash

PROJECT_LIST="
sina_include
ucse_framework
ucse_admin_framework
afterservice.xuemao.com
userservice.xuemao.com
mailservice.xuemao.com
platformservice.ucse.net
interviewservice.xuemao.com
newsservice.ucse.net
marketingservice.xuemao.com
weixinservice.ucse.net
fileservice.ucse.net
imservice.xuemao.com
applicationservice.xuemao.com
boardingservice.xuemao.com
schoolservice.ucse.net
msgservice.ucse.net
static.ucse.net
"
for i in ${PROJECT_LIST}; do bash /shell/deploy.sh master ${i} git@code.ucse.net:xuemao_php/${i}.git; done

bash /shell/link.sh