---
title: "Common Docker Issues Solutions"
date: 2024-08-15T16:13:23+08:00
draft: true
tags: ["docker"]
---

# Docker 疑难杂症汇总

在使用 Docker 的过程中，可能会遇到各种各样的问题，尤其是在国内环境下，网络限制可能会导致一些操作困难。本文将汇总常见的 Docker 安装与使用过程中可能遇到的疑难杂症，并提供相应的解决方案。

## 1. Docker 安装过程中网络问题

### 问题描述：
在国内使用 `apt-get` 安装 Docker 时，经常遇到无法连接到 Docker 官方仓库 `download.docker.com` 的问题，导致无法获取或更新 Docker 包。

### 解决方案：
- **使用国内镜像源：** 通过修改 Docker 的 APT 源配置文件，切换到国内镜像源（如清华大学、阿里云、中科大等），可以有效解决网络连接问题。

  修改 `/etc/apt/sources.list.d/docker.list` 文件：
  ```bash
  deb [arch=arm64] https://mirrors.tuna.tsinghua.edu.cn/docker-ce/linux/ubuntu jammy stable

#### 添加 GPG 公钥： 如果遇到 GPG 公钥无法获取的问题，可以手动下载并添加公钥：
```bash
curl -fsSL https://mirrors.ustc.edu.cn/docker-ce/linux/ubuntu/gpg | sudo apt-key add -
```
#### 更换DNS或使用VPN： 如果镜像源依旧无法访问，可以尝试更换DNS，或者使用VPN绕过网络限制。

# GPG 公钥问题

问题描述：  
在更新或安装 Docker 过程中，可能会出现关于 GPG 公钥的警告或错误，如：  
```js
The following signatures couldn't be verified because the public key is not available: NO_PUBKEY 7EA0A9C3F273FCD8
```
> 解决方案：  
> 手动添加公钥：  
> 使用以下命令手动添加公钥： 
 ```shell
 
curl -fsSL https://mirrors.ustc.edu.cn/docker-ce/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker-ustc.gpg

 ```
> 将公钥放置到正确的位置：
确保公钥被正确地放置到 /etc/apt/keyrings/ 目录下，并更新 APT 源配置，指定 signed-by 参数。
