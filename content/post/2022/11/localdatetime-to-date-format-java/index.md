---
title: "Localdatetime to Date Format Java"
date: 2022-11-28T16:05:03+08:00
draft: true
tags: ["java","localdatetime","localdate"]
---
# Localdatetime to Date Format Java

> 在使用`java`时间的`api`个人感觉非常不方便，很多时候存在格式转换，类型转换 比如`date` 转`localDate`
> `localDateTime`转换为 `Date` 等这种操作，二者的相互转换并不是一步到位哪么简单的，所以，还是在
> 这里记录一下转换的`api`备忘一下, `localDate`只处理`yyyyMMdd`格式，`localTime`只处理`HHmmss`格式,而
> `localDateTime` 可以处理 `yyyy-MM-dd HH:mm:ss`

## Date to LocalDateTime
```java
    Date date = new Date(); 
    LocalDateTime ldt = date.toInstant()
            .atZone(ZoneId.systemDefault() )
            .toLocalDateTime(); 
```

## LocalDateTime to Date

```java
   LocalDateTime date = LocalDateTime.now(); 
   Date date = Date.from( localDateTime.atZone( ZoneId.systemDefault()).toInstant());
```

## 生成时间序列
```java 
   public static List<Date> getDayList(String startDate, int gap) {
      String pattern = "yyyy-MM-dd HH:mm:ss";
      DateTimeFormatter dateFormat = DateTimeFormatter.ofPattern(pattern); 
      // 生成年月日的日期序列
      List<Date> res = new ArrayList<>(); 
      for (int i = 0; i < gap; i++) {
         LocalDateTime newDate = LocalDateTime.parse(startDate, dateFormat).plusDays(i);
         Date date = Date.from(newDate.atZone(ZoneId.systemDefault()).toInstant());
         res.add(date);
      }
      return res;
   }
   //调用
      String startDate = "2022-11-01 01:01:11";
      int gap = 30;
      List<Date> dayList = getDayList(startDate, gap);
      SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");
      
      dayList.forEach(item -> {
         String luanar = testLuanars(item); //输出农历
         String format = sdf.format(item);
         System.out.println(format + "=======" + luanar);
      });
```
