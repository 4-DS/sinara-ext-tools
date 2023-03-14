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

read -p "Please, enter ENTITY_PATH for your bentoservice: " bentoservicePath 

bentoservice_dir="$(basename $bentoservicePath)"

rm -rf $bentoservice_dir

docker cp $instanceName:/$bentoservicePath .

cd $bentoservice_dir

unzip model.zip
rm -f _SUCCESS
rm -f model.zip
docker build .