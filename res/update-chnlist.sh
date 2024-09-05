#!/bin/bash
set -o errexit
set -o pipefail

# Define temporary files
tmp_domains_file=$(mktemp)
tmp_adblock_file=$(mktemp)
tmp_json_file=$(mktemp)
tmp_adblock_json_file=$(mktemp)

# 获取加速的中国域名列表并处理
url='https://raw.githubusercontent.com/felixonmars/dnsmasq-china-list/master/accelerated-domains.china.conf'
curl -4fsSkL "$url" | grep -v -e '^[[:space:]]*$' -e '^[[:space:]]*#' | awk -F/ '{print $2}' | sort | uniq > "$tmp_domains_file"

# 从 adblockdns.txt 获取域名并处理
adblock_url='https://raw.githubusercontent.com/217heidai/adblockfilters/main/rules/adblockdns.txt'
curl -4fsSkL "$adblock_url" | grep '^||.*\^$' | sed 's/^||//;s/\^$//' | sort | uniq > "$tmp_adblock_file"

# 将中国域名列表转化为 JSON
jq -R . < "$tmp_domains_file" | jq -s . > "$tmp_json_file"

# 将 adblock 列表转化为 JSON
jq -R . < "$tmp_adblock_file" | jq -s . > "$tmp_adblock_json_file"

# 创建 chnlist.json 的 JSON 结构
jq -n --slurpfile domains "$tmp_json_file" '{version: 1, rules: [{domain_suffix: $domains[0]}]}' > chnlist.json

# 创建 adblock.json 的 JSON 结构
jq -n --slurpfile adblock_domains "$tmp_adblock_json_file" '{version: 1, rules: [{domain_suffix: $adblock_domains[0]}]}' > adblock.json

# 清理临时文件
rm "$tmp_domains_file" "$tmp_adblock_file" "$tmp_json_file" "$tmp_adblock_json_file"
