---
title: "Summary of Configuring Multiple Data Sources With Spring Boot 2.7.10 + JPA and Troubleshooting"
date: 2024-07-29T20:09:35+08:00
draft: false
featured: true
---


### 配置 Spring Boot 2.7.10 + JPA 支持多数据源 (使用 PostgreSQL 和 Nacos 配置)

#### 总结Spring Boot 2.7.10 + JPA 多数据源配置与问题解决
### Summary of Configuring Multiple Data Sources with Spring Boot 2.7.10 + JPA and Troubleshooting
我有一个项目需要访问多个数据库源，ccdb接口访问服务器ip为:`10.10.5.10`的ccdb数据库，而tbdb接口需要访问服务器ip为:`10.10.5.9`的tbdb数据库
ccdb接口和tbdb接口都属于同一个`jar`包代码，所以需要多数据库解决方案，
但在解决`Spring Boot 2.7.10`项目中配置多数据源和JPA访问数据库的过程中，遇到了一系列问题。以下是详细问题描述及解决方案：

#### 遇到的问题及解决方案

1. **`Not a managed type` 错误**
    - **问题描述**: 在启动应用程序时，遇到了`java.lang.IllegalArgumentException: Not a managed type`错误。
    - **原因**: 这是因为JPA实体类没有被正确扫描到，导致Hibernate无法识别这些类。
    - **解决方案**: 确保在`ccdbConfig`和`tbdbConfig`中正确配置了各自的数据源和`basePackages`，并且主类中不要再重复配置`basePackages`。

2. **`No qualifying bean of type` 错误**
    - **问题描述**: 应用启动时，报告找不到指定类型的bean。
    - **原因**: 多数据源配置时，未能正确配置各自的数据源和JPA相关的bean。
    - **解决方案**: 确保每个数据源配置类（如`ccdbConfig`和`tbdbConfig`）正确配置了`EntityManagerFactory`、`DataSource`和`TransactionManager`。

3. **`@EnableJpaRepositories` 的配置问题**
    - **问题描述**: 多数据源配置时，`@EnableJpaRepositories`没有正确配置。
    - **原因**: 主入口类配置了全局的`basePackages`，与各个数据源配置类的`basePackages`冲突。
    - **解决方案**: 在主入口类中移除`basePackages`配置，只在各自的数据源配置类中配置。

#### 详细配置步骤

1. **主入口类配置**

   ```java
   @SpringBootApplication(scanBasePackages = {"com.example"})
   @Slf4j
   @RestController
   @ComponentScan({"com.example.*"})
   @EnableJpaAuditing
   public class Application {
       public static void main(String[] args) {
           SpringApplication.run(Application.class, args);
       }
   }
   ```

2. **ccdbConfig 配置**

   ```java
   @Configuration
   @EnableJpaRepositories(
       basePackages = "com.example.ccdb.dao",
       entityManagerFactoryRef = "ccdbEntityManagerFactory",
       transactionManagerRef = "ccdbTransactionManager"
   )
   public class CcdbConfig {
       @Primary
       @Bean(name = "ccdbDataSource")
       @ConfigurationProperties(prefix = "spring.datasource.ccdb")
       public DataSource dataSource() {
           return DataSourceBuilder.create().build();
       }

       @Primary
       @Bean(name = "ccdbEntityManagerFactory")
       public LocalContainerEntityManagerFactoryBean entityManagerFactory(
               EntityManagerFactoryBuilder builder, @Qualifier("ccdbDataSource") DataSource dataSource) {
           return builder.dataSource(dataSource)
                   .packages("com.example.ccdb.model")
                   .persistenceUnit("ccdb")
                   .build();
       }

       @Primary
       @Bean(name = "ccdbTransactionManager")
       public PlatformTransactionManager transactionManager(
               @Qualifier("ccdbEntityManagerFactory") EntityManagerFactory entityManagerFactory) {
           return new JpaTransactionManager(entityManagerFactory);
       }
   }
   ```

3. **tbdbConfig 配置**

   ```java
   @Configuration
   @EnableJpaRepositories(
       basePackages = "com.example.tbdb.dao",
       entityManagerFactoryRef = "tbdbEntityManagerFactory",
       transactionManagerRef = "tbdbTransactionManager"
   )
   public class TbdbConfig {
       @Bean(name = "tbdbDataSource")
       @ConfigurationProperties(prefix = "spring.datasource.tbdb")
       public DataSource dataSource() {
           return DataSourceBuilder.create().build();
       }

       @Bean(name = "tbdbEntityManagerFactory")
       public LocalContainerEntityManagerFactoryBean entityManagerFactory(
               EntityManagerFactoryBuilder builder, @Qualifier("tbdbDataSource") DataSource dataSource) {
           return builder.dataSource(dataSource)
                   .packages("com.example.tbdb.model")
                   .persistenceUnit("tbdb")
                   .build();
       }

       @Bean(name = "tbdbTransactionManager")
       public PlatformTransactionManager transactionManager(
               @Qualifier("tbdbEntityManagerFactory") EntityManagerFactory entityManagerFactory) {
           return new JpaTransactionManager(entityManagerFactory);
       }
   }
   ```

#### PostgreSQL 数据库配置

在`application.yml`文件中，添加PostgreSQL数据源的配置：

```yaml
spring:
  datasource:
    ccdb:
      driver-class-name: org.postgresql.Driver
      url: jdbc:postgresql://10.10.5.10:5432/ccdb
      username: your-username
      password: your-password
    tbdb:
      driver-class-name: org.postgresql.Driver
      url: jdbc:postgresql://10.10.5.9:5432/tbdb
      username: your-username
      password: your-password
```

