---
title: "Application Based on lua-resty-balancer"
date: 2021-05-30T12:46:19+08:00
draft: true 
tags: ["openresty","lua-rest-balancer","librestychash","gcc"] 
featured: true
---

# 基于openresty  lua-resty-balancer 模块实现自定义分流功能



> 该模块为提供分流算法，抽离了hash算法, roundrobin轮询等，好处使业务灵活调用算法而分配对像。该对像不一定指服务器，也可以是数据对像或文件对像等等



1，下载https://github.com/openresty/lua-resty-balancer

   编译安装balancer 

   在[lua-resty-balancer](https://github.com/openresty/lua-resty-balancer)目录下执行 

```shell
 gcc -O2 -fPIC -I/usr/local/include -c chash.c -o chash.o

 gcc -shared -o librestychash.so chash.o
```

  将编译后的so文件存放在openresty 安装目录下的lualib 文件夹下即可，

  把 chash.lua   roundrobin.lua    两个文件复制到lualib/resty 目录下即可

2，应用业务代码

```nginx
worker_processes  1;
error_log logs/error.log debug;
events {
    worker_connections 1024;
}

http {
    init_by_lua_block {
	    local resty_chash = require "resty.chash"
		local cjson = require("cjson.safe")
        local object_list_1999 = {
            ["1985"] = 50,
            ["1986"] = 50
        }
        local str_null = string.char(0)
        local pids, nodes = {}, {}
        for pid, weight in pairs(object_list_1999) do
            local id = string.gsub(pid, ":", str_null) 
            pids[id] = pid
            nodes[id] = weight
        end
        local chash_up = resty_chash:new(nodes)
        package.loaded.my_chash_up_1999 = chash_up
        package.loaded.my_ids_1999 = pids
	}
    server {
        listen 80;
		charset utf-8;
        location /fpId {
		    default_type text/html;
			content_by_lua_block {
				local args, err = ngx.req.get_uri_args()
				local userId  = args["userId"]
				local chash_up = package.loaded.my_chash_up_1999
				local pid = package.loaded.my_ids_1999
				local id = chash_up:find(userId)
				local hit_id = pid[id]
				ngx.say("用户ID:"..userId.. "命中了:"..hit_id)
			}
        }
    }
}
```

