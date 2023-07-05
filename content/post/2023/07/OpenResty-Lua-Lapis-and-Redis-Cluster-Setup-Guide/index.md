---
title: "OpenResty Lua Lapis and Redis Cluster Setup Guide"
date: 2023-07-05T16:21:20+08:00
draft: false
tags: ["openrest","lapis","redis"]
featured: true
---
# 安装模块

## 下载并安装lua-resty-redis-cluster模块

- lua-resty-redis-cluster模块的GitHub地址：[https://github.com/iresty/lua-resty-redis-cluster](https://github.com/iresty/lua-resty-redis-cluster)

- 这个模块可以用来连接redis集群。

- 请将这个模块下载到任意的目录下。

- 下载完成后，你只需要在包中找到`rediscluster.lua`和`redis_slot.c`两个文件。

> 注意：`.c`文件无法直接在nginx配置文件中引入，所以我们需要将它编译成`.so`文件。以下是编译命令：

   
    gcc SOURCE_FILES -fPIC -shared -o TARGET 
   

- 使用上面的命令，你可以得到`librestyredisslot.so`文件。也可以生成redis_slot.so具体命令如下：

    
    gcc redis_slot.c  -fPIC -shared -o librestyredisslot.so
     

## 文件放置

- 将编译得到的`librestyredisslot.so`文件复制到`/data/webserver/openresty/lualib/`目录下。

- 将`rediscluster.lua`文件放到`/data/webserver/openresty/lualib/`目录下。



# OpenResty, Lua, Lapis, and Redis Cluster Setup Guide

## Download and Install the lua-resty-redis-cluster Module

- The GitHub link for the lua-resty-redis-cluster module is [here](https://github.com/iresty/lua-resty-redis-cluster).

- This module can be used to connect to a Redis cluster.

- Please download the module into any directory of your choice.

- After downloading, you will need the `rediscluster.lua` and `redis_slot.c` files from the package.

> Note: The `.c` file can't be directly imported into the Nginx configuration file, so it needs to be compiled into a `.so` file. The compilation command is:

    
    gcc SOURCE_FILES -fPIC -shared -o TARGET 
     

- Using the above command, you can obtain the librestyredisslot.so file. You can also generate redis_slot.so with the following specific command.
- The specific command is as follows:

     
    gcc redis_slot.c  -fPIC -shared -o librestyredisslot.so
     

## File Placement

- Copy the compiled `librestyredisslot.so` file into the `/data/webserver/openresty/lualib/` directory.

- Place the `rediscluster.lua` file into the `/data/webserver/openresty/lualib/` directory.