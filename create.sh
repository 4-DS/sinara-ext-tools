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

#if [[ -z "${userName:-}" ]]; then
#  read -p "Please, enter the user: " userName
#fi

#if [[ -z "${userPass:-}" ]]; then
#  read -s -p "Please, enter the password for the given user: " userPass
#fi

#if [[ -z "${runMode:-}" ]]; then
#    read -p "Please, choose a run mod " runMode
#fi

containerName=jovyan-single-use

instanceName="${instanceName:-$containerName}"

runMode="${runMode:-q}"

memRequest="${memRequest:-4g}"
memLimit="${memLimit:-8g}"
#cpuRequest="${cpuRequest:-q}"
cpuLimit="${cpuLimit:-4}"

echo "Please, keep in mind, that Sinara will be running in a quick start mode."

echo "After familiarization, we recommend starting in basic mode via 'bash create.sh --runMode b'"

echo "It will start asking for paths for code (work), data, tmp."

echo "For any run mode, the following compute resources are allocated as if we run it via 'bash create.sh --memRequest 4g --memLimit 8g --cpuLimit 4'"

echo "You can set them by your demand."

echo "You can name your Sinara instance with 'bash create.sh --instanceName your_name' "

echo "And then use that parameter in all other tools to control your instance."

echo "If you want to change the run mode, you need to issue 'remove.sh' in advance."

if [[ ${runMode} == "q" ]]; then
  dataVolume="jovyan-data-${instanceName}"
  workVolume="jovyan-data-${instanceName}"
  tmpVolume="jovyan-data-${instanceName}"

  [[ $(docker volume ls | grep $dataVolume) ]] && echo "Docker volume with jovyan data is found" || docker volume create $dataVolume
  [[ $(docker volume ls | grep $workVolume) ]] && echo "Docker volume with jovyan work is found" || docker volume create $workVolume 
  [[ $(docker volume ls | grep $tmpVolume) ]] && echo "Docker volume with jovyan tmp data is found" || docker volume create $tmpVolume
   
  if [[ $(docker ps -a --filter "status=exited" | grep "$instanceName") ]]; then
  
    echo "Your jovyan single use container is found"; docker start $instanceName
  else
    if [[ $(docker ps | grep "$instanceName") ]]; then
      echo "Your jovyan single use container is already running"
    else
      docker create -p 8888:8888 -p 4040-4060:4040-4060 -v $workVolume:/home/jovyan/work -v $dataVolume:/data -v $tmpVolume:/tmp -e DSML_USER=jovyan \
        --name "$instanceName" \
        --memory-reservation=$memRequest \
        --memory=$memLimit \
        --cpus=$cpuLimit \
        -w /home/jovyan/work \
        buslovaev/sinara-notebook \
        start-notebook.sh \
        --ip=0.0.0.0 \
        --port=8888 \
        --NotebookApp.default_url=/lab \
        --NotebookApp.token='' \
        --NotebookApp.password=''  
     
      echo "Your jovyan single use container is created";
      # fix permissions
	  #docker exec -u 0:0 $instanceName chown -R jovyan /tmp
	  #docker exec -u 0:0 $instanceName chown -R jovyan /data

      # clean tmp if exists
	  #docker exec -u 0:0 $instanceName bash -c 'rm -rf /tmp/*'
    fi
  fi


else
   if [[ ${runMode} == "b" ]]; then
   if [[ -z "${jovyanDataPath:-}" ]]; then
    read -p "Please, choose a jovyan Data path: " jovyanDataPath
   fi   

   if [[ -z "${jovyanWorkPath:-}" ]]; then
    read -p "Please, choose a jovyan Work path: " jovyanWorkPath
   fi

   if [[ -z "${jovyanTmpPath:-}" ]]; then
    read -p "Please, choose a jovyan Tmp path: " jovyanTmpPath
   fi

  
  read -p "Please, ensure that the folders exist: y/n" foldersExist 
  
  if [[ ${foldersExist} == "y" ]]; then 
     echo "Trying to run your environment"
  else
     echo "Sorry, you should prepare the folders beforehand"
     exit 1
  fi
 
  if [[ $(docker ps -a --filter "status=exited" | grep "$instanceName") ]]; then

    echo "Your jovyan single use container is found"; docker start $instanceName
  else
    if [[ $(docker ps | grep "$instanceName") ]]; then
      echo "Your jovyan single use container is already running"
    else
      docker create -p 8888:8888 -p 4040-4060:4040-4060 -v $jovyanWorkPath:/home/jovyan/work -v $jovyanDataPath:/data -v $jovyanTmpPath:/tmp -e DSML_USER=jovyan \
        --name "$instanceName" \
        --memory-reservation=$memRequest \
        --memory=$memLimit \
        --cpus=$cpuLimit \
        -w /home/jovyan/work \
        buslovaev/sinara-notebook \
        start-notebook.sh \
        --ip=0.0.0.0 \
        --port=8888 \
        --NotebookApp.default_url=/lab \
        --NotebookApp.token='' \
        --NotebookApp.password='' 

      echo "Your jovyan single use container is created";
    fi
  fi
  fi
fi

# End
#echo "Please, follow the URL http://127.0.0.1:8888/lab to access your jovyan single use, by using CTRL key"

