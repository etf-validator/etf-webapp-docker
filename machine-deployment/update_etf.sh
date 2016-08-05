#!/bin/bash
#
# Update etf-webapp docker container on a remote machine
#
# Usage: ensure etf-webapp has been deployed with deploy_etf.sh.
#
# Run this script with "bash update_etf.sh <machine name>"
#

cur_dir="$(dirname "$0")"
source "$cur_dir/machine_selection.incl.sh"

echo "Starting update of machine $machine_name - $target_ip"

docker-machine ssh "$machine_name" 'sudo bash -s' < ./recompose_on_machine.sh
echo "$target_ip updated"
if [ "$(uname)" == "Darwin" ]; then
  open http://$target_ip
fi
echo "Bye"
