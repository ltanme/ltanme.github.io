---
title: "Enable Public Network IPv6 Access for Home Routers"
date: 2024-09-11T20:52:28+08:00
draft: false
tags: ["ipv6"]
---
# 记一次开启给家庭网络开通公网ip访问，方便远程访问nas同步照片，资料等
> 我的设备为广东移动+openwrt(r5s)， 我上网模式是光猫拨号，路由器nat
> 1.找到登录光猫后台用户名和密码   
![img.png](img.png)   
> 2.设置如下状态如下->如图所示   

![img_1.png](img_1.png) 
先把这里的沟去掉吧，后续再优化，看能否通网   
![img_2.png](img_2.png)
![img_3.png](img_3.png)  
![img_4.png](img_4.png)   
![img_5.png](img_5.png)  

> 3.openwrt设置-> 如图所示  
  以下也是全部选择接受，从wan口到lan口接受
   先看是否能通，后续慢慢做安全优化
![img_6.png](img_6.png)  
![img_7.png](img_7.png)  
![img_8.png](img_8.png)  
![img_9.png](img_9.png)  
![img_10.png](img_10.png)  

> 测试 用手机5g流量,浏览器打开访问    
![img_11.png](img_11.png)

ipv6 通网成功,不过后续ipv6 地址经常变动，但可以在pt站点查看做种的ip地址
