---
title: "Hybrid Encryption With AES 128 Bit and RSA Using Java and Ngx_lua"
date: 2023-06-08T14:40:51+08:00 
draft: false
tags: ["AES","RSA","ngx_lua","encryption"]
featured: true
---
## 一种 AES（128位）+RSA混合加密，iv为前16个0字符，使用java和ngx.lua编写的加解密方法
使用 openresty 和 ngx_lua 编写的服务端 HTTP 接口，旨在提供给 Android 设备提交加密数据上报、日志采集等功能。   
主要流流程如下
![aes+rsa混合常见流程](./swim-road-flow.PNG)
>`local enable_padding = true`：定义一个布尔变量` enable_padding` 并赋值为 `true`，用于启用填充功能。
`local aes_128_cbc_with_padding = aes:new(key, nil, aes.cipher(128,"cbc"), {iv = string.rep('\0', 16)}, nil, nil, enable_padding)`：
`aes:new()` 是创建 `AES` 加密算法实例的函数。   
`key` 是用于加密和解密的密钥。   
`nil` 表示没有额外的选项参数。   
`aes.cipher(128, "cbc")` 指定使用`AES-128` 位密钥和 `CBC (Cipher Block Chaining)` 模式进行加密。   
`{iv = string.rep('\0', 16)}` 是初始化向量 `(IV)`，其中 `string.rep('\0', 16)` 创建了一个由 `16` 个空字符组成的字符串作为 `IV`。   
最后一个参数 `enable_padding` 是用于启用填充功能的布尔变量。   

> 以下是lua加密流程
```lua
local rsa_priv_key=[[
-------BEGIN PRIVATE KEY-----
your rsa private key code here 
-------END PRIVATE KEY-----
]]

 
local rsa_pub_key=[[
-------BEGIN PUBLIC KEY-----
your rsa public key code here 
-------END PUBLIC KEY-----
]]

local resty_rsa = require "resty.rsa"
local resty_aes = require "resty.aes"
local resty_rand = require "resty.random"
local resty_str = require "resty.string"

-- Base64 encode with URL safe and no padding
local function encode_base64url(input)
    local encoded = ngx.encode_base64(input)
    local url_encoded = string.gsub(encoded, '+', '-')
    url_encoded = string.gsub(url_encoded, '/', '_')
    url_encoded = string.gsub(url_encoded, '=', '')
    return url_encoded
end

-- RSA encryption function
local function rsa_encrypted(aes_key)
    local pub, err = resty_rsa:new({ public_key = rsa_pub_key })
    if not pub then
        ngx.say("new rsa err: ", err)
        return
    end
    local encrypted = pub:encrypt(aes_key)
    return encrypted
end

-- AES encryption function
local function aes_encrypted(aes_key, content)
    local aes_128_cbc_with_padding = resty_aes:new(
            aes_key, nil, resty_aes.cipher(128,"cbc"), {iv = string.rep('\0', 16)}, nil,
            nil, true)
    if not aes_128_cbc_with_padding then
        ngx.say('Failed to create aes_128_cbc_with_padding')
        return nil
    end
    local encrypted = aes_128_cbc_with_padding:encrypt(content)
    return encrypted
end

-- Main encryption function
function encrypt(content)
    -- 1. Generate random AES key
    local aes_key = resty_rand.bytes(16)

    -- 2. Use RSA algorithm + RSA public key to encrypt the AES key
    local encrypted_aes_key = rsa_encrypted(aes_key)
    if encrypted_aes_key == nil then
        ngx.say("Failed to encrypt AES key")
        return nil
    end

    -- 3. Use AES to encrypt the content
    local encrypted_content = aes_encrypted(aes_key, content)
    if encrypted_content == nil then
        ngx.say("Failed to encrypt content")
        return nil
    end

    -- Return the base64url encoded encrypted AES key and content
    return encode_base64url(encrypted_aes_key), encode_base64url(encrypted_content)
end

-- Your content to encrypt
local content = "Your content here"

-- Call the encrypt function
local encryptedAesKey, encryptedContent = encrypt(content)

-- Print the base64url encoded encrypted AES key and content
ngx.say("Encrypted AES Key: ", encryptedAesKey)
ngx.say("Encrypted Content: ", encryptedContent) 
```

> 以下是解密流程代码
```lua
local rsa_priv_key=[[
-------BEGIN PRIVATE KEY-----
your rsa private key code here 
-------END PRIVATE KEY-----
]]

local rsa_pub_key=[[
-------BEGIN PUBLIC KEY-----
your rsa public key code here 
-------END PUBLIC KEY-----
]]

local resty_str = require "resty.string"

local function stringToHex(input)
    return resty_str.to_hex(input)
end

-- Base64 decode with URL safe and no padding
local function decode_base64url(input)
    local remainder = #input % 4
    if remainder > 0 then
        local padding = string.rep('=', 4 - remainder)
        input = input .. padding
    end
    local url_decoded = string.gsub(input, '-', '+')
    url_decoded = string.gsub(url_decoded, '_', '/')
    local decoded = ngx.decode_base64(url_decoded)
    return decoded
end

-- Base64 decode with no padding
local function decode_base64nopad(input)
    local remainder = #input % 4
    if remainder > 0 then
        local padding = string.rep('=', 4 - remainder)
        input = input .. padding
    end
    local decoded = ngx.decode_base64(input)
    return decoded
end

-- RSA decryption function
local function rsa_decrypted(base64url_str)
   local resty_rsa = require "resty.rsa"
   if base64url_str == nil then
      return nil
   end
   local decoded_str = decode_base64url(base64url_str)

   if decoded_str == nil then
      ngx.say("Failed to decode base64url string: ", base64url_str)
      return nil
   end
    local priv, err = resty_rsa:new({ private_key = rsa_priv_key })
    if not priv then
       ngx.say("new rsa err: ", err)
       return
   end
   local decrypted = priv:decrypt(decoded_str)

   return  decrypted
end

-- AES decryption function
local function aes_decrypted(key, str)
   if key == nil or str == nil then
      ngx.say('key or str is nil')
      return nil
   end
    local decode_str = decode_base64url(str)
   local aes = require "resty.aes"
   local enable_padding = true
   local aes_128_cbc_with_padding = aes:new(
       key, nil, aes.cipher(128,"cbc"), {iv = string.rep('\0', 16)}, nil,
       nil, enable_padding)
   if not aes_128_cbc_with_padding then
        ngx.say('Failed to create aes_256_cbc_with_padding')
        return nil
   end
   local decrypted = aes_128_cbc_with_padding:decrypt(decode_str)
   return decrypted
end

-- Main decryption function
function decrypt(content, encryptAesKey)
    local decoded_key = rsa_decrypted(encryptAesKey)

    if decoded_key == nil then
        ngx.say("Failed to decrypt AES key")
        return nil
    end
    local decrypted_content = aes_decrypted(decoded_key, content)
    return decrypted_content
end
-- Your encrypted content and key
local content = "your encrypt content"
local encryptAesKey = "your aes key code here by java"
-- Call the decrypt function
local decryptedContent = decrypt(content,encryptAesKey)
-- Print the decrypted content
ngx.say(decryptedContent)


```