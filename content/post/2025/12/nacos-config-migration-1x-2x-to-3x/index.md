---
title: "Nacos 配置迁移实战：一键把 Nacos 1.x/2.x 导出包转换为 3.0 导入包（Python Web 工具）"
date: 2025-08-31T17:30:00+08:00
draft: false
tags: ["Nacos", "Spring Cloud", "配置中心", "Python", "Flask"]
categories: ["Java 后端", "配置与发布"]
description: "在不修改 Nacos 1.x/2.x 原始导出包内容的前提下，使用一个极简 Python + Flask Web 小工具，把旧版导出 zip 自动转换为符合 Nacos 3.0 导入要求的 zip（自动生成 .metadata.yml、推断配置类型、保留原目录结构、支持浏览器一点完成转换）。"
-----------------------------------------------------------------------------------------------------------------------------------------------------------------

> 本文记录一个**把 Nacos 1.x / 2.x 导出的配置包，自动转换为 Nacos 3.0 可直接导入包**的完整思路和工具实现。
> 核心思路：**不改动原导出包内容，只在外层补一层 Nacos 3.0 需要的 `.metadata.yml`**，并保留所有原始配置文件与目录结构。
> 配套工具使用 **Python 3 + Flask**，通过浏览器上传旧 zip，自动生成 `nacos3.0.zip` 下载，适合日常运维和批量迁移配置时使用。

---

## 0. 迁移目标概览

从配置中心视角，这次迁移的目标可以简化成一句话：
操作如下图
![show.png](show.png)
> **把 Nacos 1.x / 2.x 导出的 zip 包，变成 Nacos 3.0 认为“官方合法”的导入包。**

更具体一点：

* **输入**：旧版 Nacos 导出的 zip（一般是 1.x / 2.x 导出的配置）

    * 结构示例：

      ```text
      export.zip
      └── ADMIN/
          ├── datasource.yml
          ├── homepage-api-logging.json
          └── xxx
      ```
* **输出**：Nacos 3.0 可直接导入的 zip：

  ```text
  nacos3.0.zip
  ├── ADMIN/
  │   ├── datasource.yml
  │   ├── homepage-api-logging.json
  │   └── xxx
  └── .metadata.yml
  ```

其中 **`.metadata.yml` 是 Nacos 3.0 新增的关键文件**，用于描述：

* dataId
* group
* type（yaml / properties / xml / …）
* appName、desc 等元信息

本文的 Python Web 工具就是用来**自动生成这一层 `.metadata.yml`，并重新打包 zip**。

---

## 1. Nacos 1.x/2.x vs Nacos 3.0：导入/导出格式差异

### 1.1 旧版导出包的典型结构

在 Nacos 1.x / 2.x 中，导出配置通常只包含：

* 若干“命名空间/Group 目录”（如 `ADMIN`、`DEFAULT_GROUP`）
* 每个目录下面是一个个 dataId 对应的文件

示例结构：

```text
ADMIN/
├── application.yml
├── homepage-api-logging.json
└── mq-config
```

Nacos 旧版本通过**目录名 + 文件名 + 扩展名**来推断：

* group（目录名）
* dataId（文件名）
* type（后缀 + 人工选择）

导入时，后台有没有 `.metadata.yml` 这一层概念。

---

### 1.2 Nacos 3.0 导入包的要求

在 Nacos 3.0 中，导入 zip 时要求：

* zip 根目录下必须有一个 **`.metadata.yml`**
* 里面列出所有要导入的配置项，每一条包含：

    * dataId
    * group
    * type
    * appName
    * desc 等

示例 `.metadata.yml`：

```yaml
metadata:
  - appName: ''
    dataId: datasource.yml
    desc: ''
    group: ADMIN
    type: yaml
  - appName: ''
    dataId: homepage-api-logging.json
    desc: ''
    group: ADMIN
    type: yaml
```

如果没有 `.metadata.yml`，或者格式不符合要求，Nacos 3.0 会直接拒绝导入。

> 迁移的本质：**给旧导出包“补一张目录表”——`.metadata.yml`。**

---

## 2. 设计一个“小而美”的转换工具

### 2.1 设计目标

这次工具的设计目标非常务实：

1. **不污染原始导出包**

    * 不修改旧 zip 里的任何文件；转换过程全部在临时目录完成。
2. **只做“结构和 metadata”层面的处理**

    * 不解析配置内容，不关心 YAML/JSON 内部语义，只是补一个 `.metadata.yml`。
