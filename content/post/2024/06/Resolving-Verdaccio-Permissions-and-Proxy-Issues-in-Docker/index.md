---
title: "Resolving Verdaccio Permissions and Proxy Issues in Docker"
date: 2024-06-06T20:55:44+08:00
draft: false
tags: ["Verdaccio","Docker","Nginx"]
---

# Resolving Verdaccio Permissions and Proxy Issues in Docker
# 问题 1：无法在 Docker 容器中创建目录

## 问题描述：
> 在构建 Verdaccio 的 Docker 镜像时，尝试创建 /usr/rn-plugin/storage 和 /usr/rn-plugin/plugins 目录时，出现了权限不足的错误。

## 解决方案:
> 通过在 Dockerfile 中切换到 root 用户来创建目录，并设置适当的权限。然后切换回 verdaccio 用户
```shell
# verdaccio.Dockerfile

FROM harbor.example.com/cc_iot/verdaccio:latest

# 设置 Verdaccio 配置
COPY ./verdaccio/config.yaml /verdaccio/conf/config.yaml
COPY ./verdaccio/htpasswd /usr/rn-plugin/htpasswd

# 创建存储和插件目录并设置权限
USER root
RUN mkdir -p /usr/rn-plugin/storage /usr/rn-plugin/plugins && \
    chown -R 10001:10001 /usr/rn-plugin/storage /usr/rn-plugin/plugins && \
    chown 10001:10001 /usr/rn-plugin/htpasswd
USER verdaccio

# 设置存储和插件目录为卷
VOLUME ["/usr/rn-plugin/storage", "/usr/rn-plugin/plugins"]

# 暴露 Verdaccio 端口
EXPOSE 4873

# 设置 Verdaccio 环境变量
ENV VERDACCIO_APPDIR /verdaccio
ENV VERDACCIO_USER verdaccio
ENV VERDACCIO_PORT 4873
ENV VERDACCIO_PROTOCOL http
ENV VERDACCIO_STORAGE /usr/rn-plugin/storage
ENV VERDACCIO_PLUGINS /usr/rn-plugin/plugins
ENV VERDACCIO_LOG_FORMAT pretty
ENV VERDACCIO_LOG_LEVEL trace
ENV VERDACCIO_PUBLIC_URL https://www.example.com/verdaccio

ENTRYPOINT ["/usr/local/bin/verdaccio", "--config", "/verdaccio/conf/config.yaml", "--listen", "0.0.0.0:4873"]

```

# 问题 2：本地宿主机目录权限不足

## 问题描述：
> 在容器中无法写入挂载的本地目录 /root/dd/storage 和 /root/dd/plugins。

## 解决方案：
> 在宿主机上设置正确的目录权限，确保 Docker 容器内的用户可以写入这些目录。
```shell
sudo chown -R 10001:10001 /root/dd/storage /root/dd/plugins 
```

# 问题 3：Nginx 代理设置导致资源路径不正确
## 问题描述：
> 设置 Nginx 代理后，访问 Verdaccio 首页出现 404 错误。
## 解决方案：
> 在 Verdaccio 的配置文件 config.yaml 中设置 url_prefix，并配置 Nginx 代理以正确处理前缀。
## Verdaccio 配置：
```shell
# config.yaml
storage: /usr/rn-plugin/storage
plugins: /usr/rn-plugin/plugins

web:
  title: Verdaccio

auth:
  htpasswd:
    file: /usr/rn-plugin/htpasswd

uplinks:
  npmjs:
    url: https://registry.npmjs.org/
    cache: false

packages:
  '@*/*':
    access: $all
    publish: $authenticated
    unpublish: $authenticated
    proxy: npmjs

  '**':
    access: $all
    publish: $authenticated
    unpublish: $authenticated
    proxy: npmjs

server:
  keepAliveTimeout: 60

url_prefix: '/verdaccio/'

log:
  type: stdout
  format: pretty
  level: trace

```

## Nginx 配置：
```shell
location /verdaccio/ {
    proxy_pass http://172.20.151.17:4873/;
    proxy_set_header Host $host;
    proxy_set_header X-Real-IP $remote_addr;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header X-Forwarded-Proto $scheme;
    proxy_set_header X-Forwarded-Prefix /verdaccio;
    proxy_buffering off;
}

location /verdaccio/-/ {
    proxy_pass http://172.20.151.17:4873/-/;
    proxy_set_header Host $host;
    proxy_set_header X-Real-IP $remote_addr;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header X-Forwarded-Proto $scheme;
    proxy_set_header X-Forwarded-Prefix /verdaccio;
    proxy_buffering off;
}

```

# 问题 4：权限不足无法创建用户
## 问题描述：
> 尝试在 Verdaccio 中创建用户时出现权限不足的错误。
## 解决方案：
> 确保在 Dockerfile 中设置适当的权限，并在宿主机上设置正确的目录权限。
``` shell
# verdaccio.Dockerfile

FROM harbor.example.com/cc_iot/verdaccio:latest

# 设置 Verdaccio 配置
COPY ./verdaccio/config.yaml /verdaccio/conf/config.yaml
COPY ./verdaccio/htpasswd /usr/rn-plugin/htpasswd

# 创建存储和插件目录并设置权限
USER root
RUN mkdir -p /usr/rn-plugin/storage /usr/rn-plugin/plugins && \
    chown -R 10001:10001 /usr/rn-plugin/storage /usr/rn-plugin/plugins && \
    chown 10001:10001 /usr/rn-plugin/htpasswd
USER verdaccio

# 设置存储和插件目录为卷
VOLUME ["/usr/rn-plugin/storage", "/usr/rn-plugin/plugins"]

# 暴露 Verdaccio 端口
EXPOSE 4873

# 设置 Verdaccio 环境变量
ENV VERDACCIO_APPDIR /verdaccio
ENV VERDACCIO_USER verdaccio
ENV VERDACCIO_PORT 4873
ENV VERDACCIO_PROTOCOL http
ENV VERDACCIO_STORAGE /usr/rn-plugin/storage
ENV VERDACCIO_PLUGINS /usr/rn-plugin/plugins
ENV VERDACCIO_LOG_FORMAT pretty
ENV VERDACCIO_LOG_LEVEL trace
ENV VERDACCIO_PUBLIC_URL https://www.example.com/verdaccio

ENTRYPOINT ["/usr/local/bin/verdaccio", "--config", "/verdaccio/conf/config.yaml", "--listen", "0.0.0.0:4873"]

```
## 宿主机权限设置：

```shell
sudo chown -R 10001:10001 /root/dd/storage /root/dd/plugins
```
