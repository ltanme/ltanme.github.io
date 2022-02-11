---
title: "Mybatis Failed to Save Data"
date: 2022-02-11T12:12:06+08:00
draft: true
tags: ["java","mysql","mybatis"]
---

# 记一次遇到mybaits写入数据不成功问题

> 工作中在作日志采集接口时，遇到写入mysql数据不成功时，当时sql是正常的，采用sp6y sql显示粘贴复制到
> mysql client 执行sql执行并没有问题，但是调用接口时，写入mysql不成功，也不报错，遇到这种问题特别
> 困惑，特记录一下，

> 找了一下午才发现问题，最怕就是程序不报错，语句执行成功，但数据库没有数据这样的问题呢
> 主要问题是接口请求实体类有几个版本字段是用的Long 类型的，而mysql表对应的字段是int类型的
> 在用mybatis-generate 插件生成表的 mapper.xml、dao、model时，mysql字段为int类型的生成对应的integer类型
> 但是代码定义的dto 接口请求实体类，字段是long类型，入库时，存在long 转 integer 的行为，行为非法，但执行时sql不报错
> 由于时间关系没有进一步查为什么不报错提示，xml生成的字段类型都是 java.lang.Integer 


> 解决方法 统一 字段类型即可

> 在mysql数据库里，int类型占4个字节对应java的Integer类型，
> 而mysql中的bigint 类型占用8个字节对应java的Long类型, 在mybaits xml 文件没有Long类型，只有BIGINT
