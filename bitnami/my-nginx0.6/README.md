# nginx
## v0.1
用下面命令创建一个空的chart。helm默认的这个chart部署了一个nginx的实例。
```
helm create my-nginx
```

## v0.2

* 增加questions.yml
* 修改service type 为可选三种类型
* 配置ingress

## v0.3 

* 挂载nfs卷
  前提：已Rancher上已经启动应用nfs-client-provisioner，并将一个nfs服务器挂载其上。

   目的：挂载一个卷到nginx容器的启动目录。

  > 1: 增加一个pvc模板，my-nginx-pvc.yaml
  >
  > 2: 在deployment.yaml中claim volumes以及挂载volumes
  >
  > 这里将卷挂载在容器的/usr/share/nginx/html/test目录下

## v0.4

* 挂载配置文件卷

  > 1: 创建一个configMap，命名为server-block-configmap.yaml
  >
  > 它创建了一个data对象，包含server-blocks-paths.conf，server-block.conf
  >
  > 如果`existingServerBlockConfigmap` 有设置，那代表读取已经存在的configmap，这会override上面创建的configMap
  >
  > 2：修改deployment.yaml文件，挂载这个configmap。
  >
  > 挂载的时候使用subPath，挂在server-blocks-paths.conf到/etc/nginx/conf.d文件夹下，原有的default.conf不变
  >
  > ```
  >  volumeMounts:
  >           - name: nginx-server-block-paths
  >             mountPath: /etc/nginx/conf.d/server-blocks-paths.conf
  >             subPath: server-blocks-paths.conf
  > 
  > ```
  >
  > 

## v0.5

* 挂载静态网站
  思路: 用初始化容器来github上下载静态网站，然后挂载在nginx容器上。

  > 挂载staticsite卷，三种方式：
  >
  > * 如果是使用git下载静态网站代码，那么创建一个空卷，交由初始化容器来运行。
  >
  > * 使用staticSiteConfigmap存储静态网站内容，读取相应的configmap
  >
  > * 使用staticSitePVC单独卷的模式存储静态网站内容，直接使用staticSitePVC
  >
  > 这个三个卷的挂载逻辑定义在_helpers.tpl文件中，优先级是git>staticSiteConfigmap>staticSitePVC
  >
  > 使用git方式会覆盖其它两种方式，并且需要在deployment.yaml中增加两个initcontainer，一个下载代码，一个定期更新代码.
  >
  > 
  >

调试了半天，总是报错：“error: error converting YAML to JSON: yaml: line 15: did not find expected key，“ mapping values are not allowed in this context”，后来发现主要是由于空格和对齐问题引起的。

此外需要注意的是，报错的行号，是表示转换后的yaml文件的行数，不是转换前的。所以在根据报错行数找原始文件中的行数时，往往不是同一个行，可能推前也可能推后。

## v0.6

* liveness and readiness probes

相关概念，参考此文[kubernetes系列之八：Kubernetes的liveness和readiness探测](https://blog.csdn.net/cloudvtech/article/details/80216116?utm_medium=distribute.pc_relevant.none-task-blog-BlogCommendFromMachineLearnPai2-1.nonecase&depth_1-utm_source=distribute.pc_relevant.none-task-blog-BlogCommendFromMachineLearnPai2-1.nonecase)

这里建了一个来检测nginx容器的健康

* 用启动一个php容器，和nginx配置使用。挂载一个php网站。

  php的镜像，选用php官方的php:[7.4.6-fpm](https://hub.docker.com/layers/php/library/php/7.4.6-fpm/images/sha256-42313e7eb1eb0e018de000c76cd6d35dc82f0f4879c0dff3f37fd6640a4d858e?context=explore)版本

  * 在deployment.yml中增加php的内容。

  * 因为nginx和phpfpm在同一个pod里面，所以无需暴露服务

  *   增加nginx中的关于php的配置。

    ```
     server {
        listen 0.0.0.0:80;
        
         location / {
           root   /usr/share/nginx/html;
           index index.html index.php;
          }
         location ~ \.php$ {
            root /var/www/html;
            fastcgi_pass 127.0.0.1:9000;
            fastcgi_index index.php;
            fastcgi_param  SCRIPT_FILENAME  $document_root$fastcgi_script_name;
            include        fastcgi_params;
         }
       }
    ```

    phpfpm-server用容器名代替，这里是my-nginx-phpfpm

  用这个php网站代码来做测试，https://github.com/phhpro/atomchat.git，因为它不需要链接数据库。
    