---
title: "BrowserGuard - 智能浏览器监控工具，助力家长控制与学习管理"
date: 2025-07-27T14:00:00+08:00
tags: ["Electron", "React", "TypeScript", "Parental Control", "Browser Monitoring", "Desktop App", "Cross Platform"]
featured: false
description: 为家庭电脑学习管理设计的智能浏览器监控工具。基于 Electron + React + TypeScript 技术栈开发，支持 macOS 和 Windows 双平台，通过实时监控浏览器访问行为，帮助家长和孩子建立健康的上网习惯。
---

## 项目概述

[BrowserGuard](https://github.com/ltanme/BrowserGuard) 是一款专为家庭电脑学习管理设计的智能浏览器监控工具。基于 Electron + React + TypeScript 技术栈开发，支持 macOS 和 Windows 双平台，通过实时监控浏览器访问行为，帮助家长和孩子建立健康的上网习惯。

## 核心功能特性

### 🎯 智能拦截系统
- **实时监控**：自动轮询规则接口，实时拦截游戏网站、短视频平台等娱乐内容
- **多浏览器支持**：兼容 Chrome、Edge、Safari、Firefox 等主流浏览器
- **时间规则**：支持按时间段设置不同的拦截规则，灵活配置学习/娱乐时段

### 🔒 安全保护机制
- **管理员密码保护**：仅管理员可退出应用，防止孩子绕过监控
- **开机自启**：macOS LaunchAgent/Windows 注册表自动启动
- **单实例运行**：确保系统只有一个监控实例在运行

### ⚙️ 灵活配置管理
- **规则热更新**：支持远程规则接口，新规则自动生效
- **本地配置**：密码和配置信息保存在本地，支持修改
- **日志调试**：详细的操作日志，便于问题排查

## 使用场景

### 👨‍👩‍👧‍👦 家庭学习管理
- **防沉迷控制**：在孩子学习时间自动拦截游戏网站
- **健康上网**：限制短视频、社交媒体等娱乐内容访问
- **时间管理**：通过时间段规则，培养良好的作息习惯

### 🏢 企业自律场景
- **工作专注**：在工作时间拦截娱乐网站，提高工作效率
- **网络安全**：防止访问恶意网站，保护企业数据安全
- **员工管理**：帮助员工建立健康的上网习惯

### 🎓 教育机构应用
- **机房管理**：在学校的电脑机房统一管理学生上网行为
- **学习环境**：为学生创造专注的学习环境
- **家长合作**：与家长共同监督孩子的上网行为

## 技术架构

### 技术栈
- **框架**：Electron (跨平台桌面应用)
- **前端**：React + TypeScript
- **构建**：Webpack + Electron Builder
- **部署**：GitHub Actions 自动化构建发布

### 核心模块
```
BrowserGuard/
├── src/
│   ├── main/           # 主进程代码
│   ├── renderer/       # 渲染进程 (React)
│   └── shared/         # 共享类型定义
├── scripts/            # 跨平台脚本
├── build/              # 构建配置
└── docs/              # 项目文档
```

## 安装与使用

### 快速开始

#### 1. 下载安装
访问 [GitHub Releases](https://github.com/ltanme/BrowserGuard/releases) 页面，下载适合你系统的安装包：
- **macOS**: `BrowserGuard-1.0.0-arm64.dmg`
- **Windows**: `BrowserGuard Setup 1.0.0-ia32.exe`

#### 2. 首次运行设置
1. 启动应用后自动显示首次运行设置界面
2. 设置管理员密码（默认为 `123456`）
3. 配置规则接口 URL
4. 设置自动重载间隔（10-300秒）
5. 点击"完成设置"进入主界面

#### 3. 权限授予
- **macOS**: 首次启动会自动弹出"辅助功能"设置面板，请勾选 BrowserGuard
- **Windows**: 需以管理员身份运行以便自动关闭浏览器进程

### 配置说明

#### 默认配置
- **管理员密码**: `123456`
- **规则接口**: `https://api.example.com/blocklist`
- **自动重载间隔**: 30秒
- **配置文件位置**:
  - macOS: `~/Library/Application Support/BrowserGuard/config.json`
  - Windows: `%APPDATA%\BrowserGuard\config.json`

#### 规则配置示例
```json
{
  "periods": [
    {
      "start": "08:00",
      "end": "12:00",
      "domains": [
        "poki.com",
        "4399.com",
        "douyin.com",
        "bilibili.com"
      ]
    },
    {
      "start": "14:00",
      "end": "18:00",
      "domains": [
        "youtube.com",
        "tiktok.com"
      ]
    }
  ]
}
```

## 界面功能

### 1. 管理员登录界面
首次启动或每次登录时，用户需输入管理员密码才能进入主界面。

### 2. Dashboard 主界面
登录后显示当前规则、拦截时间段、受限域名等信息，并可进入配置设置。

### 3. 规则配置窗口
可修改管理员密码、规则接口、自动重载间隔、调试模式等，支持热更新。

### 4. 检测到游戏网站自动关闭浏览器
当检测到访问受限网站时，自动关闭浏览器并显示提示信息。

### 5. 退出确认窗口
点击退出时需再次输入管理员密码确认，防止误操作。

## 开发与构建

### 本地开发
```bash
# 克隆仓库
git clone https://github.com/ltanme/BrowserGuard.git
cd BrowserGuard

# 安装依赖
npm install

# 开发模式
npm run dev
```

### 打包构建
```bash
# 快速打包所有平台
./build.sh

# 只打包 macOS
./build.sh --mac

# 只打包 Windows
./build.sh --win

# 查看帮助
./build.sh --help
```

### CI/CD 自动化
项目配置了 GitHub Actions 工作流，支持自动构建和发布：
- **标签触发**: `git tag v1.0.0 && git push origin v1.0.0`
- **手动触发**: 在 GitHub Actions 页面手动触发构建

## 项目特色

### 🌟 智能化设计
- **基于时间规则**：支持多个时间段和不同的域名组合
- **实时监控**：自动轮询规则接口，新规则立即生效
- **跨平台兼容**：Windows 和 macOS 分别处理配置文件路径

### 🔧 易用性
- **图形化界面**：直观的 Dashboard 界面，操作简单
- **一键安装**：提供 DMG 和 EXE 安装包，开箱即用
- **详细文档**：完整的使用说明和开发文档

### 🛡️ 安全性
- **密码保护**：管理员密码保护，防止未授权退出
- **日志记录**：详细的操作日志，便于审计和调试
- **权限控制**：系统级权限管理，确保监控有效性

## 总结

BrowserGuard 是一款功能完善、设计合理的家长控制工具，不仅适用于家庭学习管理，还可以扩展到企业自律和教育机构场景。通过智能的规则配置和实时监控，帮助用户建立健康的上网习惯，实现真正的"防沉迷"管理。

项目采用现代化的技术栈，具有良好的可扩展性和维护性，是开源社区中不可多得的优秀作品。

---

**项目地址**: [https://github.com/ltanme/BrowserGuard](https://github.com/ltanme/BrowserGuard)  
**技术栈**: Electron + React + TypeScript  
**支持平台**: macOS, Windows  
**开源协议**: MIT License 