# LTAN.ME - 个人技术博客

[![Hugo](https://img.shields.io/badge/Hugo-0.148.1+-blue.svg)](https://gohugo.io/)
[![Theme](https://img.shields.io/badge/Theme-Terminal-orange.svg)](https://github.com/panr/hugo-theme-terminal)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)
[![GitHub Pages](https://img.shields.io/badge/GitHub%20Pages-Deployed-success.svg)](https://ltan.me)

## 📖 项目简介

这是一个基于 [Hugo](https://gohugo.io/) 构建的个人技术博客，使用 [Terminal 主题](https://github.com/panr/hugo-theme-terminal)，部署在 GitHub Pages 上。博客专注于技术分享、开发经验和学习笔记。

**访问地址：** [https://ltan.me](https://ltan.me)

> 💡 **About the Author**: A tech enthusiast who treats life like debugging code, builds a "digital kingdom" in NAS, contemplates "life algorithms" while swimming, and scripts everything from groceries to daily routines with IT mindset.

## ✨ 主要特性

### 🎨 动态主题色彩
- **每日自动换色**：通过 GitHub Actions 每天自动更换主题颜色
- **支持颜色**：orange、blue、red、green、pink
- **智能算法**：基于日期生成，确保同一天颜色一致

### 📱 响应式设计
- 完美适配桌面端和移动端
- 现代化的终端风格界面
- 优雅的排版和布局

### 🏷️ 内容管理
- 支持标签分类和归档
- 自动生成站点地图
- SEO 友好的 URL 结构

### 💬 互动功能
- 集成 [Utteranc](https://utteranc.es/) 评论系统
- GitHub 风格的评论界面
- 支持 GitHub 账号登录

## 🛠️ 技术栈

- **静态站点生成器**：[Hugo](https://gohugo.io/) v0.148.1+
- **主题**：[Terminal](https://github.com/panr/hugo-theme-terminal)
- **部署平台**：[GitHub Pages](https://pages.github.com/)
- **自动化**：[GitHub Actions](https://github.com/features/actions)
- **评论系统**：[Utteranc](https://utteranc.es/)

## 📁 项目结构

```
ltanme.github.io/
├── content/                 # 博客文章内容
│   ├── post/               # 文章目录（按年/月组织）
│   ├── about.md            # 关于页面
│   └── tags/               # 标签页面
├── themes/                 # Hugo 主题
│   └── terminal/           # Terminal 主题文件
├── layouts/                # 自定义布局模板
├── docs/                   # 生成的静态文件（GitHub Pages）
├── .github/workflows/      # GitHub Actions 工作流
│   └── daily-color-change.yml  # 每日颜色更换
├── config.toml            # Hugo 配置文件
└── README.md              # 项目说明
```

## 🚀 快速开始

### 本地开发

1. **克隆仓库**
   ```bash
   git clone https://github.com/ltanme/ltanme.github.io.git
   cd ltanme.github.io
   ```

2. **安装 Hugo**
   ```bash
   # macOS
   brew install hugo
   
   # 验证安装
   hugo version
   ```

3. **本地预览**
   ```bash
   hugo server -D
   ```
   访问 [http://localhost:1313](http://localhost:1313)

### 创建新文章

```bash
# 创建文章目录
mkdir -p content/post/$(date +%Y)/$(date +%m)/your-article-title

# 创建文章文件
cat > content/post/$(date +%Y)/$(date +%m)/your-article-title/index.md << 'EOF'
---
title: "文章标题"
date: $(date -u +%Y-%m-%dT%H:%M:%S+08:00)
tags: ["标签1", "标签2"]
featured: false
---

## 介绍
在这里写文章介绍...

## 正文内容
在这里写正文内容...
EOF
```

## 🔧 配置说明

### 主要配置项

- **baseURL**: `https://ltan.me` - 网站域名
- **ThemeColor**: 动态颜色（每日自动更换）
- **CenterTheme**: `true` - 居中布局
- **ReadMore**: `"Read more"` - 阅读更多按钮文本

### 文章 Front Matter 格式

```yaml
---
title: "文章标题"
date: 2024-01-02T10:00:00+08:00
tags: ["Java", "Spring Boot", "Docker"]
featured: true  # 可选，是否置顶
---
```

## 🤖 自动化功能

### 每日颜色更换

通过 GitHub Actions 实现每日自动更换主题颜色：

- **触发时间**：每天凌晨 2 点（UTC 时间）
- **支持手动触发**：可在 GitHub Actions 页面手动执行
- **颜色算法**：基于日期生成，确保同一天颜色一致

### 部署流程

1. GitHub Actions 自动构建 Hugo 站点
2. 生成静态文件到 `docs/` 目录
3. 自动提交到 GitHub Pages 分支
4. 几分钟内完成部署

## 📝 写作规范

### 文章路径规则
- 路径格式：`content/post/年份/月份/文章目录/`
- 目录命名：使用英文，kebab-case 格式
- 示例：`content/post/2024/01/solving-https-debugging-issues/`

### 图片存放规则
- **文章图片**：直接放在文章目录下，与 `index.md` 同级
- **全局图片**：放在 `docs/images/` 或 `docs/img/` 目录下
- **图片引用**：使用相对路径，如 `![](./image.png)`

### 标签规范
- 使用英文标签
- 标签用双引号包围
- 按重要性排序
- 常见标签：["Java", "Spring Boot", "Docker", "Python", "Linux", "Networking"]

## 🌐 部署信息

- **域名**：[https://ltan.me](https://ltan.me)
- **GitHub Pages**：[https://ltanme.github.io](https://ltanme.github.io)
- **部署方式**：GitHub Actions 自动部署
- **构建命令**：`hugo --baseURL="https://ltan.me"`

## 📊 统计信息

- **文章数量**：297 篇
- **标签数量**：100+ 个
- **分页设置**：每页 5 篇文章
- **构建时间**：约 140ms

## 🤝 贡献指南

欢迎提交 Issue 和 Pull Request！

1. Fork 本仓库
2. 创建特性分支：`git checkout -b feature/your-feature`
3. 提交更改：`git commit -am 'Add some feature'`
4. 推送分支：`git push origin feature/your-feature`
5. 提交 Pull Request

## 📄 许可证

本项目采用 MIT 许可证 - 查看 [LICENSE](LICENSE) 文件了解详情。

## 👨‍💻 作者

**SwimBytes** - [SwimBytes@ltan.me](mailto:SwimBytes@ltan.me)

---

⭐ 如果这个项目对你有帮助，请给它一个星标！