---
title: "How to solve SpringBoot Mysql CLIENT_PLUGIN_AUTH Is Required error"
date: 2021-12-07T09:54:05+08:00
draft: false
tags: ["java","mysql"]
---

# 一次上线遇到的问mysql版本使用问题CLIENT_PLUGIN_AUTH

> 当在项目做好即将上线时，突然发现线上数据库版本太低而报如题错误，导致程序上线启动失败，现有数据库己被很多老的项目在使用着，不可能让dba去更新数据库版本，或另开服务器。
>
> 找了一下原因，是因为使用spring boot 2.x版本，相对比较新，而默认使用的数据库版本为mysql-connect 库 8.x，而需要手动给mysql connect jar包库版本降级，从8.x降到5.1.48
>
> 主要处理方法是
>
> 第一、需要在 父pom.xml 文件里先指定
>
> ```xml
> <mysql.version>5.1.48</mysql.version>
> ```
>
> 第二、修改jdbc使用驱动jar包类
>
>    由`com.mysql.cj.jdbc.Driver` 改为 `com.mysql.jdbc.Driver`
>
>    链接url
>
> ```yaml
> url: jdbc:mysql://172.20.1.2:3406/xxx?useUnicode=true&characterEncoding=UTF-8&useJDBCCompliantTimezoneShift=true&useLegacyDatetimeCode=false&serverTimezone=Asia/Shanghai&zeroDateTimeBehavior=CONVERT_TO_NULL
> ```
>
> 改为：
>
>  ```yaml
>  jdbc:mysql://172.20.1.2:3406/xxx?useUnicode=true&characterEncoding=UTF-8&useJDBCCompliantTimezoneShift=true&useLegacyDatetimeCode=false&serverTimezone=Asia/Shanghai&zeroDateTimeBehavior=convertToNull
>  ```
>
> `CONVERT_TO_NULL  `  to  `convertToNull`

   

大功告成，顺利上线