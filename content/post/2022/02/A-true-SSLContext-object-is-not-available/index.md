---
title: "A True SSLContext Object Is Not Available"
date: 2022-02-17T19:46:19+08:00
draft: true
tags: ["python2.7","pip"]
---
# windows 下pyhon2.7环境pip install 模块报错A true SSLContext object is not available

> 具体错误代码如下：
  SNIMissingWarning
d:\python27\lib\site-packages\pip\_vendor\urllib3\util\ssl_.py:160: InsecurePlatformWarning: A true SSLContext object is not available. This pre
vents urllib3 from configuring SSL appropriately and may cause certain SSL connections to fail. You can upgrade to a newer version of Python to
solve this. For more information, see https://urllib3.readthedocs.io/en/latest/advanced-usage.html#ssl-warnings
  InsecurePlatformWarning
  Retrying (Retry(total=4, connect=None, read=None, redirect=None, status=None)) after connection broken by 'ReadTimeoutError("HTTPSConnectionPo
ol(host='pypi.org', port=443): Read timed out. (read timeout=15)",)': /simple/ndg-httpsclient/
d:\python27\lib\site-packages\pip\_vendor\urllib3\util\ssl_.py:160: InsecurePlatformWarning: A true SSLContext object is not available. This pre
vents urllib3 from configuring SSL appropriately and may cause certain SSL connections to fail. You can upgrade to a newer version of Python to
solve this. For more information, see https://urllib3.readthedocs.io/en/latest/advanced-usage.html#ssl-warnings
  InsecurePlatformWarning
  Retrying (Retry(total=3, connect=None, read=None, redirect=None, status=None)) after connection broken by 'ReadTimeoutError("HTTPSConnectionPo
ol(host='pypi.org', port=443): Read timed out. (read timeout=15)",)': /simple/ndg-httpsclient/
d:\python27\lib\site-packages\pip\_vendor\urllib3\util\ssl_.py:160: InsecurePlatformWarning: A true SSLContext object is not available. This pre
vents urllib3 from configuring SSL appropriately and may cause certain SSL connections to fail. You can upgrade to a newer version of Python to
solve this. For more information, see https://urllib3.readthedocs.io/en/latest/advanced-usage.html#ssl-warnings
  InsecurePlatformWarning
  Retrying (Retry(total=2, connect=None, read=None, redirect=None, status=None)) after connection broken by 'ReadTimeoutError("HTTPSConnectionPo
ol(host='pypi.org', port=443): Read timed out. (read timeout=15)",)': /simple/ndg-httpsclient/
d:\python27\lib\site-packages\pip\_vendor\urllib3\util\ssl_.py:160: InsecurePlatformWarning: A true SSLContext object is not available. This pre
vents urllib3 from configuring SSL appropriately and may cause certain SSL connections to fail. You can upgrade to a newer version of Python to
solve this. For more information, see https://urllib3.readthedocs.io/en/latest/advanced-usage.html#ssl-warnings
  InsecurePlatformWarning
  Retrying (Retry(total=1, connect=None, read=None, redirect=None, status=None)) after connection broken by 'ReadTimeoutError("HTTPSConnectionPo
ol(host='pypi.org', port=443): Read timed out. (read timeout=15)",)': /simple/ndg-httpsclient/
d:\python27\lib\site-packages\pip\_vendor\urllib3\util\ssl_.py:160: InsecurePlatformWarning: A true SSLContext object is not available. This pre
vents urllib3 from configuring SSL appropriately and may cause certain SSL connections to fail. You can upgrade to a newer version of Python to
solve this. For more information, see https://urllib3.readthedocs.io/en/latest/advanced-usage.html#ssl-warnings
  InsecurePlatformWarning
  Retrying (Retry(total=0, connect=None, read=None, redirect=None, status=None)) after connection broken by 'ReadTimeoutError("HTTPSConnectionPo
ol(host='pypi.org', port=443): Read timed out. (read timeout=15)",)': /simple/ndg-httpsclient/
d:\python27\lib\site-packages\pip\_vendor\urllib3\util\ssl_.py:160: InsecurePlatformWarning: A true SSLContext object is not available. This pre
vents urllib3 from configuring SSL appropriately and may cause certain SSL connections to fail. You can upgrade to a newer version of Python to
solve this. For more information, see https://urllib3.readthedocs.io/en/latest/advanced-usage.html#ssl-warnings
  InsecurePlatformWarning
  Could not find a version that satisfies the requirement ndg-httpsclient (from versions: )
No matching distribution found for ndg-httpsclient
d:\python27\lib\site-packages\pip\_vendor\urllib3\util\ssl_.py:160: InsecurePlatformWarning: A true SSLContext object is not available. This pre
vents urllib3 from configuring SSL appropriately and may cause certain SSL connections to fail. You can upgrade to a newer version of Python to
solve this. For more information, see https://urllib3.readthedocs.io/en/latest/advanced-usage.html#ssl-warnings
  InsecurePlatformWarning

> 解决方法如下，升级python2.7最新版本，在官网找到
  https://www.python.org/downloads/