---
title: "Cursor + Bruno + IntelliJ IDEA 2025：自动扫 Controller、生成接口请求、一键运行的爽感工作流"
date: 2025-12-10T10:00:00+08:00
draft: false
featured: true
tags: ["Cursor", "Bruno", "IntelliJ IDEA", "Java", "API 自动化", "开发提效"]
categories: ["工具实践", "开发流程"]
description: "把 Cursor 拉来帮 IntelliJ 读 Controller，再让 Bruno 自动接收生成的接口请求文件，最终实现 Java 后端接口从代码到调试的一整套自动化流程。写完就能跑，完全不用手工敲请求，爽到飞起。"
---


---

# **借助 Cursor 与 Bruno：从 IntelliJ IDEA 2025.1.2 Java Controller 自动生成接口请求并一键运行**

最近搞 Java 接口开发的时候，越写越觉得：
**能不能让我写完接口之后，不用手动去 Postman / Bruno 里一个个敲接口、拼参数、调试半天？**

废话少说，先上图
![cursor.png](cursor.png)
>
![bruno.png](bruno.png)


然后我就开始折腾 Cursor，再把 Bruno 拉进来，结果还真把这一套自动化流程搞顺了。
现在就是：

✨ **写完 Controller → Cursor 自动读取接口 → 自动生成 .bru 文件 → Bruno 里一键运行**

舒服，真的舒服得不行。

下面我就来分享一下我这套“偷懒工作流”，反正我自己用了之后已经回不去了。

---

## 🛠 使用的工具

### **1. IntelliJ IDEA 2025.1.2 Ultimate**

平时写 Java 后端 Controller 的家伙式，主要就是提供 URL 和参数的信息来源。

### **2. Cursor**

这玩意简直就是高级码农小弟，让它去读代码、找 Controller、提取 URL、识别参数，都很稳。
还可以顺手把 `.bru` 文件写好存到 Bruno 目录。

### **3. Bruno**

一个基于文件系统的接口调试工具，特别适合跟 Cursor 搭配，因为
**Cursor 直接能往 Bruno 的文件夹里生成 .bru 接口文件**
你只要点一下就能运行，简直像外挂。

---

## 🧩 整体流程长这样

1. **在 IntelliJ 写好 Java Controller**
2. 用 Cursor 对项目说一句类似：

   > 帮我扫描 controller 包，提取所有 @RequestMapping / @GetMapping / @PostMapping 的接口
3. Cursor 自动生成 `.bru` 文件
4. Cursor 把这些 `.bru` 文件扔到 Bruno 的接口目录（比如 `/bruno/api`）
5. 我打开 Bruno，接口全都躺在那里
6. 点一下就能跑

---

## 🔥 我示例用的 Java Controller

为了方便展示，我就放一个简单的例子：

```java
@RestController
@RequestMapping("/api/user")
public class UserController {

    @GetMapping("/info")
    public UserInfo getUserInfo(@RequestParam String userId) {
        return new UserInfo(userId, "Tom", 25);
    }

    @PostMapping("/create")
    public Result createUser(@RequestBody CreateUserRequest req) {
        return new Result("ok", req.getName());
    }
}
```

Cursor 就是读取这种代码，自动提取：

* URL：`/api/user/info`
* 参数：`userId`
* method：GET
  等等信息。

---

## 🧪 Cursor 帮我生成的 `.bru` 示例

下面给你看 Cursor 自动生成的 Bruno 文件大概长啥样。

### `user-info.bru`

```
meta {
  name: "Get User Info"
  type: http
}

request {
  method: GET
  url: http://localhost:8080/api/user/info
  params {
    userId: "123"
  }
}
```

### `user-create.bru`

```
meta {
  name: "Create User"
  type: http
}

request {
  method: POST
  url: http://localhost:8080/api/user/create
  body: json({
    "name": "Tom",
    "age": 25
  })
}
```

然后 Cursor 会自动把它们写到：

```
/bruno/api/user-info.bru
/bruno/api/user-create.bru
```

打开 Bruno 左边就能看到两个接口，点运行即可。

---

## 🎯 Cursor Prompt（你可以直接用）

给 Cursor 一句话，它就能帮你自动扫 Controller + 自动生成 bru 文件：

```
帮我扫描 src/main/java 下所有 Controller 类，读取 @RequestMapping、@GetMapping、@PostMapping，并生成对应的 Bruno .bru 文件。

规则：
- 文件名采用 {controller-name}-{method-name}.bru
- GET 用 params
- POST/PUT 用 json body
- 自动生成基础示例参数
- 输出到项目根目录的 /bruno/api/
```

Cursor 会乖乖照做。

---

## 🍺 用下来是什么体验？

一句话：
**爽到飞起。**

以前写接口要开工具 → 手动补 URL → 补参数 → 补 body → 保存 → 运行……
现在写完 Controller 一句话让 Cursor 帮我生成，Bruno 里自动出现接口，点一下就能跑。

而且文件式接口存储真的太适合自动化了。

---

## 📁 Bruno 目录结构（我现在是这样）

```
bruno/
 └── api/
      ├── user-info.bru
      ├── user-create.bru
      └── ...
```

只要 Cursor 往这里丢文件，Bruno 就能自动识别。

---
