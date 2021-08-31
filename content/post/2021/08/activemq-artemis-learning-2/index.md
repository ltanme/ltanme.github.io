---
title: "Activemq Artemis Learning 2"
date: 2021-08-28T23:21:14+08:00
draft: true
tags: ["activemq artemis"]
---

# activemq artmis 项目所依赖模块说明整理 

> artemis-boot ：项目主要的程序入口，man函数在此

> artemis-cdi-client : cdi 集成 它既可以使用嵌入代理，也可以连接到远程代理。通过实现 `artemis clientconfiguration` 接口提供配置

> artemis-cli: 提供命令工具使用，可以通过命令窗口运行东西，如创建用户，创建`address`

> artemis-commons: 为整个项目提供 api 的统一异常库，网络连接心跳逻辑，日志打印库，连接池，集合库，线程原子锁，uuid生成工具库，时间工具类库

> artemis-core-client:   客户端连接sdk包

> artemis-core-client-all: 全局的客户端sdk包

> artemis-core-client-osgi: 开放服务网关协议的客户端工具sdk包

> artemis-distribution:  打成wapper包 重要模块，决定你的项目打包后最终的结构

> artemis-docker: docker build 镜像脚本

> artemis-dto: 数据层传输 对像

> artemis-features: 项目特性配置，初始化数据配置，端口，依赖版本等配置

> artemis-hawtio:  基于hawtio  用于管理Java东西的模块化Web控制台。 简而言之，这是一个带有插件的网络控制台。 它有[大量的插件](http://hawt.io/plugins/index.html) ，可以自定义和扩展以满足您的需求，web修改，扩展都这里面改，关于web页面的增加，删除等功能

> `artemis-jakarta-client`,`artemis-jakarta-ra`,`artemis-jakarta-server`,`artemis-jakarta-service-extensions` : 	Jakarta是Apache组织下的一套Java解决方案的开源软件的名称

> artemis-jdbc-store:  基于jdbc 数据存储类，如mysql,db2,postgres 等

> artemis-jms-client:

> artemis-jms-client-all:

> artemis-jms-client-osgi:

> artemis-jms-server:

> artemis-journal:

> artemis-junit

> artemis-maven-plugin

> artemis-protocols

> artemis-quorum-api

> artemis-quorum-ri

> artemis-ra

> artemis-rest

> artemis-selector

> artemis-server

> artemis-server-osgi

> artemis-service-extensions

> artemis-web

> artemis-website

> docs

> etc

> examples

> integration

> scripts