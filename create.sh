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

runMode="${runMode:-q}"

echo "Please, keep in mind, that Sinara will be running in a quick start mode."

echo "After familiarization, we recommend starting in basic mode via 'bash run_sinara.sh --runMode b'"

echo "It will start asking for paths for code (work), data, tmp."

echo "If you want to change the run mode, you need to issue 'remove.sh' in advance."

containerName=jovyan-single-use

if [[ ${runMode} == "q" ]]; then
   [[ $(docker volume ls | grep jovyan-data) ]] && echo "Docker volume with jovyan data is found" || docker volume create jovyan-data
   [[ $(docker volume ls | grep jovyan-work) ]] && echo "Docker volume with jovyan work is found" || docker volume create jovyan-work

   # TODO
   # need to clean the contents of tmp volume or move to the folders
   # docker inspect --format '{{ range .Mounts }}{{ .Source}}{{"\n"}}{{end}}' jovyan-single-use | grep jovyan-tmp
 
   [[ $(docker volume ls | grep jovyan-tmp) ]] && echo "Docker volume with jovyan tmp data is found"; echo "Need to 'docker volume rm jovyan-tmp -f; docker volume create jovyan-tmp'" || docker volume create jovyan-tmp
   
  if [[ $(docker ps -a --filter "status=exited" | grep "$containerName") ]]; then
  
    echo "Your jovyan single use container is found"; docker start $containerName
  else
    if [[ $(docker ps | grep "$containerName") ]]; then
      echo "Your jovyan single use container is already running"
    else
      docker run -d -p 8888:8888 -p 4040-4060:4040-4060 -v jovyan-work:/home/jovyan/work -v jovyan-data:/data -v jovyan-tmp:/tmp -e DSML_USER=jovyan \
        --name "$containerName" \
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
	docker exec -u 0:0 $containerName chown -R jovyan /tmp
	docker exec -u 0:0 $containerName chown -R jovyan /data

      # clean tmp if exists
	docker exec -u 0:0 $containerName bash -c 'rm -rf /tmp/*'
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
 
  if [[ $(docker ps -a --filter "status=exited" | grep "$containerName") ]]; then

    echo "Your jovyan single use container is found"; docker start $containerName
  else
    if [[ $(docker ps | grep "$containerName") ]]; then
      echo "Your jovyan single use container is already running"
    else
      docker run -d -p 8888:8888 -p 4040-4060:4040-4060 -v $jovyanWorkPath:/home/jovyan/work -v $jovyanDataPath:/data -v $jovyanTmpPath:/tmp -e DSML_USER=jovyan \
        --name "$containerName" \
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
echo "Please, follow the URL http://127.0.0.1:8888/lab to access your jovyan single use, by using CTRL key"

