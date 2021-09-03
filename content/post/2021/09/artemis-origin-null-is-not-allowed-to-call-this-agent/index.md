---
title: "Artemis Origin Null Is Not Allowed to Call This Agent"
date: 2021-09-03T11:14:53+08:00
draft: false
tags: ["activemq artemis","wireshark","jolokia"]
---

# Artemis Origin Null Is Not Allowed to Call This Agent 

### 解决不能访问jolokia http interface 接口的问题，访问报403 状态错误 

> 工作项目中需要使用到mq的消息管理api,如需要查询在线连接数，需要查看某一个clientId是否在线，需要整合到自身业务当中去，
>
> 对于artemis 就是一个黑盒，虽然是开源的，而且是完全开放的源代码，没有必须去改里面源码达到需求，其实artemis 后台提供了
>
> 丰富的http rest 接口。再比如根据某一个clientId 踢下线，超时设置，连接数查看，系统资源统计监控查询这些api 都是开放的
>
> 但发现实际使用过程中，并不是很顺利，踩了一些坑，标题就是常见的问题之一



比如官方这篇文档有提到通过 jolokia 提供 接口对外暴露调用，以一下是连接地址

[Management · ActiveMQ Artemis Documentation (apache.org)](http://activemq.apache.org/components/artemis/documentation/latest/management.html#management-notifications)

```
Exposing JMX using Jolokia
The default Broker configuration ships with the Jolokia HTTP agent deployed as a web application. Jolokia is a remote JMX-over-HTTP bridge that exposes MBeans. For a full guide as to how to use it refer to Jolokia Documentation, however a simple example to query the broker's version would be to use a browser and go to the URL http://username:password@localhost:8161/console/jolokia/read/org.apache.activemq.artemis:broker="0.0.0.0"/Version.

This would give you back something like the following:
```

```json
{"request":{"mbean":"org.apache.activemq.artemis:broker=\"0.0.0.0\"","attribute":"Version","type":"read"},"value":"2.0.0-SNAPSHOT","timestamp":1487017918,"status":200}
```

访问格式如下，比如查询borker  版本 

```
http://username:password@localhost:8161/console/jolokia/read/org.apache.activemq.artemis:broker="0.0.0.0"/Version
```

但实际过程就是报错如下 ，常见403错误

原因是 origin 这个参数是null, 官方也没有说清 origin 这个参数是怎么传过去，虽然做为开发对http接口协议还是有一点了解，

origin 这个参数就是需要指明访问目标。通常在http header头 加上即可

```
{

  "error_type": "java.lang.Exception",

  "error": "java.lang.Exception : Origin null is not allowed to call this agent",

  "status": 403

}
```

![image-20210903113004787](image-20210903113004787.png)

加上后果然访问正常了

![image-20210903113348373](image-20210903113348373.png)



但在实际springboot 项目中，我们用restTemplate 这个http client 客户端，发现不行，还是403

postman 是可以的，我们在spring boot 项目中，用restTemplate 访问不行。为什么，后面我们没有绕过这个问题，没有换过库

没有使用postman 推荐的code ,以下是postman 推荐的，但没有尝试，我们还是坚持采用 restTemplate  客户端

```Java
Unirest.setTimeouts(0, 0);
HttpResponse<String> response = Unirest.get("http://admin:admin@172.20.151.90:8161/console/jolokia/")
  .header("Origin", " http://172.20.151.90:8161")
  .header("Content-Type", "application/json")
  .body("{\"type\":\"exec\",\"mbean\":\"org.apache.activemq.artemis:broker=\\\"d2403827fe6c\\\"\",\"operation\":\"listConsumers(java.lang.String, int, int)\",\"arguments\":[\"{\\\"field\\\":\\\"CLIENT_ID\\\",\\\"operation\\\":\\\"EQUALS\\\",\\\"value\\\":\\\"86303335\\\",\\\"sortOrder\\\":\\\"asc\\\",\\\"sortColumn\\\":\\\"id\\\"}\",1,10]}")
  .asString();

```



怀疑 restTemplate 并没有把orgin传过去,经过抓包 才发现

于是我们用`wireshark` 工具抓包发现restTemplate 没有把orgin 参数传给atemis-server

![img](16306405458570.png)

然后在百度一下，发现以下csdn 博客解决了，增加一行配置即可

```
System.setProperty("sun.net.http.allowRestrictedHeaders","true");
```



```java

@Component
public class ArtemisJmxHelper {
  @Autowired
  private RestTemplate restTemplate;
  private final String username="admin";
  private final String password="admin";

  public Map getTopicCosumer(String topic){


//这一行必须要加，才能让restTemplate 生效orgin参数 
System.setProperty("sun.net.http.allowRestrictedHeaders","true");



//    String url="http://admin:admin@172.20.151.90:8161/console/jolokia";
    String url="http://172.20.151.90:8161/console/jolokia/";
    JolokiaReq jolokiaReq = new JolokiaReq();
    jolokiaReq.setType("exec");
    jolokiaReq.setOperation("listConsumers(java.lang.String, int, int)");
    jolokiaReq.setMbean("org.apache.activemq.artemis:broker=\"d2403827fe6c\"");

​    Map req = new HashMap();
​    req.put("field","CLIENT_ID");
​    req.put("operation","EQUALS");
​    req.put("value","deviceClient");
​    req.put("sortOrder","asc");
​    req.put("sortColumn","id");
​    Object[] arguments=new Object[]{JSON.toJSONString(req),1,10};
​    jolokiaReq.setArguments(arguments);

​    HttpHeaders httpHeaders = new HttpHeaders();
​    httpHeaders.setContentType(MediaType.APPLICATION_JSON);
​    httpHeaders.add("Origin","http://172.20.151.90:8161");
​    String auth = username + ":" + password;
​    byte[] encodedAuth = Base64.encodeBase64(auth.getBytes(Charset.forName("US-ASCII")));
​    httpHeaders.add("Authorization", "Basic " + new String(encodedAuth));



    HttpEntity httpEntity = new HttpEntity(jolokiaReq,httpHeaders);
    String str = JSON.toJSONString(httpEntity);
    System.out.println(str);
    ResponseEntity<String> responseEntity = restTemplate.postForEntity(url, str, String.class);
    String body = responseEntity.getBody();
    return null;
  }
}
```



加了后 `System.setProperty("sun.net.http.allowRestrictedHeaders","true");`

![image-20210903142612594](image-20210903142612594.png)



４０３问题 最后总结一下：

  有两点需要注意的，

第一，请求时，需要加用户名和密码，在ｈｅａｄｅｒ头增加ｏｒｇｉｎ参数

第二，需要在jolokia-access.xml设置给一下跨域访问为  cors `*//* `