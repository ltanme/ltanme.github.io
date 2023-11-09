---
title: "Date and LocalDatetime in Java 8"
date: 2021-09-26T21:08:19+08:00
draft: false
tags: ["Java8","LocalDateTime"]
---

# Java 8中的 Date和LocalDateTime类在工作中遇到的问题

> java 8 中的 LocalDateTime  比 date 速度快很多，而且在处理时间方法比较灵活，在日期计算方面，日期比较简单易用，而Date 要繁琐很多
>
> 我在工作中遇到一个实体类`创建时间`字段原来为Date类型， 在ｍｙｂａｔｉｓ　时间创建数据库记录时，需要用到自动填充当前时间为创建时间，
>
> ```java
> @TableField(fill = FieldFill.INSERT_UPDATE)
> private Date lastUpdateTime;
> ```
>
> 发现报错如下具体原因是因为`Date`在转换 `LocalDateTime.now()`出问题了，报错误不匹配

```json
{

  "timestamp": "2021-09-26T13:17:55.034+0000",

  "status": 500,

  "error": "Internal Server Error",

  "message": "nested exception is org.apache.ibatis.reflection.ReflectionException: Could not set property 'createTime' of 'class com.company.device.control.api.model.Command' with value '2021-09-26T21:17:54.966' Cause: java.lang.IllegalArgumentException: argument type mismatch",

  "path": "/comm/add"

}
```

是我用了mybatis自动填充, 也就是自动转换，但类型不一样，所以导致错误

```java
public class MybatisObjectHandler implements MetaObjectHandler {
    @Override
    public void insertFill(MetaObject metaObject) {
        setFieldValByName("createTime", LocalDateTime.now(), metaObject);
        setFieldValByName("updateTime", LocalDateTime.now(), metaObject);
    }

    @Override
    public void updateFill(MetaObject metaObject) {
        //更新时 需要填充字段
        setFieldValByName("updateTime", LocalDateTime.now(), metaObject);
    }
}
```

解决方法为，把原来自动用mybatis gen tool 生成的实体类类型字段，手动改成LocalDateTime 即可,如下

```java
@TableField(fill = FieldFill.INSERT_UPDATE)
private LocalDateTime lastUpdateTime;
```

