---
title: "Configure Direct Domain in Clash"
date: 2023-10-12T17:00:18+08:00
url: "/guides/configure-direct-domain-in-clash"
featured: true
---

In Clash, if you want a specific domain to bypass the proxy and connect directly, you can utilize the `mixin` and `rules` settings. Below is an example of how to set up a direct connection for the domain `baolei.xxxx.com`:

```yaml
mixin: # Pay attention to the indentation below
  dns:
    enable: true
    listen: :53
    nameserver:
      - 8.8.8.8

rules:
  - DOMAIN-SUFFIX,baolei.xxx.com,DIRECT
Explanation:
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

