---
title: "My Python2.7 Notes"
date: 2021-07-21T20:43:52+08:00
draft: false
tags: ["python2.7","sql where in","stream grouping by"]
---

# python 日常笔记

> 记录工作要用的python 使用工具，或者常用的代码片段。 Python 是一种解释型语言： 这意味着开发过程中没有了编译这个环节。类似于PHP和Perl语言。Python 是交互式语言： 这意味着，您可以在一个 Python 提示符 >>> 后直接执行代码。Python 是面向对象语言: 这意味着Python支持面向对象的风格或代码封装在对象的编程技术。Python 是初学者的语言：Python 对初级程序员而言，是一种伟大的语言，它支持广泛的应用程序开发，从简单的文字处理到 WWW 浏览器再到游戏。

### 时间转换

```python
from datetime import *
import time
date_time = datetime.fromtimestamp(long("1528797322"))
print date_time.strftime("%Y-%m-%d, %H:%M:%S")
 
 
import datetime
date1 = time.strptime("2019-12-11 09:35:10", "%Y-%m-%d %H:%M:%S")
a = datetime.datetime(date1[0],date1[1],date1[2],date1[3],date1[4],date1[5])
 
 
strftime = datetime.datetime.strptime("2017-11-02 09:31:10", "%Y-%m-%d %H:%M:%S")
strftime2 = datetime.datetime.strptime("2017-11-02 09:30:10", "%Y-%m-%d %H:%M:%S")
print("32",strftime>strftime2)
 
 
from datetime import *
import time
print datetime.now().timetuple()
print time.mktime(datetime.now().timetuple())
 
 
import datetime
import time
date1 = time.strptime("2019-12-11 09:35:10", "%Y-%m-%d %H:%M:%S")
print long(time.mktime(date1) * 1000)
```

### where in mysql 使用 

```python
def get_config_list(conn, cur, aid, keys):
 sql = "select `key`,label from config where id = %s and `key` in (%s) " % (
    aid, ','.join(['%s'] * len(keys)))
    cur.execute(sql, keys)
    data = cur.fetchall()
    return data
```

### 实现类似java stream grouping by to map 效果

```python
clist = get_config_list(conn, cur,item["id"],keys)
print clist
clist = {v['key']:v['label'] for i, v in enumerate(clist)}
print clist
```

### 三目表达式应用

```python
device["size"] = clist["ram_size"] if clist["ram_size"] == None else ""
 
device["reso"] = clist["resolution"] if clist["resolution"] == None else ""
 
device["viseo"] = clist["content_source"] if clist["content_source"] == None else ""
 
device["sourname"] = clist["source"] if clist["source"] == None else ""
 
device["brad"] = clist["brand"] if clist["brand"] == None else ""
```

### 批量插入mysql

```python
c.executemany( """INSERT INTO breakfast (name, spam, eggs, sausage, price) VALUES (%s, %s, %s, %s, %s)""", [ ("Spam and Sausage Lover's Plate", 5, 1, 8, 7.95 ), ("Not So Much Spam Plate", 3, 2, 0, 3.95 ), ("Don't Wany ANY SPAM! Plate", 0, 4, 3, 5.95 ) ] )
#so in your case:
c.executemany("insert into T (F1,F2) values (%s, %s)", [('a','b'),('c','d')])
```

