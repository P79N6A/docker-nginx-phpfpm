<?php
/**
 * 部署数据过滤处理
 *
 * @author duanxuqiang@ucse.net
 * @version 2018/3/21
 */
define('CACHE_PATH','/var/log/deploy/');
date_default_timezone_set('Asia/Shanghai');
//报错开关
#ini_set("display_errors", "On");
//报错等级 0 关闭 -1 全开
#error_reporting(-1);
class Cache
{
    /**
     * 写入
     * @author duanxuqiang@ucse.net
     * @version 2018/3/24
     * @param mixed $content
     * @param string $name
     * @param string $path
     * @return bool|int
     */
    public static function set($content, $name='', $path='')
    {
        defined('CACHE_PATH') && $path = CACHE_PATH.$path;
        if (!$name) return false;
        self::checkDir($path);
        $file = $path.$name;
        if (is_array($content) || is_object($content)) $content = json_encode($content,JSON_UNESCAPED_UNICODE);
        return file_put_contents($file,$content);
    }

    /**
     * 获取缓存
     * @author duanxuqiang@ucse.net
     * @version 2018/3/24
     * @param string $name
     * @param string $path
     * @return mixed
     */
    public static function get( $name='', $path='')
    {
        defined('CACHE_PATH') && $path = CACHE_PATH.$path;
        $file = $path.$name;
        $cache = json_decode(@file_get_contents($file),true);
        return $cache;
    }

    /**
     * 检测是否是有该文件夹，没有则生成
     * @author duanxuqiang@ucse.net
     * @version 2018/3/24
     * @param string $dir
     * @param int $mode
     * @return bool
     */
    public static function checkDir($dir='', $mode=0770) {
        if (!$dir)  return false;
        if(!is_dir($dir)) {
            if (!file_exists($dir) && mkdir($dir, $mode, true))
                return true;
            return false;
        }
        return true;
    }

    /**
     * 写入日志到文件
     * @author duanxuqiang@ucse.net
     * @version 2018/3/27
     * @param mixed $log 日志内容
     * @param string $name 日志文件名
     * @param string $path 日志路径
     */
    public static function log($log, $name='', $path='')
    {
        if (!$path){
            defined('CACHE_PATH') && $path = CACHE_PATH.$path;
            $path = $path.date('Ymd/');
        }else{
            defined('CACHE_PATH') && $path = CACHE_PATH.$path;
        }
        if (!$name) $name = date( 'Ymd' );
        self::checkDir($path);
        $file = $path.$name.'.log';
        if (is_array($log) || is_object($log)) $log = json_encode($log,JSON_UNESCAPED_UNICODE);
        $content = "\nTime : ".date('Y-m-d H:i:s')."\nData : ".$log;
        file_put_contents($file,$content,FILE_APPEND);
        #error_log($content,3,$file);
    }


}

class Deploy
{
    protected static $repoInfo=[
        'platform.admin'=>'admin/platform'
    ];
    const SHELL = '/shell/deploy.sh';
    public static $tmp = [
        "ref"=> "refs/heads/master",
        "checkout_sha"=> "586efabad911c3405a60a7d1d90922853b30ba59",
        "user_email"=> "duanxuqiang@ucse.net",
        "commits"=> [
            "id"=>"586efabad911c3405a60a7d1d90922853b30ba59",
        ]

    ];


    public static function process()
    {
        # 接收数据并处理
        $post = file_get_contents("php://input");
        Cache::log($post,'git_push_log');
//        file_put_contents('event.json',$post);
        $post = json_decode($post,true);
//        file_put_contents('event.json',json_encode($post,256));
        # 检测不通过
        $ip = self::getIp();
        if (!self::check($ip)) {
            Cache::log(['ip'=>$ip,'data'=>$post],'deploy_err');
            die();
        }

        $branch = explode('/',$post['ref']);
        $GIT_BRANCH = end($branch);
        if($GIT_BRANCH != 'develop'){
            Cache::log("分支错误 $GIT_BRANCH",'deploy_err');
            die();
        }
        $GIT_REPO_NAME = $post['repository']['name'];
        $repo = self::toPath($post['repository']['name']);
        if(!$repo){
            Cache::log(['data'=>$post],'deploy_err');
            die();
        }

        $GIT_REPO = $post['repository']['git_ssh_url'];
        $log = [
            'branch'=>$GIT_BRANCH,
            'repo_name'=>$GIT_REPO_NAME,
            #'repo_url'=>$GIT_REPO,
            'msg'=>$post['commits']['message'],
            'user_email'=>$post['user_email'],
            'deploy_time'=>date('Y-m-d H:i:s')
        ];
        Cache::log($log,'deploy');
        system(self::SHELL." $GIT_BRANCH $GIT_REPO_NAME $GIT_REPO",$state);
    }

    /**
     * admin项目的转换
     * @author duanxuqiang@ucse.net
     * @version 2018/3/28
     * @param $data
     * @return bool
     */
    protected static function toPath($data)
    {
        if(strpos($data,'.') === false){
            return $data;
        }
        $repo = explode('.',$data);
        if(!$repo) return false;
        return $repo[1].$repo[0];
    }


    /**
     * 简单的安全校验
     * @author duanxuqiang@ucse.net
     * @version 2018/3/28
     * @param $data
     * @return bool
     */
    protected static function check($ip)
    {
        $whiteList = ['47.93.177.100','121.43.182.162','127.0.0.1','172.16.3.8'];
        if(in_array($ip,$whiteList)) return true;
        return false;
    }

    /**
     * 获取IP
     * @return string $ip
     */
    protected static function getIp() {
        static $ip = null;
        if ($ip !== null) {
            return $ip;
        }
        //判断是否为代理/别名/常规
        if (getenv('HTTP_X_FORWARDED_FOR')) {
            $ip = getenv('HTTP_X_FORWARDED_FOR');
        } else if (getenv('HTTP_CLIENT_IP')) {
            $ip = getenv('HTTP_CLIENT_IP');
        } else {
            $ip = getenv('REMOTE_ADDR');
        }
        return $ip;
    }
}

Deploy::process();




