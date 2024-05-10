---
title: "Records of Problems Encountered During the Installation and Initialization of Thingsboard 3.6.4"
date: 2024-05-10T10:41:26+08:00
draft: false
featured: true
tags: ["thingsboard", "IoT","lombok","JDK17"]
---
#　Records of Problems Encountered During the Installation and Initialization of Thingsboard 3.6.4
> 记录`thingsboard3.6.4`在导入 `IntelliJ IDEA 2022.2.3` 编译报错的一些问题

> 导入步骤简单说一下，先从github下载thingsboard3.6.4 源码 
> 导入代码前提准备是环境，我的环境如下
> windows 10
> IntelliJ IDEA 2022.2.3  
IntelliJ IDEA 只需要安装 protocol buffers 和 lombook 就可以了
> JDK17,不是jdk11
> 在本地安装postgreSQL,创建好数据库名`thingsboard364`
> 然后导入到IntelliJ IDEA 2022.2.3。
>  从复制sql脚本到application的`src/main/data/`目录下
  ![img.png](img.png)
> 点击 **IntelliJ IDEA** maven package 进行编译项目
# 我遇到的问题如下：
> lombok 在jdk17下版本太低不兼容
```shell
class lombok.javac.apt.LombokProcessor (in unnamed module @0x719f35fe) 
cannot access class com.sun.tools.javac.processing.JavacProcessingEnvironment
 (in module jdk.compiler) 
 because module jdk.compiler does not export com.sun.tools.javac.processing to
  unnamed module @0x719f35fe
```
> 解决lombok 报错
> The issue you are facing with the error "java.lang.IllegalAccessError: class lombok.javac.apt.LombokProcessor" is related to compatibility problems between Lombok and JDK versions. To resolve this issue, you need to ensure that you are using a compatible version of Lombok with your JDK. Upgrading Lombok to version 1.18.22 or higher should address this problem. Additionally, make sure that Lombok is set up correctly in your project configuration.
The error occurs because Java 17 enforces strong encapsulation, and using an older version of Lombok can lead to this issue. By upgrading to Lombok version 1.18.22 or newer, you should be able to resolve the problem. It's crucial to verify that you are indeed using the correct version of Lombok for your build to avoid compatibility issues   
> 
这个错误是因为Java 17 强制执行强封装，使用较旧版本的Lombok可能会导致此问题。通过升级到Lombok 1.18.22或更新版本，您应该能够解决这个问题。务必验证您确实正在使用正确的Lombok版本来构建，以避免兼容性问题。

在`thingsboard` 根项目目录下`pom.xml` 修改 第85行
<lombok.version>1.18.18</lombok.version>
```xml
<lombok.version>1.18.26</lombok.version>
```


