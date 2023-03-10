containerName=jovyan-single-use

 
if [[ $(docker ps -a --filter "status=exited" | grep "$containerName") ]]; then
  
    echo "Your jovyan single use container is found"; docker start $containerName
  else
    if [[ $(docker ps | grep "$containerName") ]]; then
      echo "Your jovyan single use container is already running"
    fi
fi

echo "Please, follow the URL http://127.0.0.1:8888/lab to access your jovyan single use, by using CTRL key"
