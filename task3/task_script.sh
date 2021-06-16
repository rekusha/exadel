#!/bin/bash
### task1 (with extra)
sudo apt update
sudo apt install apt-transport-https
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
sudo apt update
sudo apt install -y docker-ce

### task2 (with extra)
sudo docker run -d --name task2 -p 8020:80 httpd
TASK2CONTID=$(docker ps -aqf "name=task2")
sudo docker exec $TASK2CONTID sh -c "echo '<br>rekun alexandr<br>sandbox 2021' >> /usr/local/apache2/htdocs/index.html"


### task3 (with extra)
sudo docker build -t task3extra -f task3dockerfile .
sudo docker run -d --env DEVOPS=changed_value -p 8030:80 --name=task3 task3extra

#docker stop task3
#docker rm task3
#docker rmi task3extra
#docker build -t task3extra -f task3dockerfile .
#docker run -d --env DEVOPS=changed_value -p 8030:80 --name=task3 task3extra

### task 4





