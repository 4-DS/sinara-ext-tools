containerName=jovyan-single-use

 
if [[ $(docker ps -a --filter "status=exited" | grep "$containerName") ]]; then
  
    echo "Your jovyan single use container is found. It is stopped.";
else
    if [[ $(docker ps | grep "$containerName") ]]; then
      echo "Your jovyan single use container is running. Stopping it.."; docker stop $containerName
    fi
fi

if [[ $(docker ps -a --filter "status=exited" | grep "$containerName") ]]; then
      echo "Your jovyan single use container is successfully stopped. "

fi