---
title: "How to Install Apache Spark on Windows Setup PySpark"
date: 2023-05-11T15:25:41+08:00
draft: false
tags: ["python3","pyspark","scala","winutils"]
featured: true
---

## 为什么要在Windows 10上运行Scala Spark程序
### 开发环境设置简单：
对于许多开发者来说，Windows是他们最熟悉的操作系统，
因此在Windows上进行开发可以节省大量的环境设置和配置时间。
此外，Windows上有IntelliJ IDEA可以方便Scala和Spark的开发。

### 本地测试方便：
在本地Windows环境中进行开发，
可以方便快速的进行代码的单元测试和调试。
虽然Spark在集群中运行时的行为可能与在单个机器上有所不同，
但对于许多常见的任务，
本地测试通常可以提供足够的保证。


## 如何做
### 步骤1，下载spark并安装
根据自己的环境版本，在官网下载`spark-3.2.4-bin-hadoop2.7`包
下载链接地址为`https://spark.apache.org/downloads.html`
解压.tgz文件放到你本地目录夹,如`d:\spark-2.4.4-bin-hadoop2.7`

### 步骤2 下载winutils并安装
下载winutils.exe(解释windows hadoop通信问题)
下载链接地址`https://github.com/steveloughran/winutils/blob/master/hadoop-2.7.1/bin/winutils.exe`
存放到`d:\spark-2.4.4-bin-hadoop2.7\bin\winutils.exe` 该目录下

### 步骤3，设置环境变量
设置windows环境变量
```shell
# Environment variable: 
SPARK_HOME=d:\spark-2.4.4-bin-hadoop2.7
HADOOP_HOME=d:\spark-2.4.4-bin-hadoop2.7
# PATH variable:
 d:\spark-2.4.4-bin-hadoop2.7\bin
```

### 步骤4 验证测试scala spark 、 pyspark
测试 pyspark
```python
import sys
# 这里不需要用pip install pyspark 会容易报错，根本不好安装的，不好使还不如这样引用
sys.path.append("D:\spark-3.2.4-bin-hadoop2.7\python")
from pyspark.sql import SparkSession

# 创建 SparkSession
spark = SparkSession.builder
    .appName("HDFS Read Example")
    .config("spark.master", "local")
    .getOrCreate()

# 读取 CSV 文件
df = spark.read.csv("hdfs://sybigdata/user/example/part-00000-d3d3436e-f258-43b8-bfec-e45eb966edc7-c000.csv", header=True)

# 显示前 10 行
df.show(10)

```
查看显示结果
```shell
Using Spark's default log4j profile: org/apache/spark/log4j-defaults.properties
Setting default log level to "WARN".
To adjust logging level use sc.setLogLevel(newLevel). For SparkR, use setLogLevel(newLevel).
23/05/11 15:19:23 WARN NativeCodeLoader: Unable to load native-hadoop library for your platform... using builtin-java classes where applicable
+------+--------+--------------+--------------+-----------+----------+
|vvbbcc|hhmm_int|abc_name_index|abc_page_index|bbbbb_index|dddd_index|
+------+--------+--------------+--------------+-----------+----------+
|    31|     943|           2.0|           2.0|        0.0|       0.0|
|    18|     395|           6.0|           6.0|        0.0|      31.0|
|     9|    1175|           2.0|           2.0|        0.0|      20.0|
|    15|    1250|           5.0|           5.0|        0.0|      34.0|
|    16|     266|           7.0|           7.0|        0.0|       1.0|
|     6|     131|           5.0|           5.0|        0.0|       8.0|
|     8|     136|           4.0|           3.0|        0.0|       0.0|
|     7|    1229|           1.0|           1.0|        0.0|       5.0|
|    10|      79|           4.0|           3.0|        0.0|       4.0|
|    19|    1156|           6.0|           6.0|        0.0|       3.0|
+------+--------+--------------+--------------+-----------+----------+
```

only showing top 10 rows



### 验证scala spark
读取csv文件
```shell
    val spark = SparkSession.builder()
      .appName("ShowLocal")
      .config("spark.master", "local")
      .enableHiveSupport()
      .getOrCreate()
    val path = "hdfs://sybigdata/user/example/part-00000-d3d3436e-f258-43b8-bfec-e45eb966edc7-c000.csv"
    // 从HDFS中读取所有CSV文件
    val df = spark.read.format("csv").option("header", "true").load(path)
    // 打印数据
    df.show(10)
```
写入csv文件
```shell
    System.setProperty("hadoop.home.dir", "C:\\winutils\\")

    val user = "admin"
    val ugi = UserGroupInformation.createRemoteUser(user)

    ugi.doAs(new PrivilegedExceptionAction[Unit]() {
      override def run: Unit = {
        val spark = SparkSession.builder()
          .appName("helloSpsark")
          .config("spark.master", "local")
          .enableHiveSupport()
          .getOrCreate()
        val tuples = Seq((1, "spark"), (2, "Big Data"))
        val df = spark.createDataFrame(tuples).toDF()
        df.show()
        #这里会把csv文件保存在e:\abcd目录下
        df.write.mode(SaveMode.Overwrite).format("csv").save("file:///e:/abcd")
        spark.stop()
      }
    })
```
以下是保存的csv文件目录
```shell
E:\abcd>dir 
2023/05/11  14:59    <DIR>          .
2023/05/11  14:59    <DIR>          ..
2023/05/11  14:59                12 .part-00000-8430568a-02c2-4db8-ad6c-16a2aed410df-c000.csv.crc
2023/05/11  14:59                 8 ._SUCCESS.crc
2023/05/11  14:59                21 part-00000-8430568a-02c2-4db8-ad6c-16a2aed410df-c000.csv
2023/05/11  14:59                 0 _SUCCESS
               4 个文件             41 字节
               2 个目录 211,274,485,760 可用字节
```
csv 文件内容
```shell
E:\abcd>type part-00000-8430568a-02c2-4db8-ad6c-16a2aed410df-c000.csv
1,spark
2,Big Data
```