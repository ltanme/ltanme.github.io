---
title: "Configure Direct Domain in Clash"
date: 2023-10-12T17:00:18+08:00
url: "/guides/configure-direct-domain-in-clash"
featured: true
---

In Clash, if you want a specific domain to bypass the proxy and connect directly, you can utilize the `mixin` and `rules` settings. Below is an example of how to set up a direct connection for the domain `baolei.xxxx.com`:

```yaml
dns:
  enable: true
  enhanced-mode: redir-host # 或者使用 fake-ip，根据你的需求选择
  listen: 0.0.0.0:53
  nameserver:
    - 172.20.128.2 # 你的首选DNS服务器,家庭内网dns,公司内网dns
    - 172.20.128.3 # 你的备用DNS服务器,家庭内网dns,公司内网dns
    # - "8.8.8.8" # 公共DNS，仅在访问互联网时使用
    # - "8.8.4.4" # 公共DNS，仅在访问互联网时使用
  fallback: # 当 nameserver 无法解析才使用以下dns解析
    - "8.8.8.8"
    - "8.8.4.4"
    - "1.1.1.1"
  fallback-filter:
    geoip: true # 使用GeoIP规则过滤掉国内的IP地址
    ipcidr: # 保证以下私有地址范围不使用fallback DNS
      - "0.0.0.0/8"
      - "10.0.0.0/8"
      - "127.0.0.0/8"
      - "169.254.0.0/16"
      - "172.16.0.0/12"
      - "192.168.0.0/16"
      - "::1/128"
      - "fc00::/7"
      - "fe80::/10"

rules:
  - 'DOMAIN-SUFFIX,baolei.xxxx.com,DIRECT' # 确保这条规则在任何可能触发代理的规则之前
  # 其他规则...

```

`mixin`: This setting allows you to modify the main configuration dynamically. It is useful when you want to have a base configuration and apply changes without affecting the main configuration.   

`dns`: Inside the mixin, this section configures the DNS settings for Clash.   

`enable`: true: This enables the DNS feature in Clash.   
`listen`: :53: This instructs Clash to listen on port 53 for DNS requests.   
`nameserver`: This specifies the default DNS servers that Clash will use to resolve domain names. In this case, Google's public DNS (8.8.8.8) is used.   
`rules`: This section defines the rules for how domains are treated in terms of routing.   

`DOMAIN-SUFFIX,baolei.xxxx.com,DIRECT`: This rule means that any domain ending with baolei.xxxx.com will connect directly, bypassing the proxy.
By implementing this configuration, all traffic to baolei.xxxx.com will bypass the proxy and connect directly. It's useful when you want certain domains to have a direct connection, perhaps due to performance reasons or to bypass potential issues with proxying.  

# 对于 DIRECT 规则，即使域名解析使用了 8.8.8.8，实际的数据流还是直连的

