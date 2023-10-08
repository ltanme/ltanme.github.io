---
title: "Resolving the Issue of Centos 7 Vm Unable to Ping Its Host Machine"
date: 2023-10-08T19:16:07+08:00
tags: ["vmware","docker"]
featured: true
---

# 解决因docker网络导致的网络问题，无法ping通局域网ip

## 背景

在我的办公室网络环境中，我有一个 Windows 10 宿主机，上面安装了 VMware，并在 VMware 中运行了一个 CentOS 7 虚拟机。虽然宿主机和 CentOS 7 虚拟机都可以正常上网并 ping 通外部地址，但 CentOS 7 无法 ping 通宿主机。这让我非常困惑，并最初怀疑可能是公司的网管对我的 MAC 地址进行了某种限制。
```shell
[root@localhost ~]# route -n
Kernel IP routing table
Destination     Gateway         Genmask         Flags Metric Ref    Use Iface
0.0.0.0         172.22.128.1    0.0.0.0         UG    100    0        0 ens33
172.17.0.0      0.0.0.0         255.255.0.0     U     0      0        0 docker0
172.18.0.0      0.0.0.0         255.255.0.0     U     0      0        0 br-6b8659f8f886
172.19.0.0      0.0.0.0         255.255.0.0     U     0      0        0 br-89bc77a42b8a
172.20.0.0      0.0.0.0         255.255.0.0     U     0      0        0 br-b4e656893ece
172.22.128.0    0.0.0.0         255.255.240.0   U     100    0        0 ens33
172.26.0.0      0.0.0.0         255.255.0.0     U     0      0        0 br-5b7ab2df8a43
```

> 虚拟机上有多个 Docker 网络，其中一个网络（br-b4e656893ece）与宿主机的网络冲突。  
> 这意味着， 尝试 ping 宿主机时，数据包可能被发送到了 Docker 网络，而不是真正的物理网络。  
> 这是最关键的问题所在

## 问现现像
> 我的一个局域网ip ping不通
```shell
[root@localhost ~]# ping 172.20.151.90
PING 172.20.151.90 (172.20.151.90) 56(84) bytes of data.
From 172.20.0.1 icmp_seq=1 Destination Host Unreachable
From 172.20.0.1 icmp_seq=2 Destination Host Unreachable
From 172.20.0.1 icmp_seq=3 Destination Host Unreachable
From 172.20.0.1 icmp_seq=4 Destination Host Unreachable
```

## 诊断过程

经过一系列的诊断步骤，包括：

1. 检查 VMware 的网络模式设置。
2. 检查 Windows 和 CentOS 的防火墙设置。
3. 使用 `traceroute` 和 `route -n` 命令跟踪网络路径。
4. 检查 CentOS 的路由表。

我发现了一个关键的线索：CentOS 虚拟机上的 Docker 网络与宿主机的网络地址冲突。

## 解决方法

最终确定是 Docker 网络与宿主机网络冲突导致的问题。为了解决这个问题，我采取了以下步骤：

第一步, 停止 Docker 服务。
```shell
sudo systemctl stop docker.service
sudo systemctl stop docker.socket

```
第二步, 手动删除冲突的 Docker 网络或修改其 IP 地址。
```shell
#我选择删除
sudo route del -net 172.20.0.0 netmask 255.255.0.0
```
第三步, 重启 Docker 服务和 CentOS 虚拟机。

经过上述步骤，CentOS 7 虚拟机成功 ping 通了宿主机。

```shell
# check test,it worked!
[root@localhost ~]# ping 172.20.151.90
PING 172.20.151.90 (172.20.151.90) 56(84) bytes of data.
64 bytes from 172.20.151.90: icmp_seq=1 ttl=63 time=0.422 ms
64 bytes from 172.20.151.90: icmp_seq=2 ttl=63 time=0.362 ms
64 bytes from 172.20.151.90: icmp_seq=3 ttl=63 time=0.555 ms
^C
--- 172.20.151.90 ping statistics ---
3 packets transmitted, 3 received, 0% packet loss, time 2000ms
rtt min/avg/max/mdev = 0.362/0.446/0.555/0.082 ms
```

## 结论
> 这次的经验教训是，当遇到网络通信问题时，不仅要检查常见的网络配置和防火墙设置，  
> 还要考虑到其他可能影响网络的因素，例如 Docker 或其他虚拟化技术。而最重要的是，  
> 不要过早地得出结论或怀疑其他人，因为问题的根源可能出乎意料。  