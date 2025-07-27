#!/bin/bash
colors=("orange" "blue" "red" "green" "pink")
echo "测试未来7天的颜色变化："
echo "=========================="
for i in {0..6}; do
    future_date=$(date -v+${i}d +%j)  # macOS语法
    color_index=$((future_date % ${#colors[@]}))
    selected_color=${colors[$color_index]}
    date_str=$(date -v+${i}d +"%Y-%m-%d")
    echo "$date_str: $selected_color"
done
echo ""
echo "当前配置的颜色："
grep "ThemeColor" config.toml 