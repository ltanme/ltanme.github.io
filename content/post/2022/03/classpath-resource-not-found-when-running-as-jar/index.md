---
title: "Classpath Resource Not Found When Running as Jar"
date: 2022-03-08T09:45:39+08:00
draft: true
tags: ["java","springboot","groovy"]
---
#  读取jar包resources目录下的groovy脚本并调用
> 工作需要，需要采集不同的日志项，每个日志项的参数不一样，判断验证需要根据业务需求判断
> 所以采用生成groovy脚本形式来解决动态校验以及入库规则
> 项目初期设计不复杂，功能简单，直接按日志项名称编写groovy脚本规则
> groovy文件放在resources/logTemplate文件夹下，遇到在jar包模式运行不能读到文件的问题
> 而在idea能直接运行
> java -jar xxx.jar 运行报错如下
```java
 Caused by: java.lang.IllegalArgumentException: URI is not hierarchical
```
# 解决方法，通过jar包运行时，不能以文件形式读取jar包里的内容，参考google方法整理有如下几种方法解决
> 第一种方法 Using IOUtils.toString (Apache Utils)
```java
String result = IOUtils.toString(inputStream, StandardCharsets.UTF_8);
```
> 第二种方法 Using CharStreams (Guava)
```java
 String result = CharStreams.toString(new InputStreamReader(
       inputStream, Charsets.UTF_8));
```
> 第三种方法 Using Scanner (JDK)
```java
 Scanner s = new Scanner(inputStream).useDelimiter("\\A");
 String result = s.hasNext() ? s.next() : "";
```
> 第四种方法 Using Stream API (Java 8). Warning: This solution converts different line breaks (like \r\n) to \n.
```java
 String result = new BufferedReader(new InputStreamReader(inputStream))
   .lines().collect(Collectors.joining("\n"));
```
> 第五种方法 Using parallel Stream API (Java 8). Warning: This solution converts different line breaks (like \r\n) to \n.
```java
 String result = new BufferedReader(new InputStreamReader(inputStream))
    .lines().parallel().collect(Collectors.joining("\n"));
```
> 第六种方法 Using InputStreamReader and StringBuilder (JDK)
```java
 int bufferSize = 1024;
 char[] buffer = new char[bufferSize];
 StringBuilder out = new StringBuilder();
 Reader in = new InputStreamReader(stream, StandardCharsets.UTF_8);
 for (int numRead; (numRead = in.read(buffer, 0, buffer.length)) > 0; ) {
     out.append(buffer, 0, numRead);
 }
 return out.toString();
```
> 第七种方法 Using StringWriter and IOUtils.copy (Apache Commons)
```java
 StringWriter writer = new StringWriter();
 IOUtils.copy(inputStream, writer, "UTF-8");
 return writer.toString();
```
> 第八种方法 Using ByteArrayOutputStream and inputStream.read (JDK) 
```java
 ByteArrayOutputStream result = new ByteArrayOutputStream();
 byte[] buffer = new byte[1024];
 for (int length; (length = inputStream.read(buffer)) != -1; ) {
     result.write(buffer, 0, length);
 }
 // StandardCharsets.UTF_8.name() > JDK 7
 return result.toString("UTF-8");
```
> 第九种方法 Using ByteArrayOutputStream and inputStream.read (JDK) 
```java
 String newLine = System.getProperty("line.separator");
 BufferedReader reader = new BufferedReader(
         new InputStreamReader(inputStream));
 StringBuilder result = new StringBuilder();
 for (String line; (line = reader.readLine()) != null; ) {
     if (result.length() > 0) {
         result.append(newLine);
     }
     result.append(line);
 }
 return result.toString();
```

> 第十种方法 Using BufferedInputStream and ByteArrayOutputStream (JDK)
```java
BufferedInputStream bis = new BufferedInputStream(inputStream);
ByteArrayOutputStream buf = new ByteArrayOutputStream();
for (int result = bis.read(); result != -1; result = bis.read()) {
    buf.write((byte) result);
}
// StandardCharsets.UTF_8.name() > JDK 7
return buf.toString("UTF-8");
```
> 第十一种方法 Using inputStream.read() and StringBuilder (JDK). Warning: This solution has problems with Unicode, for example with Russian text (works correctly only with non-Unicode text)
```java
StringBuilder sb = new StringBuilder();
for (int ch; (ch = inputStream.read()) != -1; ) {
    sb.append((char) ch);
}
return sb.toString();
```
> 根据场景需求我最终选择第四种方法来解决读取jar包里的文件内容
本文来自：https://stackoverflow.com/questions/309424/how-do-i-read-convert-an-inputstream-into-a-string-in-java
