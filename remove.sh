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

runMode="${withVolumes:-no}"

echo "Please, keep in mind, that 'remove.sh' will not delete any volumes by default."
echo "To delete volumes use '--withVolumes yes'"
echo "Your custom folders will never be deleted"

containerName=jovyan-single-use

docker stop $containerName

if [[ ${withVolumes} == "yes" ]]; then
   [[ $(docker volume ls | grep jovyan-data) ]] && echo "Docker volume with jovyan data is found. Removing it.."; docker volume rm -f jovyan-data
   [[ $(docker volume ls | grep jovyan-work) ]] && echo "Docker volume with jovyan work is found. Removing it.."; docker volume rm -f jovyan-work 
   [[ $(docker volume ls | grep jovyan-tmp) ]] && echo "Docker volume with jovyan tmp data is found. Removing it.."; docker volume rm -f jovyan-tmp
 