#### Nacos 配置

配置Spring Boot项目使用Nacos进行配置管理：

1. 添加依赖：

   ```xml
   <dependency>
       <groupId>com.alibaba.cloud</groupId>
       <artifactId>spring-cloud-starter-alibaba-nacos-config</artifactId>
       <version>2021.1</version>
   </dependency>
   ```

2. 在`bootstrap.yml`文件中配置Nacos：

```yaml
server:
  port: 7001
spring:
  main:
    allow-bean-definition-overriding: true
  profiles:
    active: @activatedProperties@
  servlet:
    multipart:
      max-file-size: 2000MB
      max-request-size: 2000MB
  application:
    name: example-admin-api
  cloud:
    nacos:
      discovery:
        server-addr: ${spring.cloud.nacos.server-addr}
        namespace: ${spring.cloud.nacos.namespace}
        group: ${spring.cloud.nacos.group}
      config:
        server-addr: ${spring.cloud.nacos.server-addr}
        namespace: ${spring.cloud.nacos.namespace}
        group: ${spring.cloud.nacos.group}
        file-extension: yaml
        refresh-enabled: true
        shared-configs[0]:
          data-id: example-admin-api.yml
          group: EXAMPLE_GROUP
          refresh: false
        shared-configs[1]:
          data-id: example-multiple-mysql.yml
          group: EXAMPLE_GROUP
          refresh: false
  mvc:
    pathmatch:
      matching-strategy: ant_path_matcher
  jpa:
    hibernate:
      ddl-auto: validate
    show-sql: true

---
# dev环境配置
spring:
  cloud:
    nacos:
      server-addr: 10.10.5.2:8848
      namespace: 3d10dc42-b214-4c0d-9ddb-8618a170873d
      group: EXAMPLE_GROUP
  config:
    activate:
      on-profile: dev

---
# master 正式环境环境配置
spring:
  cloud:
    nacos:
      server-addr: 10.10.5.3:8848
      namespace: c11b80fb-db5a-4a10-bb28-21945fffef72
      group: EXAMPLE_GROUP
  config:
    activate:
      on-profile: master
```

#### 核心依赖

在`pom.xml`文件中，确保以下核心依赖：

```xml
<dependencies>
    <!-- Spring Boot Starter Data JPA -->
    <dependency>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter-data-jpa</artifactId>
    </dependency>

    <!-- PostgreSQL Driver -->
    <dependency>
        <groupId>org.postgresql</groupId>
        <artifactId>postgresql</artifactId>
        <version>42.2.20</version>
    </dependency>

    <!-- Nacos Config Starter -->
    <dependency>
        <groupId>com.alibaba.cloud</groupId>
        <artifactId>spring-cloud-starter-alibaba-nacos-config</artifactId>
        <version>2021.1</version>
    </dependency>

    <!-- Spring Boot Starter Web -->
    <dependency>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter-web</artifactId>
    </dependency>

    <!-- Lombok -->
    <dependency>
        <groupId>org.projectlombok</groupId>
        <artifactId>lombok</artifactId>
    </dependency>
</dependencies>
```

#### 项目结构如下
```markdown
example-multi-datasource-project
├── src
│   ├── main
│   │   ├── java
│   │   │   └── com
│   │   │       └── example
│   │   │           ├── Application.java  #spring boot 启动入口
│   │   │           ├── ccdb  #查ccdb数据库服务器
│   │   │           │   ├── config
│   │   │           │   │   └── CcdbConfig.java
│   │   │           │   ├── dao
│   │   │           │   │   └── RnPluginsRepository.java
│   │   │           │   ├── model
│   │   │           │   │   └── RnPlugins.java
│   │   │           │   └── service
│   │   │           │       └── RnPluginsService.java
│   │   │           ├── tbdb  #查tbdb数据库服务器
│   │   │           │   ├── config
│   │   │           │   │   └── TbdbConfig.java
│   │   │           │   ├── dao
│   │   │           │   │   └── TbPluginsRepository.java
│   │   │           │   ├── model
│   │   │           │   │   └── TbPlugins.java
│   │   │           │   └── service
│   │   │           │       └── TbPluginsService.java
│   │   │           └── common
│   │   │               └── config
│   │   │                   └── CommonConfig.java
│   │   ├── resources
│   │   │   ├── application.yml
│   │   │   ├── bootstrap.yml
│   │   │   └── logging.yml
│   ├── test
│   │   ├── java
│   │   │   └── com
│   │   │       └── example
│   │   │           ├── ccdb
│   │   │           │   └── RnPluginsServiceTest.java
│   │   │           └── tbdb
│   │   │               └── TbPluginsServiceTest.java
├── pom.xml
└── README.md
```

这种格式应该在 Hugo 中正确渲染。如果仍然遇到问题，可以检查 Hugo 的渲染配置，确保 Markdown 文件的解析设置正确。


#### 调试与验证

1. **检查实体类**：确保所有JPA实体类都在指定的包路径下，并且正确标注了`@Entity`注解。
2. **日志级别**：将Spring和Hibernate的日志级别调整为`DEBUG`，以获取更多的调试信息。
3. **单独验证**：分别启动两个数据源的配置，确保各自单独运行时没有问题，然后再组合进行测试。

通过这些步骤，最终成功解决了Spring Boot 2.7.10 + JPA 多数据源配置中的问题。关键在于各个配置类的职责清晰，并避免配置的冲突。
