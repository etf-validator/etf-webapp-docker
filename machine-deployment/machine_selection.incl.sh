if [[ -z $1 ]]; then
    echo "Name of target machine expected"
    exit 1
fi
machine_name=$1

echo "Checking machine status:"
docker-machine status $machine_name || \
  ( echo "Error checking status of machine $machine_name" && exit 1 )

status=$(docker-machine status $machine_name)
if [[ "$status" != "Running" ]]; then
    echo
    docker-machine ls
    echo
    echo "Machine $machine_name is not running!"
    exit 1
fi
target=$(docker-machine url $machine_name)

target_ip=$( echo $target | cut -d'/' -f3 | cut -d':' -f1 )
