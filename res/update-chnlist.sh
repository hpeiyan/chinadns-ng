# exit if curl failed
# url='https://raw.githubusercontent.com/felixonmars/dnsmasq-china-list/master/accelerated-domains.china.conf'
# data="$(curl -4fsSkL "$url" | grep -v -e '^[[:space:]]*$' -e '^[[:space:]]*#')"

# echo "$data" | awk -F/ '{print $2}' | sort | uniq >chnlist.txt

#!/bin/bash
set -o errexit
set -o pipefail

# exit if curl failed
url='https://raw.githubusercontent.com/felixonmars/dnsmasq-china-list/master/accelerated-domains.china.conf'
data="$(curl -4fsSkL "$url" | grep -v -e '^[[:space:]]*$' -e '^[[:space:]]*#')"

# Extract domain, sort, remove duplicates, and format as JSON array
domains=$(echo "$data" | awk -F/ '{print $2}' | sort | uniq | jq -R . | jq -s .)

# Create JSON structure
json_output=$(jq -n --argjson domains "$domains" '{version: 1, rules: [{domain_suffix: $domains}]}')

# Output JSON to file
echo "$json_output" > chnlist.json

