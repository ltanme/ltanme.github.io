---
title: "Record an Error During Node RED Deployment"
date: 2024-02-22T20:50:54+08:00
draft: false
tags: ["nodered", "pm2", "docker"]
---

# 记一次在docker 打包部署node red 启动报错

报错如下：
```shell
---------------------------------------------------------------------
Your flow credentials file is encrypted using a system-generated key.

If the system-generated key is lost for any reason, your credentials
file will not be recoverable, you will have to delete it and re-enter
your credentials.

You should set your own key using the 'credentialSecret' option in
your settings file. Node-RED will then re-encrypt your credentials
file using your chosen key the next time you deploy a change.
---------------------------------------------------------------------

22 Feb 20:47:25 - [warn] Encrypted credentials not found
22 Feb 20:47:25 - [info] Server now running at http://127.0.0.1:3002/
22 Feb 20:47:25 - [info] Starting flows
22 Feb 20:47:25 - [info] Started flows

22 Feb 20:47:35 - [warn] Flushing file /data/nodes to disk failed : Error: EISDIR: illegal operation on a directory, rename '/data/nodes.$$$' -> '/data/nodes'
22 Feb 20:47:35 - [warn] Error saving flows: EISDIR: illegal operation on a directory, rename '/data/nodes.$$$' -> '/data/nodes'
22 Feb 20:47:35 - [warn] Error: EISDIR: illegal operation on a directory, rename '/data/nodes.$$$' -> '/data/nodes'

```


## PM2启动信息

使用如下PM2配置文件启动Node-RED实例：

```json
# cat pm2-nodered.json
    {
        "apps": [
           {
                "name": "NR-INSTANCE-3002",
                "script": "/usr/src/node-red/packages/node_modules/node-red/red.js",
                "args": "--userDir /data/config/node-red-3002  --nodesDir /data/nodes --port 3002",
                "exec_mode": "fork",
                "node_args": ["--inspect=9000"]
           }
        ]
    }
```

## 我的settings.js 文件的nodesDir 配置如下:
  ```js
      nodesDir:/data/nodes,
```

## 最终解决方法为： 
在启动命令中去除--nodesDir /data/nodes选项。官方不推荐在命令行中使用此选项，因为nodes.$$$是一个临时文件夹，起初以为是权限问题，后来发现并非如此。
若在命令行中指定--nodesDir /data/nodes，且settings.js文件中也有设置，命令行的设置会优先生效。但如果两者同时设置，可能会引起兼容性问题或其他未知问题。
