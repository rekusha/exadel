# Task 3: Docker
 
## Docs:
1. Read documentation about docker (https://docs.docker.com/)
 
## Tasks:
1. Install docker. (Hint: please use VMs or Clouds  for this.) <br> **EXTRA** 1.1. Write bash script for install Docker 
 
2. Find, download and run any docker container "hello world". (Learn commands and parameters to create/run docker containers.
**EXTRA** 2.1. Use image with html page, edit html page and paste text: <Username> Sandbox 2021
 
3. 1. Create your Dockerfile for building a docker image. Your docker image should run any web application (nginx, apache, httpd). Web application should be located inside the docker image. <br> **EXTRA** 3.1.2. For creating docker image use clear basic images (ubuntu, centos, alpine, etc.)
   1. Add an environment variable "DEVOPS=<username> to your docker image<br> **EXTRA** 3.2.1. Print environment variable with the value on a web page (if environment variable changed after container restart - the web page must be updated with a new value)
 
4. Push your docker image to docker hub (https://hub.docker.com/). Create any description for your Docker image. <br> **EXTRA** 4.1. Integrate your docker image and your github repository. Create an automatic deployment for each push.
 
5.  Create docker-compose file. Deploy a few docker containers via one docker-compose file. 
  * first image - your docker image from the previous step. 5 nodes of the first image should be run;
  * second image - any java application;
  * last image - any database image (mysql, postgresql, mongo or etc.).
  Second container should be run right after a successful run of a database container.<br> **EXTRA** 5.1. Use env files to configure each service.

 
The task results is the docker/docker-compose files in your GitHub repository
