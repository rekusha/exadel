#!/bin/bash
sudo docker build -t task3extra -f task3dockerfile .
sudo docker run -d --env DEVOPS=changed_value -p 8030:80 --name=task3 task3extra
