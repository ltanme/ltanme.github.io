---
title: "Export Command Data from PhpMyAdmin"
date: 2024-11-04T12:00:00+08:00
draft: false
tags: ["phpmyadmin", "data export", "automation", "python", "Excel"]
---

 

在使用 PhpMyAdmin 时，您可能会遇到一个问题：当某些字段内容较长时，界面无法完整显示这些字段内容，只能看到部分数据。这种情况下，PhpMyAdmin 默认的导出功能可能无法满足需求，因为网页导出的数据也会被截断，手动复制粘贴又非常耗时且容易出错。

因此，我们可以通过编写 Python 脚本直接调用 PhpMyAdmin 的接口，自动化获取完整数据并保存为 Excel 文件。这样做的主要原因包括：

1. **避免手动操作的繁琐**：使用代码可以批量导出数据，无需逐行查看、复制，节省了大量时间。
2. **数据完整性**：直接通过接口请求数据，可以获取字段的完整内容，避免网页显示导致的数据截断问题。
3. **便于分析和存储**：将数据保存到 Excel 文件中，方便后续的分析和归档，也可以作为备份使用。

通过此方法，您可以轻松导出完整的数据库字段信息，不受界面限制，也提高了数据处理的效率。

To solve the issue of PhpMyAdmin's web interface not fully displaying certain fields (especially when fields are too long to display completely), you can use the following method to export complete data. This method utilizes Python and the `requests` and `openpyxl` libraries to retrieve data from PhpMyAdmin and save it to an Excel file. Please note that some sensitive information in the code has been hidden.

### Code Example

```python
import requests
import openpyxl

# Create an Excel file
workbook = openpyxl.Workbook()
sheet = workbook.active
sheet.title = "Command Data"
sheet.append(["ID", "Command Name", "Command Detail"])  # Add headers

# Define base request information
url = "http://[HOST]/sql.php"
headers = {
    "accept": "*/*",
    "accept-encoding": "gzip, deflate",
    "accept-language": "zh-CN,zh;q=0.9,en;q=0.8,en-GB;q=0.7,en-US;q=0.6",
    "cache-control": "no-cache",
    "connection": "keep-alive",
    "content-type": "application/x-www-form-urlencoded; charset=UTF-8",
    "cookie": "[COOKIE_DATA]",
    "host": "[HOST]",
    "origin": "[ORIGIN]",
    "user-agent": "Mozilla/5.0",
    "x-requested-with": "XMLHttpRequest"
}

# Define request data template
data_template = {
    "db": "device_remote_control",
    "ajax_request": "true",
    "grid_edit": "true",
    "_nocache": "[NOCACHE_VALUE]",
    "token": "[TOKEN_VALUE]"
}

# Define query function
def query_command(sql_query, command_id):
    data = data_template.copy()
    data["sql_query"] = sql_query
    print(f"Executing SQL for ID {command_id}: {sql_query}")
    response = requests.post(url, headers=headers, data=data)
    response_json = response.json()
    return response_json.get("value", "")  # Return queried field value

# Loop to query command_name and command_detail from ID 74 to 580
for command_id in range(74, 581):
    command_name_query = f"SELECT command_name FROM `command` WHERE id={command_id}"
    command_detail_query = f"SELECT command_detail FROM `command` WHERE id={command_id}"

    # Query command_name
    command_name = query_command(command_name_query, command_id)

    # Query command_detail
    command_detail = query_command(command_detail_query, command_id)

    # Write to Excel if either value exists
    if command_name or command_detail:
        print(f"Writing to Excel: ID={command_id}, command_name={command_name}, command_detail={command_detail}")
        sheet.append([command_id, command_name, command_detail])

# Save the Excel file
workbook.save("command_data.xlsx")
print("Data successfully written to the Excel file.")
```

### Notes
- **Sensitive Information Hidden**: Be sure to replace placeholder values such as `[HOST]`, `[COOKIE_DATA]`, `[NOCACHE_VALUE]`, and `[TOKEN_VALUE]` with actual values.
- **Customizable Range**: The code loops through command IDs from 74 to 580. Adjust this range as needed.
- **Library Requirements**: Ensure `requests` and `openpyxl` libraries are installed by running:
  ```bash
  pip install requests openpyxl
  ```

This method allows you to automate data retrieval from PhpMyAdmin, avoiding the limitations of its web interface.
```

 
