---
title: "Controlling Internet Access with OpenWRT Firewall: Blocking Websites and Disabling Internet"
date: 2025-02-28T17:03:23+08:00
draft: false
tags: ["OpenWRT", "Firewall", "Networking", "Parental Controls"]
categories: ["Networking", "Home Automation"]
description: "Learn how to control internet access for devices on your network using OpenWRT's firewall capabilities, including blocking specific websites, managing access to NAS resources, and scheduling internet availability."
---

## Introduction

In today's connected world, managing internet access within a home or small office network has become increasingly important. Whether you're implementing parental controls, limiting non-productive internet usage during specific hours, or securing access to network resources, OpenWRT provides powerful tools to accomplish these tasks.

This article demonstrates several practical scripts for controlling internet access using an OpenWRT router. We'll cover:

1. Switching between different proxy modes (using OpenClash)
2. Restricting access to NAS resources for specific devices
3. Completely disabling internet access for selected devices
4. Blocking specific websites using filtering rules
5. Automating all of the above with scheduled cron jobs

## Prerequisites

- An OpenWRT router with shell access
- Basic familiarity with Linux command line
- OpenClash installed (for the proxy mode script)
- AdGuard Home installed (for the website filtering script)

## Script 1: Controlling Proxy Mode with OpenClash

OpenClash is a popular proxy tool for OpenWRT that allows traffic routing through different rules. This script toggles between "Rule" mode (selective proxy) and "Direct" mode (bypass proxy):

```bash
#!/bin/bash
# switch_openclash_mode.sh

# Determine mode based on parameter
if [ "$1" == "enable" ]; then
    MODE="Rule"
elif [ "$1" == "disable" ]; then
    MODE="Direct"
else
    echo "Usage: $0 enable|disable"
    exit 1
fi

# Generate JSON payload
JSON_PAYLOAD=$(echo '{}' | jq -c --arg mode "$MODE" '.mode = $mode')

# Target URL
URL="http://192.168.100.200:9090/configs"

# Construct curl command
CURL_CMD="curl -X PATCH \"$URL\" \
-H \"Accept: application/json, text/plain, */*\" \
-H \"Accept-Encoding: gzip, deflate\" \
-H \"Accept-Language: en,zh-CN;q=0.9,zh;q=0.8,en-GB;q=0.7,en-US;q=0.6\" \
-H \"Authorization: Bearer xxxxxxxxxxxx\" \
-H \"Connection: keep-alive\" \
-H \"Content-Type: application/json\" \
-H \"Host: 192.168.100.200:9090\" \
-H \"Origin: http://192.168.100.200:9090\" \
-H \"Referer: http://192.168.100.200:9090/ui/dashboard/\" \
-H \"User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/129.0.0.0 Safari/537.36\" \
-d '$JSON_PAYLOAD' -w \"\\nHTTP_CODE:%{http_code}\""

# Print and execute command
echo "Executing command:"
echo "$CURL_CMD"
OUTPUT=$(eval "$CURL_CMD")
echo "$OUTPUT"
```

**Usage:**
- `./clashlimit.sh enable` - Switches to Rule mode
- `./clashlimit.sh disable` - Switches to Direct mode

> **Note:** Replace the Authorization token with your own OpenClash API token.

## Script 2: Restricting Access to NAS Resources

This script allows you to control which devices can access your NAS by MAC address:

```bash
#!/bin/sh

# Define NAS IP address
NAS_IP="192.168.100.193"

# List of MAC addresses to control
MAC_LIST="XX:XX:XX:XX:XX:XX XX:XX:XX:XX:XX:XX XX:XX:XX:XX:XX:XX XX:XX:XX:XX:XX:XX XX:XX:XX:XX:XX:XX"

# Get first parameter (disable or enable)
ACTION=$1

# Process based on parameter
if [ "$ACTION" = "disable" ]; then
    # Disable access - add firewall rule for each MAC address
    for MAC in $MAC_LIST; do
        iptables -A FORWARD -d $NAS_IP -m mac --mac-source $MAC -j REJECT
        echo "Disabled: $MAC access to $NAS_IP"
    done
elif [ "$ACTION" = "enable" ]; then
    # Enable access - remove firewall rule for each MAC address
    for MAC in $MAC_LIST; do
        iptables -D FORWARD -d $NAS_IP -m mac --mac-source $MAC -j REJECT
        echo "Enabled: $MAC access to $NAS_IP"
    done
else
    echo "Error: Parameter must be 'disable' or 'enable'"
    exit 1
fi
```

