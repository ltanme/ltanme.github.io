---
title: "Anaconda Modify the Domestic Mirror Ai Learning Section 1"
date: 2021-07-08T20:58:37+08:00
draft: true
tags: ["Anaconda"]
---

# 我的AI学习第一课 Anaconda 修改镜像源

> 为什么要修改镜像源，因为初次使用anaconda 发现下载太慢了，都是从官网服务器拉取模块，需要 等很漫长时间，
>
> 因此网上找了一上镜像源和修改源的方法，就用清华大学的源
>
> `[https://mirrors.tuna.tsinghua.edu.cn/anaconda/pkgs/free/](https://link.jianshu.com/?t=https://mirrors.tuna.tsinghua.edu.cn/anaconda/pkgs/free/)`
>
> 大该分为三步

## 1、首先找到conda安装目录

这里我安装在`D:\anaconda3`  然后找到`condabin`目录

在地址输入 `cmd` 命令并回车执行，在弹窗的cmd 窗口输入以下两条命令

```sh
conda config --add channels https://mirrors.tuna.tsinghua.edu.cn/anaconda/pkgs/free/
conda config --set show_channel_urls yes
```



> 此时，目录 C:\Users<你的用户名> 下就会生成配置文件.condarc，内容如下：

```sh
C:\Users\admin>type .condarc
channels:
  - https://mirrors.tuna.tsinghua.edu.cn/anaconda/pkgs/free/
  - defaults
show_channel_urls: true
```

## 2、修改配置文件

> 删除上述配置文件 .condarc 中的第三行，然后保存，最终版本文件如下：

```sh
channels:
  - https://mirrors.tuna.tsinghua.edu.cn/anaconda/pkgs/free/
show_channel_urls: true
```

## 3、查看是生否生效

> 通过命令 conda info 查看当前配置信息，内容如下，即修改成功，关注 channel URLs 字段内容

```sh
D:\anaconda3\condabin>conda info

     active environment : None
       user config file : C:\Users\admin\.condarc
 populated config files : C:\Users\admin\.condarc
          conda version : 4.10.3
    conda-build version : 3.21.4
         python version : 3.8.8.final.0
       virtual packages : __cuda=11.0=0
                          __win=0=0
                          __archspec=1=x86_64
       base environment : D:\anaconda3  (writable)
      conda av data dir : D:\anaconda3\etc\conda
  conda av metadata url : None
           channel URLs : https://mirrors.tuna.tsinghua.edu.cn/anaconda/pkgs/free/win-64
                          https://mirrors.tuna.tsinghua.edu.cn/anaconda/pkgs/free/noarch
                          https://repo.anaconda.com/pkgs/main/win-64
                          https://repo.anaconda.com/pkgs/main/noarch
                          https://repo.anaconda.com/pkgs/r/win-64
                          https://repo.anaconda.com/pkgs/r/noarch
                          https://repo.anaconda.com/pkgs/msys2/win-64
                          https://repo.anaconda.com/pkgs/msys2/noarch
          package cache : D:\anaconda3\pkgs
                          C:\Users\admin\.conda\pkgs
                          C:\Users\admin\AppData\Local\conda\conda\pkgs
       envs directories : D:\anaconda3\envs
                          C:\Users\admin\.conda\envs
                          C:\Users\admin\AppData\Local\conda\conda\envs
               platform : win-64
             user-agent : conda/4.10.3 requests/2.25.1 CPython/3.8.8 Windows/10 Windows/10.0.19041
          administrator : True
             netrc file : None
           offline mode : False
```

很明显我上述加的 清华镜像源 己成功了，`win-64`