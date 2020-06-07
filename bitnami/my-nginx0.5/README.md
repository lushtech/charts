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
  > 
  >