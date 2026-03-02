---
title: "OpenClaw 部署踩坑记录：从装起来到跑通"
date: 2026-03-01
draft: false
tags: ["OpenClaw", "Docker", "Ollama", "代理", "故障排查"]
categories: ["AI 工具", "部署记录"]
description: "记录 OpenClaw 部署和使用过程中的实际问题：依赖安装、配置文件、代理连接、端口冲突和模型配置不一致，并附可直接复用的解决命令。"
---

这篇是纯排错笔记，按我实际踩坑顺序记，省得下次重装再走一遍。

## 环境

- Ubuntu 22.04
- Docker 26.x + Docker Compose v2
- Python 3.11
- Ollama 0.6.x

## 依赖安装直接炸了：`tokenizers` 编译失败

第一次装依赖就报错：

```text
error: subprocess-exited-with-error
× Building wheel for tokenizers (pyproject.toml) did not run successfully.
error: can't find Rust compiler
```

问题很直接，机器里没 Rust 工具链，`tokenizers` 需要编译。

解决：

```bash
sudo apt-get update
sudo apt-get install -y build-essential python3-dev rustc cargo

python3 -m venv .venv
source .venv/bin/activate
pip install -U pip setuptools wheel
pip install -r requirements.txt
```

![依赖安装报错截图](dependency-error.png)

## 配置文件路径不对：启动就 `FileNotFoundError`

服务启动后马上退出：

```text
FileNotFoundError: [Errno 2] No such file or directory: './config/config.yaml'
```

我最开始是从项目根目录外面调用启动脚本，导致相对路径全错。

处理方式：

```bash
cp config/config.example.yaml config/config.yaml
export OPENCLAW_CONFIG=$(pwd)/config/config.yaml
python app.py
```

如果是 systemd 跑，建议写死环境变量，别吃当前目录：

```ini
Environment=OPENCLAW_CONFIG=/opt/openclaw/config/config.yaml
WorkingDirectory=/opt/openclaw
```

## 网络代理没配干净：模型下载一直超时

报错长这样：

```text
requests.exceptions.ConnectTimeout:
HTTPSConnectionPool(host='huggingface.co', port=443): Max retries exceeded
```

只配了 `HTTP_PROXY` 不够，`HTTPS_PROXY` 和 `NO_PROXY` 也要一起配，不然内网地址也会被代理走，接口偶发超时。

```bash
export HTTP_PROXY=http://127.0.0.1:7890
export HTTPS_PROXY=http://127.0.0.1:7890
export NO_PROXY=localhost,127.0.0.1,::1,ollama,redis,postgres
```

另外国内网络下我加了 HF 镜像，不然拉模型很慢：

```bash
export HF_ENDPOINT=https://hf-mirror.com
```

![网络超时截图](network-timeout.png)

## Docker 端口冲突：`port is already allocated`

`docker compose up -d` 直接失败：

```text
Error response from daemon:
driver failed programming external connectivity on endpoint openclaw-web
Bind for 0.0.0.0:3000 failed: port is already allocated
```

查了一下是本机另一个前端服务占了 `3000`。

```bash
sudo lsof -i :3000
```

我这里直接改 compose 映射，避免互相抢端口：

```yaml
services:
  web:
    ports:
      - "3300:3000"
```

改完重建：

```bash
docker compose down
docker compose up -d --build
```

## 模型配置写错：OpenClaw 调不到 Ollama 模型

调用时报错：

```text
404 model "qwen2.5:14b-instruct" not found, try pulling it first
```

原因是 `config.yaml` 里写的模型名和 `ollama list` 里的实际 tag 不一致。

先看本地模型：

```bash
ollama list
```

没有就拉：

```bash
ollama pull qwen2.5:14b
```

然后把 OpenClaw 配置改成一致的名字：

```yaml
llm:
  provider: ollama
  base_url: http://ollama:11434
  model: qwen2.5:14b
```

这一步改完，接口就能正常返回了。

![模型配置截图](model-config.png)

## 一个省事的自检清单

每次部署前我现在都跑下面这几条，能省很多时间：

```bash
python -V
docker compose ps
ollama list
curl -s http://127.0.0.1:11434/api/tags | jq '.models[].name'
env | grep -Ei 'proxy|hf_endpoint|openclaw_config'
```

如果你也在折腾 OpenClaw，优先检查三件事：配置路径、代理变量、模型名。十次里有八次是这三个地方出问题。