**Usage:**
- `./naslimit.sh disable` - Blocks specified devices from accessing the NAS
- `./naslimit.sh enable` - Allows specified devices to access the NAS

> **Note:** Replace the MAC addresses with those of the devices you want to control.

## Script 3: Controlling Internet Access by MAC Address

This script enables or disables internet access completely for specified devices:

```bash
#!/bin/sh

# Configure MAC addresses to manage
MAC_LIST="XX:XX:XX:XX:XX:XX XX:XX:XX:XX:XX:XX XX:XX:XX:XX:XX:XX XX:XX:XX:XX:XX:XX XX:XX:XX:XX:XX:XX"

manage_mac() {
    for mac in $MAC_LIST; do
        case "$1" in
            disable)
                # Check if DROP rule already exists, if not add it
                iptables -C FORWARD -m mac --mac-source "$mac" -j DROP 2>/dev/null
                if [ $? -ne 0 ]; then
                    iptables -I FORWARD -m mac --mac-source "$mac" -j DROP
                    logger -p info -t "timeset" "Blocked internet access for MAC address $mac"
                else
                    logger -p info -t "timeset" "MAC address $mac already blocked"
                fi
                ;;
            enable)
                # Check if DROP rule exists, if yes remove it
                iptables -C FORWARD -m mac --mac-source "$mac" -j DROP 2>/dev/null
                if [ $? -eq 0 ]; then
                    iptables -D FORWARD -m mac --mac-source "$mac" -j DROP
                    logger -p info -t "timeset" "Allowed internet access for MAC address $mac"
                else
                    logger -p info -t "timeset" "MAC address $mac already allowed"
                fi
                ;;
            *)
                logger -p err -t "timeset" "Unsupported parameter: $1. Use disable or enable."
                ;;
        esac
    done
}

# Call function with provided parameter
manage_mac "$1"
```

**Usage:**
- `./netlimit.sh disable` - Blocks internet access for specified devices
- `./netlimit.sh enable` - Enables internet access for specified devices

## Script 4: Blocking Specific Websites with AdGuard Home

This script manages filtering rules in AdGuard Home to block or allow access to specific websites:

```bash
#!/bin/bash

# Preset rules (fixed rules, unchangeable)
PRESET_RULES='["||gamesgo.net^","||game.moe.ms^","||265.com^","||yandex.com^","||papergaes.io^","||17yoo.cn^","||gamemonetize.com^","||gamemonetize.video^","||gamemonetize.co^","||finder.video.qq.com^","||szextshort.weixin.qq.com^","||360.cn^","||msn.cn^","||4399.com^","||18183.com^","||Y8.com^","||addictinggames.com^","||7k7k.com^","||freeonlinegames.com^","||armorgames.com^","||html5games.com^","||kongregate.com^","||17173.com^","||2436.cn^","||3199.cn^","||17yy.com^","||pogo.com^","||douying.com^","||douyin.com^","||acfun.cn^","||ixigua.com^","||shifen.aazzgames.com^","@@||jia.360.cn^$important"]'

# Additional rules (configurable as needed)
ADDITIONAL_RULES_DISABLE='["||poki.com^","||youtube.com^"]'
ADDITIONAL_RULES_ENABLE='[]'  # Empty when enabling

# AdGuard Home credentials
USERNAME="admin"
PASSWORD="password"

# Merge rules function
merge_rules() {
    if [ "$1" == "disable" ]; then
        # Merge preset rules with additional disable rules
        BODY=$(echo "$PRESET_RULES" | jq -c --argjson additional "$ADDITIONAL_RULES_DISABLE" '. + $additional')
        BODY="{\"rules\":$BODY}"
    elif [ "$1" == "enable" ]; then
        # Use only preset rules when enabling
        BODY=$(echo "$PRESET_RULES" | jq -c --argjson additional "$ADDITIONAL_RULES_ENABLE" '. + $additional')
        BODY="{\"rules\":$BODY}"
    fi
}

# Function to send POST request
send_post_request() {
    HTTP_CODE=$(curl -o /dev/null -w '%{http_code}' -X POST "http://192.168.100.1:3000/control/filtering/set_rules" \
    -u "$USERNAME:$PASSWORD" \
    -H "Content-Type: application/json" \
    -H "Accept: application/json, text/plain, */*" \
    -H "Accept-Encoding: gzip, deflate" \
    -H "Accept-Language: zh-CN,zh;q=0.9,en;q=0.8,en-GB;q=0.7,en-US;q=0.6" \
    -H "Connection: keep-alive" \
    -H "Cookie: agh_session=xxxxxxxxxxxxxxxxxxxxxxxxx" \
    -H "Host: 192.168.100.1:3000" \
    -H "Origin: http://192.168.100.1:3000" \
    -H "Referer: http://192.168.100.1:3000/" \
    -H "User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/129.0.0.0 Safari/537.36" \
    -d "$BODY")
    echo "HTTP Status Code: $HTTP_CODE"
}

# Process based on parameter
case "$1" in
    disable)
        echo "Applying restriction rules..."
        merge_rules "disable"
        echo "Request Body: $BODY"
        send_post_request
        ;;
    enable)
        echo "Removing restriction rules..."
        merge_rules "enable"
        echo "Request Body: $BODY"
        send_post_request
        ;;
    *)
        echo "Invalid parameter: $1. Use disable or enable."
        exit 1
        ;;
esac
```

