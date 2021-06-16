#!/bin/bash
sudo docker run -d --name task2 -p 8020:80 httpd
TASK2CONTID=$(docker ps -aqf "name=task2")
sudo docker exec $TASK2CONTID sh -c "echo '<br>rekun alexandr<br>sandbox 2021' >> /usr/local/apache2/htdocs/index.html"
