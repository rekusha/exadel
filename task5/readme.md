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
1. install docker  
```
$ mkdir task5 && cd task5/
$ wget https://raw.githubusercontent.com/rekusha/exadel/master/task3/1.1/docker_install.sh  
$ chmod +x docker_install.sh  
$ sudo ./docker_install.sh  

$ sudo curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
$ sudo chmod +x /usr/local/bin/docker-compose
```
$ mkdir withoutextra && cd withoutextra/  
$ nano docker-compose.yml  
$ docker-compose.yml contains:  
```
version: '3.6'
services:
 jenkins:
  image: "jenkins/jenkins:lts"
  container_name: "jenkins_lts"
  volumes:
  - ./jenkins_home/:/var/jenkins_home
  #network_mode: host
  ports:
  - 8080:8080
  restart: always
```
$ mkdir jenkins_home  
$ sudo chown -R 1000:1000 ./jenkins_home/  
$ tree  
```
.
├── docker_install.sh
└── withoutextra
    ├── docker-compose.yml
    └── jenkins_home
```
$ sudo docker-compose up -d  
```
Creating network "withoutextra_default" with the default driver
Pulling jenkins (jenkins/jenkins:lts)...
lts: Pulling from jenkins/jenkins
d960726af2be: Pull complete
971efeb01290: Pull complete
...
Digest: sha256:99fd3cb74257d1df7678c19106586a2da127cd1b08484c9201c7130d4fab92c1
Status: Downloaded newer image for jenkins/jenkins:lts
Creating task5 ... done
```
next go in web browser to addres http://<youJenkinsServerIp>:8080/  
and see "To ensure Jenkins is securely set up by the administrator, a password has been written to the log (not sure where to find it?) and this file on the server:"  
   
$ sudo docker logs task5  
```
Jenkins initial setup is required. An admin user has been created and a password generated.
Please use the following password to proceed to installation:

44abbeeb308b43eea3c39011fe6617c71

This may also be found at: /var/jenkins_home/secrets/initialAdminPassword
```
enter this string to field in web page to continue  
  
Create First Admin User:  
   name Jenkins_admin1
   password <Password>
   email email@email.email  

-----   
2. install plugins (if need)  
```
install suggest plugin (by default, yet) 
```
   
-----   
3. configure a few build agents  
```

```