**Usage:**
- `./weblimit100_1.sh disable` - Blocks additional websites (like YouTube)
- `./weblimit100_1.sh enable` - Removes additional blocks

> **Note:** Replace the username, password, and cookie with your AdGuard Home credentials.

## Scheduling with Cron Jobs

To automate these scripts based on time schedules, you can use cron jobs on your OpenWRT router. Here are some examples:

### Example 1: Block Games and Social Media During Study Hours

```
# Block access to entertainment sites on weekdays during school hours
0 8 * * 1-5 /root/weblimit100_1.sh disable
0 17 * * 1-5 /root/weblimit100_1.sh enable
```

### Example 2: Disable Internet Access at Night for Children's Devices

```
# Disable internet for kids' devices at night
0 22 * * * /root/netlimit.sh disable
0 7 * * * /root/netlimit.sh enable
```

### Example 3: Restrict NAS Access During Work Hours

```
# Block NAS access during work hours
0 9 * * 1-5 /root/naslimit.sh disable
0 18 * * 1-5 /root/naslimit.sh enable
```

### Example 4: Switch Proxy Mode Based on Time of Day

```
# Use Rule mode during daytime, Direct mode at night
0 8 * * * /root/clashlimit.sh enable
0 23 * * * /root/clashlimit.sh disable
```

## Adding Cron Jobs in OpenWRT

To add these schedules to your OpenWRT router:

1. SSH into your router
2. Edit the crontab:
   ```
   crontab -e
   ```
3. Add your desired schedules using the format shown above
4. Save and exit
5. Restart the cron service:
   ```
   /etc/init.d/cron restart
   ```

You can also add cron jobs through the LuCI web interface under System → Scheduled Tasks.

## Security Considerations

When implementing these scripts, consider the following security aspects:

1. **Credential Protection**: Replace all API tokens, usernames, and passwords with secure credentials.
2. **Script Permissions**: Ensure your scripts are only executable by root or appropriate system users.
3. **IP and MAC Validation**: Validate all IPs and MACs to prevent script injection attacks.
4. **Logging**: Implement proper logging to monitor script execution and troubleshoot issues.

## Conclusion

OpenWRT provides powerful capabilities for controlling internet access on your network. By combining firewall rules, AdGuard Home filtering, and scheduled cron jobs, you can implement sophisticated access control policies tailored to your specific needs.

These scripts offer a starting point that you can customize for your particular network environment and requirements. Whether you're implementing parental controls, boosting productivity, or securing network resources, these tools provide an effective solution.

## References

- [OpenWRT Documentation](https://openwrt.org/docs/start)
- [iptables Manual](https://linux.die.net/man/8/iptables)
- [AdGuard Home Documentation](https://github.com/AdguardTeam/AdGuardHome/wiki)
- [OpenClash Documentation](https://github.com/vernesong/OpenClash/wiki)

