---
title: "Managing Multiple Git Accounts on Windows 10"
date: 2023-09-19T19:19:09+08:00
draft: false
---

# 在 Windows 10 下管理多个 Git 账号
> 问题背景描述 
在开发过程中，开发者经常需要在多个代码托管平台（例如 GitHub、GitLab 或公司私有的代码托管平台）之间切换。这样做可能会引发一系列问题，尤其是当你需要使用不同的 Git 账号进行代码提交时。
> 本文将指导你如何在 Windows 10 下管理多个 Git 账号，并确保你的用户名和电子邮件地址不被泄露。   
> `为什么要采用ssh提交git代码,而不是用http协议提交代码`  
> `个人认为主要是ssh提供更好的安全，而用http提交的话，一但会话失效需要重登录，甚至还要用浏览器登录一下非常不便`
## 前提条件
- 已安装 Git
- Windows 10 操作系统

## 步骤 1: 生成 SSH 密钥

首先，为每一个 Git 账号生成一个 SSH 密钥。
打开gitbash cmd 命令窗口,如果安装了git的话，在安装目录下找到bash窗口

```bash
# 生成 SSH 密钥为 GitHub 账号
ssh-keygen -t rsa -b 4096 -C "your_email@example.com" -f /c/Users/admin/.ssh/id_rsa_mygithubusername

# 生成 SSH 密钥为公司的 Git 账号
ssh-keygen -t rsa -b 4096 -C "your_work_email@example.com" -f /c/Users/admin/.ssh/id_rsa_mycompanyname
```
## 步骤 2: 创建 SSH Config 文件
> 在 C:\Users\admin\.ssh 目录下创建一个 config 文件（`如果没有的话`），并添加以下内容：
```shell
# GitHub a 账号
Host github.com
  HostName github.com
  User git
  IdentityFile C:\Users\admin\.ssh\id_rsa_mygithubusername_a  #这是存在在本地的私钥，pub文件公钥上传到github上

# GitHub b 账号
Host github.com
  HostName github.com
  User git
  IdentityFile C:\Users\admin\.ssh\id_rsa_mygithubusername_b  #这是存在在本地的私钥，pub文件公钥上传到github上

# 公司 Git 账号
Host work.git
  HostName company.git
  User git
  IdentityFile C:\Users\admin\.ssh\id_rsa_mycompanyname  #这是存在本地的私钥，pub文件公钥上传到公司gitlib上
```

## 步骤 3: 配置 Git 用户信息,
> 为了保证不泄露个人信息，你可以在每个项目目录下单独设置 Git 用户名和电子邮件。
```shell
    # 在项目目录下运行，也就是为每个项目单独添加独立的name和email而不用公共的，默认的
    git config user.name "Your Name"
    git config user.email "your_email@example.com"
```
> 如果的你的项目已经存在，或者是通过http接口上传的gitlib的，可以找到项目根目录下有个.git隐藏目录 打开它
> 然后找到config文件，并打开它，显示如下内容
```shell
[core]
	repositoryformatversion = 0
	filemode = false
	bare = false
	logallrefupdates = true
	symlinks = false
	ignorecase = true
[remote "origin"]
	url = http://gitlab.company.com/forest/holly.git
	fetch = +refs/heads/*:refs/remotes/origin/*
[branch "master"]
	remote = origin
	merge = refs/heads/master
[branch "dev"]
	remote = origin
	merge = refs/heads/dev
[user]
	name = your name   # 切记这里一定要添加你的name,否则是用默认全局,泄露信息，可以匿名
	email = your email # 切记这里一定要添加你的eamil,否则是用默认全局 泄露信息 可以匿名	
```
> 只要将以上url 修改为git@gitlab.company.com:forest/holly.git 即可马上提交代码

> 如果遇到github.com 多个账号都要提交不同的代码怎么办？
> 分别给每个账号生成一对公私钥对，把公钥分别添加`SSH and GPG keys` github上即可
> 然后在项目.git目录下找到config文件内容修改如下：
```shell
[core]
	repositoryformatversion = 0
	filemode = false
	bare = false
	logallrefupdates = true
	symlinks = false
	ignorecase = true
[remote "origin"]
	url = git@github.com-{你的github账号}:用户名/项目名   #主要是这里，在github.com后面添加-账号
	fetch = +refs/heads/*:refs/remotes/origin/*
[branch "master"]
	remote = origin
	merge = refs/heads/master
[branch "dev"]
	remote = origin
	merge = refs/heads/dev
[user]
	name = your name   # 切记这里一定要添加你的name,否则是用默认全局,泄露信息，可以匿名
	email = your email # 切记这里一定要添加你的eamil,否则是用默认全局 泄露信息 可以匿名
```