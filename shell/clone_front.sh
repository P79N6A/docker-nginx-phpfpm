#!/usr/bin/env bash
PROJECT_LIST="
sina_include
ucse_framework
ucse_admin_framework
www.xuemao.com
xiaodai.ucse.net
intra.ucse.net
video.service.ucse.net
newadmin.ucse.net
api.ucse.net
admission.edvantage.com.cn
admin.application.xuemao.com
weixinxd.ucse.net
admin.weixin.ucse.net
admin.platform.ucse.net
admin.marketing.xuemao.com
admin.interview.xuemao.com
proxy.xuemao.com
qrcode.ucse.net
m.xuemao.com
passport.xuemao.com
openapi.xuemao.com
admin.aftersale.xuemao.com
admin.user.xuemao.com
hr.ucse.net
"
for i in ${PROJECT_LIST}; do bash /shell/deploy.sh master ${i} git@code.ucse.net:xuemao_php/${i}.git; done

bash /shell/link.sh