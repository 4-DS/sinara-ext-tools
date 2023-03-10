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
 
if [[ $(docker ps -a --filter "status=exited" | grep "$instanceName") ]]; then
  
    echo "Your jovyan single use container is found. It is stopped.";
else
    if [[ $(docker ps | grep "$instanceName") ]]; then
      echo "Your jovyan single use container is running. Stopping it.."; docker stop $instanceName
    fi
fi

if [[ $(docker ps -a --filter "status=exited" | grep "$instanceName") ]]; then
    echo "Your jovyan single use container is successfully stopped. "
else
    echo "Your jovyan single use container is not found."
fi