#!/bin/bash

cur_dir="$(dirname "$0")"
source "$cur_dir/machine_selection.incl.sh"

log_file="status_log_${machine_name}.json"

auth=""
if [[ -n "$2" ]]; then
  auth="-u ${2}"
fi
echo $auth

target_url="http://${target_ip}/etf-webapp/v0/admin/status"

echo "{\"entries\":[" > $log_file
curl --fail $auth "$target_url" >> $log_file || exit 1

function closeJson {
  echo "]}" >> $log_file
}
trap closeJson EXIT

while true
do
  sleep 20
  echo "," >> $log_file
  curl $auth "$target_url" >> $log_file
done
