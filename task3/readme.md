# Task 3: Docker
 
## Docs:
1. Read documentation about docker (https://docs.docker.com/)
 
## Tasks:
1. Install docker. (Hint: please use VMs or Clouds  for this.) <br> **EXTRA** 1.1. Write bash script for install Docker 
 
2. Find, download and run any docker container "hello world". (Learn commands and parameters to create/run docker containers.<br> **EXTRA** 2.1. Use image with html page, edit html page and paste text: <Username> Sandbox 2021
 
3. 1. Create your Dockerfile for building a docker image. Your docker image should run any web application (nginx, apache, httpd). Web application should be located inside the docker image. <br> **EXTRA** 3.1.2. For creating docker image use clear basic images (ubuntu, centos, alpine, etc.)
   1. Add an environment variable "DEVOPS=<username> to your docker image<br> **EXTRA** 3.2.1. Print environment variable with the value on a web page (if environment variable changed after container restart - the web page must be updated with a new value)
 
4. Push your docker image to docker hub (https://hub.docker.com/). Create any description for your Docker image. <br> **EXTRA** 4.1. Integrate your docker image and your github repository. Create an automatic deployment for each push.
 
5.  Create docker-compose file. Deploy a few docker containers via one docker-compose file. 
  * first image - your docker image from the previous step. 5 nodes of the first image should be run;
  * second image - any java application;
  * last image - any database image (mysql, postgresql, mongo or etc.).
  Second container should be run right after a successful run of a database container.<br> **EXTRA** 5.1. Use env files to configure each service.

 
The task results is the docker/docker-compose files in your GitHub repository

 -------------------------
 answer:  

  task 1:  
   \# apt update  
   \# apt install docker   
   
  task 1.1  
   \# ./docker_install.sh  
   in docker_install.sh contains:  
```
#!/bin/bash
apt update
apt-get install apt-transport-https ca-certificates curl gnupg lsb-release -y
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
$(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

apt-get update && apt-get install docker-ce docker-ce-cli containerd.io -y

systemctl start docker && systemctl enable docker
```

  task 2:  
    docker run hello-world --name task2

  task 2.1:  
    ./task2extra.sh  
```
#!/bin/bash
sudo docker run -d --name task21 -p 8021:80 httpd
TASK2CONTID=$(docker ps -aqf "name=task21")
sudo docker exec $TASK2CONTID sh -c "echo '<br>rekun alexandr<br>sandbox 2021' >> /usr/local/apache2/htdocs/index.html"
```

```
$ curl http://127.0.0.1:8021 
<html><body><h1>It works!</h1></body></html>
<br>rekun alexandr<br>sandbox 2021
```
 
  task 3.1/3.2:  
    \# docker build -t task3extra -f task3dockerfile .  
    \# docker run -d --env DEVOPS=changed_value -p 8030:80 --name=task3 task3extra
```
# docker ps
CONTAINER ID   IMAGE        COMMAND                  CREATED          STATUS          PORTS                                   NAMES
3c3ea0b629f7   task3extra   "/bin/sh -c ./task3w…"   12 seconds ago   Up 11 seconds   0.0.0.0:8030->80/tcp, :::8030->80/tcp   task3
```
```
$ curl http://127.0.0.1:8030
Alexandr Rekun<br>Sandbox 2021<br>env DEVOPS = changed_value
```
  task 4:  
    \# docker pull rekusha/devopspractice  
  
  task4.1:  
    новый акк на докер хабе ругается и не хочет даром делать ничего  
    {"error": "Automated Build only available on a Pro or Team plan"}  
  
  task5.1:  
 \# docker build -t japp -f java_app .    
 \# docker-compose --compatibility up -d  
 
```
Creating network "5_default" with the default driver
Creating postgres ... done
Creating 5_from_task4_1 ... done
Creating 5_java_task5_1 ... done
Creating 5_java_task5_2 ... done
Creating 5_java_task5_3 ... done
Creating 5_java_task5_4 ... done
Creating 5_java_task5_5 ... done
```
 
