#!/bin/bash
#set -euxo pipefail
set -euo pipefail
# Parse arguments
while [ $# -gt 0 ]; do
    if [[ $1 == *"--"* ]]; then
        v="${1/--/}"
        declare $v="$2"
    fi
    shift
done

containerName=jovyan-single-use

instanceName="${instanceName:-$containerName}"

 
if [[ $(docker ps -a --filter "status=created" | grep "$instanceName") ]]; then
  
    echo "Your jovyan single use container is created. Start it.."; docker start $instanceName
else
    if [[ $(docker ps -a --filter "status=exited" | grep "$instanceName") ]]; then
  
        echo "Your jovyan single use container is stopped. Start it.."; docker start $instanceName
    else
        if [[ $(docker ps | grep "$instanceName") ]]; then
        echo "Your jovyan single use container is already running"

        fi
    fi
fi

if [[ ! $(docker ps | grep "$instanceName") ]]; then
      echo "Your jovyan single use container is not found. Please, create it with 'create.sh' "
else
    # fix permissions
	docker exec -u 0:0 $instanceName chown -R jovyan /tmp
	docker exec -u 0:0 $instanceName chown -R jovyan /data

    # clean tmp if exists
	docker exec -u 0:0 $instanceName bash -c 'rm -rf /tmp/*'

    echo "Please, follow the URL http://127.0.0.1:8888/lab to access your jovyan single use, by using CTRL key"
fi
