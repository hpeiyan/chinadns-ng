#!/bin/bash
set -o errexit
set -o pipefail

# exit if curl failed
# url='https://raw.githubusercontent.com/felixonmars/dnsmasq-china-list/master/accelerated-domains.china.conf'
# data="$(curl -4fsSkL "$url" | grep -v -e '^[[:space:]]*$' -e '^[[:space:]]*#')"

# echo "$data" | awk -F/ '{print $2}' | sort | uniq >chnlist.txt

# Define temporary files
tmp_domains_file=$(mktemp)
tmp_json_file=$(mktemp)

# exit if curl failed
url='https://raw.githubusercontent.com/felixonmars/dnsmasq-china-list/master/accelerated-domains.china.conf'
curl -4fsSkL "$url" | grep -v -e '^[[:space:]]*$' -e '^[[:space:]]*#' | awk -F/ '{print $2}' | sort | uniq > "$tmp_domains_file"

# Process domains and format them into JSON using jq
jq -R . < "$tmp_domains_file" | jq -s . > "$tmp_json_file"

# Create the final JSON structure
jq -n --slurpfile domains "$tmp_json_file" '{version: 1, rules: [{domain_suffix: $domains[0]}]}' > chnlist.json

# Clean up temporary files
rm "$tmp_domains_file" "$tmp_json_file"

