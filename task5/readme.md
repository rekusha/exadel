# Task 5: Jenkins. Автоматизируй, Управляй и Контролируй  
   
## Важные моменты:  
Почитать про Jenkins. Что это такое и для чего он нужен? Способы применения. Что такое императивный и декларативный подход.   
  
## Tasks:  
1. Установить Jenkins (Jenkins должен быть установлен  в Docker контейнере).  
2. Установить необходимые плагины (если потребуются на ваше усмотрение).  
3. Настроить несколько билд агентов.  
4. Создать Freestyle project. Который будет в результате выполнения на экран выводить текущее время.  
5. Создать Pipeline который будет на хосте выполнять команду docker ps -a.  
6. Создать Pipeline который будет выкачивать из вашего репозитория код и будет собирать докер образ из вашего Dockerfile (который вы писали во время знакомства с докером).  
7. Передать переменную PASSWORD=QWERTY! В зашифрованном виде в докер контейнер.  
  
## EXTRA:  
1. Написать pipeline который будет на дополнительной виртуальной машине запускать докер контейнер из вашего докерфайла.  
2. Написать ансибл скрипт который будет разворачивать дженкинс.  
3. Развернуть локальный docker registry загрузить в него докер образ, выгрузить докер образ из docker registry и запустить контейнер на окружении (с использованием Jenkinsfile)  
4. Настроить двухстороннюю интеграцию между Jenkins и вашим Git репозиторием. Jenkins проект будет запускаться автоматически при наличии изменений в вашем репозитории а также в Git будет виден статус последней сборки из дженкинса (успешно/неуспешно/в процессе).  

--------
создаем 4 виртуальных машины ubuntu server 20.04 [host_server, agent_server1, agent_server2, docker_cloud]  

на host_server создаем пару ssh ключей  
ssh-keygen -f ~/.ssh/jenkins_agent_key  
и пересылаем на отсальные машины публичные ключи для дальнейшего подключения через ssh  
ssh-copy-id -i ~/.ssh/jenkins_agent_key user@host  
  
поднимаем на host_server ansible  
заранее написанным плейбуком docker_install_local.yml на хосте ставятся все необходимые зависимости + докер и поднимается докер контейнер с дженкинсом на порту 8080 в виде сервиса для того чтоб при перезагрузке докер с дженкинсом поднимались автоматически

после установки докер контейнера с дженкинсом делаем первую настройку перейдя в браузере по url http://<youJenkinsServerIp>:8080/  
и видим "To ensure Jenkins is securely set up by the administrator, a password has been written to the log (not sure where to find it?) and this file on the server:"   
  
выполняя на хосте $ sudo docker logs jenkins_lts  
```
Jenkins initial setup is required. An admin user has been created and a password generated.
Please use the following password to proceed to installation:

44abbeeb308b43eea3c39011fe6617c71

This may also be found at: /var/jenkins_home/secrets/initialAdminPassword
```
копируем набор цифр и вставляем в форму в браузере  
заполняем данные администратора  
устанавливаем плагины по умолчанию  
  
   
доп плагины: "Manage Jenkins" -> "Manage Plugins" -> "Available" -> "Docker", "Password Mask"  
  
   
создаем креденшиал для подключения к агентам по ssh ранее созданным приватным ключем  
manage jenkins -> manage Credentials -> Add Credentials  
Kind: SSH Username with private key;  
id: hosts  
description: hosts ssh key  
username: <username>  
Private Key: select Enter directly and press the Add button to insert your private key from ~/.ssh/hosts_agent_key  
   
создаем еще пару ключей для агентов и тоже добавляем в кредейншиалы  

в дженкинсе конфигурируем подключение ко всем хостам (host_server, agent_server1, agent_server2, docker_cloud)   
в данный момент у нас исполнители есть на 4х хостах + внутри мастер контейнера с дженкинсом (последнее желательно отключить чтоб ресурсы не распылять)
   
заранее написанным плейбуком docker_install_instance.yml на инстансах (сервер1 и сервер2) ставятся ява + докер  
заранее написанным плейбуком docker_install_instance.yml на docker-cloud ставятся ява + докер  
   
делаем простой 
  