3. **通过浏览器操作**

    * Flask 起一个本地 Web 服务，后端接受 zip，后端返回新的 `nacos3.0.zip`。
4. **足够简单**

    * 依赖只有：`flask` + Python 标准库。

---

### 2.2 文件类型推断策略（_guess_type）

Nacos 3.0 导入时要求每条 metadata 声明 `type`。但实际环境中：

* 很多配置是 **无后缀**，但实际写的是 YAML
* 还有 `.json` 文件，但实际 Nacos 中 type 选择的是 `yaml`

所以在这个工具里，采用了一个**偏保守且更贴近当前使用场景**的策略：

* 以 `.yml/.yaml` 结尾 → `yaml`
* 以 `.json` 结尾 → **也一律当 `yaml` 处理**（与你当前使用习惯一致）
* `.xml` → `xml`
* `.properties` → `properties`
* 其他后缀 / 无后缀 → 默认 `yaml`

后续如果你公司内部对 JSON / YAML 区分更严格，只需要改一行：

```python
if fname_lower.endswith(".json"):
    return "json"
```

即可。

---

## 3. Web 转换工具完整代码

> 原代码 Gist：[https://gist.github.com/ltanme/8d20b61b891fbbcef8595609d720ccb2](https://gist.github.com/ltanme/8d20b61b891fbbcef8595609d720ccb2)

将下面代码保存为：**`nacos_web_converter.py`**（文件名随意，方便自己记就行）
```shell
1) pip install flask
2) python nacos_web_converter.py
3) 浏览器打开 http://127.0.0.1:8000
4) 选择 nacos 导出 zip 文件，点击“上传并转换”，浏览器会下载 nacos3.0.zip

```

```python
#!/usr/bin/env python3
# -*- coding: utf-8 -*-

"""
简单的 Nacos 1.x / 2.x → Nacos 3.x 导入包转换 Web 工具

使用：
    1) pip install flask
    2) python nacos_web_converter.py
    3) 浏览器打开 http://127.0.0.1:8000
    4) 选择 nacos 导出 zip 文件，点击“上传并转换”，浏览器会下载 nacos3.0.zip
"""

import os
import io
import shutil
import tempfile
import zipfile

from flask import Flask, request, send_file, render_template_string

app = Flask(__name__)

# 简单页面模板
INDEX_HTML = """
<!doctype html>
<html lang="zh-CN">
<head>
  <meta charset="utf-8">
  <title>Nacos 1.x / 2.x → 3.x 转换工具</title>
</head>
<body style="font-family: sans-serif; padding: 20px;">
  <h2>Nacos 1.x / 2.x 导出包 转换为 Nacos 3.x 导入包</h2>
  <form method="POST" action="/convert" enctype="multipart/form-data">
    <p>
      <label>选择 Nacos 导出的 zip 文件：</label>
      <input type="file" name="file" accept=".zip" required>
    </p>
    <button type="submit">上传并转换为 nacos3.0.zip</button>
  </form>
</body>
</html>
"""


@app.route("/", methods=["GET"])
def index():
    return render_template_string(INDEX_HTML)


def _detect_group_dir(root_dir: str) -> str:
    """在解压出来的根目录下面找 group 目录，比如 ADMIN"""
    for name in os.listdir(root_dir):
        path = os.path.join(root_dir, name)
        if os.path.isdir(path) and not name.startswith("."):
            return name
    raise RuntimeError("未在导出包中找到命名空间目录（例如 ADMIN）")


def _guess_type(fname: str) -> str:
    """
    根据扩展名粗略猜测 Nacos 配置类型

    注意：
    - 你当前环境很多无后缀 / .json 实际也是 yaml，我们这里保守一点：
      默认类型一律视为 yaml，只有少数常见扩展单独标注
    """
    fname_lower = fname.lower()
    if fname_lower.endswith((".yml", ".yaml")):
        return "yaml"
    if fname_lower.endswith(".json"):
        # 你给的例子里 homepage-api-logging.json 也是 type: yaml
        # 如果你以后真有严格要求，可以把这里改成 "json"
        return "yaml"
    if fname_lower.endswith(".xml"):
        return "xml"
    if fname_lower.endswith(".properties"):
        return "properties"
    # 没有后缀 / 其他后缀，一律按 yaml 处理（符合你现在的使用场景）
    return "yaml"


def _build_metadata_yaml(group_name: str, group_dir: str) -> str:
    """
    生成 .metadata.yml 内容（字符串），符合 Nacos 3.x 要求：

    metadata:
      - appName: ''
        dataId: xxx
        desc: ''
        group: XXX
        type: yaml
    """
    lines = []
    lines.append("metadata:")
    for fname in sorted(os.listdir(group_dir)):
        if fname.startswith("."):
            continue
        full_path = os.path.join(group_dir, fname)
        if not os.path.isfile(full_path):
            continue

        cfg_type = _guess_type(fname)

        lines.append(f"  - appName: ''")
        lines.append(f"    dataId: {fname}")
        lines.append(f"    desc: ''")
        lines.append(f"    group: {group_name}")
        lines.append(f"    type: {cfg_type}")

    return "\n".join(lines) + "\n"



@app.route("/convert", methods=["POST"])
def convert():
    file = request.files.get("file")
    if not file:
        return "未收到上传文件", 400
    if not file.filename.lower().endswith(".zip"):
        return "只支持 zip 文件", 400

    # 创建临时目录
    work_dir = tempfile.mkdtemp(prefix="nacos2_")
    out_dir = tempfile.mkdtemp(prefix="nacos3_")

    try:
        # 把上传的 zip 保存到临时文件
        src_zip_path = os.path.join(work_dir, "nacos2.zip")
        file.save(src_zip_path)

        # 解压 Nacos 2.0 导出包
        with zipfile.ZipFile(src_zip_path, "r") as zf:
            zf.extractall(work_dir)

        # 检测命名空间目录（例如 ADMIN）
        group_name = _detect_group_dir(work_dir)
        group_src_dir = os.path.join(work_dir, group_name)

        # 输出目录结构： out_dir 下也放一个同名目录 + .metadata.yml
        group_out_dir = os.path.join(out_dir, group_name)
        shutil.copytree(group_src_dir, group_out_dir)

        # 生成 metadata
        metadata_content = _build_metadata_yaml(group_name, group_src_dir)
        metadata_path = os.path.join(out_dir, ".metadata.yml")
        with open(metadata_path, "w", encoding="utf-8") as f:
            f.write(metadata_content)

        # 打包为内存中的 zip，返回给前端下载
        mem_zip = io.BytesIO()
        with zipfile.ZipFile(mem_zip, "w", zipfile.ZIP_DEFLATED) as zf:
            for root, _, files in os.walk(out_dir):
                for fname in files:
                    full_path = os.path.join(root, fname)
                    arcname = os.path.relpath(full_path, out_dir)
                    # 这里会把 .metadata.yml 一并打进 zip（根目录）
                    zf.write(full_path, arcname)
        mem_zip.seek(0)

        return send_file(
            mem_zip,
            mimetype="application/zip",
            as_attachment=True,
            download_name="nacos3.0.zip",
        )

    except Exception as e:
        return f"转换失败: {e}", 500
    finally:
        # 清理临时目录
        shutil.rmtree(work_dir, ignore_errors=True)
        shutil.rmtree(out_dir, ignore_errors=True)


if __name__ == "__main__":
    # host 改为 0.0.0.0 可以在局域网其他设备访问
    app.run(host="0.0.0.0", port=3000, debug=True)
```

---

## 4. 使用方式：本地起一个“转换小站”

### 4.1 安装依赖

建议在本地（或一台工具机）新建一个虚拟环境：

```bash
python3 -m venv venv
source venv/bin/activate

pip install flask
```

若是 Windows：

```bash
python -m venv venv
venv\Scripts\activate
pip install flask
```

---

### 4.2 启动服务

```bash
python nacos_web_converter.py
```

默认会监听：`http://127.0.0.1:3000`。

浏览器打开：

```text
http://127.0.0.1:3000
```

即可看到一个非常简单的页面：

* 文件选择框：选择旧 Nacos 导出 zip
* 按钮：**“上传并转换为 nacos3.0.zip”**

点击之后：

1. 后端接收 zip → 解压到临时目录
2. 自动检测命名空间目录（如 `ADMIN`）
3. 自动扫描目录下所有文件，推断 type
4. 生成 `.metadata.yml`
5. 压缩为 `nacos3.0.zip` 返回浏览器下载

下载好的 `nacos3.0.zip` 就可以直接去 **Nacos 3.0 后台 → 配置管理 → 导入** 使用。

---

## 5. 关键函数与“特点”拆解

### 5.1 `_detect_group_dir`：自动找命名空间目录

```python
def _detect_group_dir(root_dir: str) -> str:
    """在解压出来的根目录下面找 group 目录，比如 ADMIN"""
    for name in os.listdir(root_dir):
        path = os.path.join(root_dir, name)
        if os.path.isdir(path) and not name.startswith("."):
            return name
    raise RuntimeError("未在导出包中找到命名空间目录（例如 ADMIN）")
```

**背景：**

* 旧导出包一般会是：`export.zip → ADMIN/xxx` 这种结构
* 我们并不知道导出的 group 目录名是 `ADMIN`、`DEFAULT_GROUP` 还是别的

**特点：**

* 只要根目录下有一个**非隐藏的目录**，就认为它是“命名空间目录”
* 如果你有多命名空间的导出包，可以扩展为：返回一个列表，然后在 `.metadata.yml` 里遍历多个 group

---

### 5.2 `_guess_type`：类型推断的实际考量

```python
if fname_lower.endswith(".json"):
    return "yaml"
```

**背景：**

* 你给的实际导出例子里，`homepage-api-logging.json` 在 Nacos 中 type 也是 `yaml`
* 很多团队习惯用 `.json` 后缀写 YAML 格式（或者混合）

**特点：**

* 工具默认与**当前真实使用场景对齐**：只要对系统“看起来没问题”，就先全部按 yaml 导入
* 真正要严格区分的时候，你只需要改这一行就行

---

### 5.3 `_build_metadata_yaml`：一行行拼 `.metadata.yml`

```python
lines.append("metadata:")
for fname in sorted(os.listdir(group_dir)):
    ...
    lines.append(f"  - appName: ''")
    lines.append(f"    dataId: {fname}")
    lines.append(f"    desc: ''")
    lines.append(f"    group: {group_name}")
    lines.append(f"    type: {cfg_type}")
```

**特点：**

* 完全按照 Nacos 3.x 官方导出格式构造
* 只关注最关键的字段：

    * dataId：文件名
    * group：目录名
    * type：从文件名推断
* appName、desc 暂时留空，后续如果你要做更精细的管理，可以再做二次加工

---

### 5.4 `convert()`：整体流程编排

```python
# 1. 把上传 zip 落到 work_dir
# 2. 解压
# 3. 找 group 目录
# 4. 复制到 out_dir 中
# 5. 生成 .metadata.yml
# 6. 打包 out_dir 为内存中的 zip → send_file() 返回
# 7. finally 里彻底清理临时目录
```

**特点：**

* 使用 `tempfile.mkdtemp()` 为每次请求生成独立临时目录
* 最终打包时用 `io.BytesIO()` 在内存中构建 zip，不在磁盘上残留
* `finally` 里无论成功失败，都会清理临时目录，避免堆积

---

## 6. 工具的优点与适用场景

### 6.1 优点概览

* ✅ **完全不动原始导出包内容**
* ✅ **“无状态”服务**：每次请求都是一次性临时目录，适合扔到工具机 / CI 环境跑
* ✅ **操作门槛低**：运维同学打开浏览器就能用
* ✅ **业务无侵入**：脚本仅处理目录 + metadata，不碰配置具体内容
* ✅ **可扩展性好**：想支持多命名空间、多 group，只需要在 `_detect_group_dir` 和 `_build_metadata_yaml` 上做轻量改造就行

---

### 6.2 适合的使用场景

* 从老 Nacos 1.4.x / 2.x 平滑迁移到 Nacos 3.0
* 多个环境（dev / beta / prod）都有导出包，需要批量转换
* 不希望开发同学挨个点点点手工导入，而是给一个统一工具

---

## 7. 后续扩展方向（可以慢慢加）

如果你后面有精力，可以基于这版小工具继续迭代，例如：

1. **多命名空间支持**

    * 导出包里可能包含多个命名空间目录
    * 可从 `_detect_group_dir` 改为 `_detect_group_dirs`，遍历多个目录生成多组 metadata

2. **appName / desc 自动填充**

    * 比如：

        * 从文件名前缀推断 appName
        * 从某个约定的注释 / YAML 字段中提取 desc

3. **命令行模式**

    * 除了 Web 版，再加一个 CLI：

      ```bash
      python nacos_web_converter.py --input old.zip --output nacos3.0.zip
      ```
    * 方便脚本批量处理

4. **打成 Docker 镜像**

    * 一条命令起一个临时转换服务：

      ```bash
      docker run -p 3000:3000 your-org/nacos-web-converter
      ```

---