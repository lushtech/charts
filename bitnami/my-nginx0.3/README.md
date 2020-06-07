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

