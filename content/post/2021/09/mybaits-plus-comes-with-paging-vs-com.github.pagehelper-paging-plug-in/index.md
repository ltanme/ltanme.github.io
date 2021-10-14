---
title: "Mybaits Plus Comes With Paging VS Com.github.pagehelper Paging Plug In"
date: 2021-09-27T16:49:31+08:00
draft: false
tags: ["Mybaits Plus","com.github.pagehelper","java"]
---

# mybatis-plus 自带分页 和 com.github.pagehelper工具使用对比

> 对经常写中台列表数据管理接口的同学来说，需要经常使用到分页插件来提升自己的工作效率，通常我用过最多的两款插件如标题所示，这两款插件在写文章之前，我一直搞不清，浮躁，混为一谈，需要总结整理
>
> 今抽空花些时间来比较一下他们在返回`response body` 时内容, 观察到`pagehelper`不愧是术业有专攻啊，个人认为`pagehelper` 作为专业分页插件不得不说，其功能特点比`mybatis-plus` 完善多了，考虑到人性化，由期在前后端对接方面，大大提升了效率，少写很多代码，不过有时还是看需求场景，对于不需要web端展示的，我推荐`mybatis-plus 自带的page分页` ,它相比`pagehelper`插件提供的能力还是比较简单，比如没有提供`页码位置`，`前一页`，`后一页`

## mybatis-plus page 

以下为mybatis-plus 分页插件在返回data数据 结构如下

```json
{
        "records": [
           .....		
        ],
        "total": 7,
        "size": 10,
        "current": 1,
        "orders": [],
        "searchCount": true,
        "pages": 1
    }
```

代码使用：

```java
   @GetMapping("/list")
   public Object pageList(@RequestParam(defaultValue = "1") Integer pageNum,
                          @RequestParam(defaultValue = "10") Integer pageSize) {
	  QueryWrapper<xxModel> queryWrapper = new QueryWrapper<>();
      Page<xxModel> page = new Page<>(pageNum, pageSize); 
      IPage<xxModel> list = xxService.page(page, queryWrapper);
      return list
}

```





## pagehelper 

以下为pagehelper 的返回data数据，结构如下

```json
{
        "total": 0,
        "list": [
            .....
        ],
        "pageNum": 1,
        "pageSize": 10,
        "size": 0,
        "startRow": 0,
        "endRow": 0,
        "pages": 0,
        "prePage": 0,
        "nextPage": 0,
        "isFirstPage": true,
        "isLastPage": true,
        "hasPreviousPage": false,
        "hasNextPage": false,
        "navigatePages": 8,
        "navigatepageNums": [],
        "navigateFirstPage": 0,
        "navigateLastPage": 0
}
```

web前端对接时看到有 prePage，nextPage 实现太香，不要不要的

![image-20210927173234110](image-20210927173234110.png)

代码使用：

```
 @GetMapping("/list")
   public Object pageList(@RequestParam(defaultValue = "1") Integer pageNum,
                          @RequestParam(defaultValue = "10") Integer pageSize) {
      QueryWrapper<xxModel> queryWrapper = new QueryWrapper<>();
      PageHelper.startPage(pageNum, pageSize); 
	  List<xxModel> list = xxService.list(queryWrapper);
      return new PageInfo<>(list)
}
```

最后总结：

​     推荐大家按需求选自己最合适的分页插件，当然两者可以整合一起使用。有冲突的话则排除冲突，用 mybatis-plus 则重点在mybatis `dao`,`service`,`mapper` ，常见sql可以不写xml,不写service，除非特别的连表查询sql语句，而`pagehelper` 则重点在于分页，分页功能强大无敌，对于需要web前端分页的小伙伴，它可以帮你节省不少时间，另外对我当前使用的mybatis-plus 在默认的情况下，`mybatis-plus total 为0的问题`， 为了解决total字段为0的问题，百度,google搜索一大把关于它的文章，解决方法。还有个坑就是`mybatis-plus的分页，单页查询默认为500条限制`