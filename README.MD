# UCSE 开发测试环境
* aliyun镜像仓库
`https://cr.console.aliyun.com/?spm=5176.2020520152.210.d103.471d16ddHRg5BF#/imageList`

* 命令行docker登录aliyun镜像仓库(xxx表示你的用户名)  
`docker login --username=dxq@ucse registry.cn-beijing.aliyuncs.com`

* 拉取镜像  
`docker pull registry.cn-beijing.aliyuncs.com/ucse/test`

* 执行命令  
`docker run --restart always --name test -v /www/ucse/:/var/www/ -p 80:80 -p 443:443 -p 8181:8181 -itd registry.cn-beijing.aliyuncs.com/ucse/test`  
8181是自动部署用的，本地可以不用      
`-v /www/ucse`是自己的项目代码目录

自动更新测试
