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
   
на машине docker-cloud  
вносим инебольшие изменения в конфигурацию докера  
sudo nano /lib/systemd/system/docker.service  

и в строке ExecStart добавляем -H=tcp://0.0.0.0:2375 чтоб получилось что то похожее на ExecStart=/usr/bin/dockerd -H=fd:// -H=tcp://0.0.0.0:2375 ...  
сохраняем изменения и выходим  
перезапускаем докер демона $ sudo systemctl daemon-reload  
перезапускаем сам докер $ sudo service docker restart  
если все верно сделано то curl http://localhost:2375/images/json отдаст нам в ответ [] если нет образов, иначе даста инфу по образам в json формате  
на машине docker-cloud на этом настройка закончена  
   
agent_server1 и agent_server2 готовы сразу после выполнения на них действий ансиблом (см. выше)  
   
---------------  
подготовительная часть закончена приступаем к выполнению заданий  
1. Установить Jenkins (Jenkins должен быть установлен  в Docker контейнере). - выполнено на этапе подготовки  
2. Установить необходимые плагины (если потребуются на ваше усмотрение). - выполнено на этапе подготовки   
3. Настроить несколько билд агентов. 
   для создания билд агентов на agent_server1 и agent_server2 создаем фристайл проект который выполнить на обоих хостах шелл комманды  
   sudo docker run -d --rm --name=agent1 -p 2001:22 bibinwilson/jenkins-slave:latest  
   sudo docker run -d --rm --name=agent2 -p 2002:22 bibinwilson/jenkins-slave:latest   
   после чего у нас на каждом хосте будет подняты контейнеры с именами агент1 и агент2 и портами подключения 2001 и 2002 соответственно  
   в дженкинсе Dashboard -> Nodes -> New Node   
   указываем данные подключения к каждому из агентов не забывая изменить стандартные порты для подключения по ssh  
   по итогу должо получится 4 агента (по два контейнера на хосте)  
     
   далее Dashboard -> Nodes -> Configure Clouds  
   именуем наш конфиг как docker-cloud  
   в cloud config указываем tcp://<docker_cloud-name/ip>:2375 и максимальное число исполняемых контейнеров (у меня 5)  
   в Docker Agent templates указываем образ который будем использовать для работы в облаке и его лэйблы (не забывать про данные подключения)  
   преимущество облачной реализации в том, что она поднимает образы исполняет на них нужное и останавливает образы сама  
   если образов будет несколько то выберет тот который соответствует лэйблу задания
   
   ! в списке нод облачные контейнеры не отображаются на постоянной основе, их можно увидеть только когда облако начинает обработку и создает для этого ноду !  
     

4. Создать Freestyle project. Который будет в результате выполнения на экран выводить текущее время.  
простой проект - выполнить команду shell  
```
sh -c date
```
на выходе должны получить  
```
Started by user rekusha
Running as SYSTEM
Building remotely on java-docker-slave-00000m6ca64y3 on docker-cloud1 (java-docker-slave) in workspace /home/jenkins/workspace/cloud test with time
[cloud test with time] $ /bin/sh -xe /tmp/jenkins246060738662144517.sh
+ sh -c date
Sun Jun 27 23:51:21 UTC 2021
Finished: SUCCESS
```
5. Создать Pipeline который будет на хосте выполнять команду docker ps -a.  
   создать айтем - пайплайн  
```
   pipeline {
    agent {label 'master-host'}
    stages {
        stage('do it') {
            steps {
                sh '''
                  sudo docker ps -a
                '''  
            }
        }
    }
}
```
   на выходе  
```
Started by user rekusha
Running in Durability level: MAX_SURVIVABILITY
[Pipeline] Start of Pipeline
[Pipeline] node
Running on master-host in /home/rekusha/tmp/workspace/pipeline at host docker ps -a
[Pipeline] {
[Pipeline] stage
[Pipeline] { (do it)
[Pipeline] sh
+ sudo docker ps -a
CONTAINER ID   IMAGE             COMMAND                  CREATED        STATUS       PORTS                                              NAMES
f8fe021b028a   jenkins/jenkins   "/sbin/tini -- /usr/…"   21 hours ago   Up 3 hours   0.0.0.0:8080->8080/tcp, 0.0.0.0:50000->50000/tcp   jenkins-server
[Pipeline] }
[Pipeline] // stage
[Pipeline] }
[Pipeline] // node
[Pipeline] End of Pipeline
Finished: SUCCESS
```
6. Создать Pipeline который будет выкачивать из вашего репозитория код и будет собирать докер образ из вашего Dockerfile (который вы писали во время знакомства с докером).  
   создать айтем - пайплайн 
```
pipeline {
    agent { label 'slave-host'}
    stages {
        stage('task5.6') {
            steps {
                git url: 'https://github.com/rekusha/exadel.git'
                sh '''
                  cd task3/3
                  sudo docker image build -t task3extra:fromjenkinspipeline -f task3dockerfile .
                  sudo docker images
                '''  
            }
        }
    }
}   
```
на выходе   
```
Started by user rekusha
Running in Durability level: MAX_SURVIVABILITY
[Pipeline] Start of Pipeline
[Pipeline] node
Running on slave-host-2 in /home/rekusha/workspace/task5.6
[Pipeline] {
[Pipeline] stage
[Pipeline] { (task5.6)
[Pipeline] git
The recommended git tool is: NONE
No credentials specified
Fetching changes from the remote Git repository
Checking out Revision 5bf959bd76d4035d6c3daa7391c1c6e8383030dd (refs/remotes/origin/master)
Commit message: "Update readme.md"
 > git rev-parse --resolve-git-dir /home/rekusha/workspace/task5.6/.git # timeout=10
 > git config remote.origin.url https://github.com/rekusha/exadel.git # timeout=10
Fetching upstream changes from https://github.com/rekusha/exadel.git
 > git --version # timeout=10
 > git --version # 'git version 2.25.1'
 > git fetch --tags --force --progress -- https://github.com/rekusha/exadel.git +refs/heads/*:refs/remotes/origin/* # timeout=10
 > git rev-parse refs/remotes/origin/master^{commit} # timeout=10
 > git config core.sparsecheckout # timeout=10
 > git checkout -f 5bf959bd76d4035d6c3daa7391c1c6e8383030dd # timeout=10
 > git branch -a -v --no-abbrev # timeout=10
 > git branch -D master # timeout=10
 > git checkout -b master 5bf959bd76d4035d6c3daa7391c1c6e8383030dd # timeout=10
 > git rev-list --no-walk 5bf959bd76d4035d6c3daa7391c1c6e8383030dd # timeout=10
[Pipeline] sh
+ cd task3/3
+ sudo docker image build -t task3extra:fromjenkinspipeline -f task3dockerfile .
Sending build context to Docker daemon  5.632kB

Step 1/16 : FROM ubuntu:20.04
20.04: Pulling from library/ubuntu
c549ccf8d472: Pulling fs layer
c549ccf8d472: Verifying Checksum
c549ccf8d472: Download complete
c549ccf8d472: Pull complete
Digest: sha256:aba80b77e27148d99c034a987e7da3a287ed455390352663418c0f2ed40417fe
Status: Downloaded newer image for ubuntu:20.04
 ---> 9873176a8ff5
Step 2/16 : MAINTAINER Alexandr Rekun
 ---> Running in 29dae8f4c29d
Removing intermediate container 29dae8f4c29d
 ---> 50c1bef9f8c5
Step 3/16 : ENV TZ=Europe/Kiev
 ---> Running in 4b5a3120b3d8
Removing intermediate container 4b5a3120b3d8
 ---> 8fc47f902f70
Step 4/16 : RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone
 ---> Running in bf36ec78c789
Removing intermediate container bf36ec78c789
 ---> f3d095dc7ce4
Step 5/16 : RUN apt-get update && apt-get install -y apache2
 ---> Running in db365ac0d192
Get:1 http://archive.ubuntu.com/ubuntu focal InRelease [265 kB]
Get:2 http://archive.ubuntu.com/ubuntu focal-updates InRelease [114 kB]
Get:3 http://archive.ubuntu.com/ubuntu focal-backports InRelease [101 kB]
Get:4 http://archive.ubuntu.com/ubuntu focal/main amd64 Packages [1275 kB]
Get:5 http://security.ubuntu.com/ubuntu focal-security InRelease [114 kB]
Get:6 http://archive.ubuntu.com/ubuntu focal/multiverse amd64 Packages [177 kB]
Get:7 http://archive.ubuntu.com/ubuntu focal/restricted amd64 Packages [33.4 kB]
Get:8 http://archive.ubuntu.com/ubuntu focal/universe amd64 Packages [11.3 MB]
Get:9 http://archive.ubuntu.com/ubuntu focal-updates/restricted amd64 Packages [411 kB]
Get:10 http://archive.ubuntu.com/ubuntu focal-updates/main amd64 Packages [1356 kB]
Get:11 http://archive.ubuntu.com/ubuntu focal-updates/universe amd64 Packages [1032 kB]
Get:12 http://archive.ubuntu.com/ubuntu focal-updates/multiverse amd64 Packages [32.0 kB]
Get:13 http://archive.ubuntu.com/ubuntu focal-backports/universe amd64 Packages [4305 B]
Get:14 http://security.ubuntu.com/ubuntu focal-security/multiverse amd64 Packages [27.6 kB]
Get:15 http://security.ubuntu.com/ubuntu focal-security/restricted amd64 Packages [368 kB]
Get:16 http://security.ubuntu.com/ubuntu focal-security/universe amd64 Packages [777 kB]
Get:17 http://security.ubuntu.com/ubuntu focal-security/main amd64 Packages [925 kB]
Fetched 18.4 MB in 2s (8028 kB/s)
Reading package lists...
Reading package lists...
Building dependency tree...
Reading state information...
The following additional packages will be installed:
  apache2-bin apache2-data apache2-utils ca-certificates file krb5-locales
  libapr1 libaprutil1 libaprutil1-dbd-sqlite3 libaprutil1-ldap
  libasn1-8-heimdal libbrotli1 libcurl4 libexpat1 libgdbm-compat4 libgdbm6
  libgssapi-krb5-2 libgssapi3-heimdal libhcrypto4-heimdal libheimbase1-heimdal
  libheimntlm0-heimdal libhx509-5-heimdal libicu66 libjansson4 libk5crypto3
  libkeyutils1 libkrb5-26-heimdal libkrb5-3 libkrb5support0 libldap-2.4-2
  libldap-common liblua5.2-0 libmagic-mgc libmagic1 libnghttp2-14 libperl5.30
  libpsl5 libroken18-heimdal librtmp1 libsasl2-2 libsasl2-modules
  libsasl2-modules-db libsqlite3-0 libssh-4 libssl1.1 libwind0-heimdal libxml2
  mime-support netbase openssl perl perl-modules-5.30 publicsuffix ssl-cert
  tzdata xz-utils
Suggested packages:
  apache2-doc apache2-suexec-pristine | apache2-suexec-custom www-browser ufw
  gdbm-l10n krb5-doc krb5-user libsasl2-modules-gssapi-mit
  | libsasl2-modules-gssapi-heimdal libsasl2-modules-ldap libsasl2-modules-otp
  libsasl2-modules-sql perl-doc libterm-readline-gnu-perl
  | libterm-readline-perl-perl make libb-debug-perl liblocale-codes-perl
  openssl-blacklist
The following NEW packages will be installed:
  apache2 apache2-bin apache2-data apache2-utils ca-certificates file
  krb5-locales libapr1 libaprutil1 libaprutil1-dbd-sqlite3 libaprutil1-ldap
  libasn1-8-heimdal libbrotli1 libcurl4 libexpat1 libgdbm-compat4 libgdbm6
  libgssapi-krb5-2 libgssapi3-heimdal libhcrypto4-heimdal libheimbase1-heimdal
  libheimntlm0-heimdal libhx509-5-heimdal libicu66 libjansson4 libk5crypto3
  libkeyutils1 libkrb5-26-heimdal libkrb5-3 libkrb5support0 libldap-2.4-2
  libldap-common liblua5.2-0 libmagic-mgc libmagic1 libnghttp2-14 libperl5.30
  libpsl5 libroken18-heimdal librtmp1 libsasl2-2 libsasl2-modules
  libsasl2-modules-db libsqlite3-0 libssh-4 libssl1.1 libwind0-heimdal libxml2
  mime-support netbase openssl perl perl-modules-5.30 publicsuffix ssl-cert
  tzdata xz-utils
0 upgraded, 57 newly installed, 0 to remove and 9 not upgraded.
Need to get 24.1 MB of archives.
After this operation, 117 MB of additional disk space will be used.
Get:1 http://archive.ubuntu.com/ubuntu focal-updates/main amd64 perl-modules-5.30 all 5.30.0-9ubuntu0.2 [2738 kB]
Get:2 http://archive.ubuntu.com/ubuntu focal/main amd64 libgdbm6 amd64 1.18.1-5 [27.4 kB]
Get:3 http://archive.ubuntu.com/ubuntu focal/main amd64 libgdbm-compat4 amd64 1.18.1-5 [6244 B]
Get:4 http://archive.ubuntu.com/ubuntu focal-updates/main amd64 libperl5.30 amd64 5.30.0-9ubuntu0.2 [3952 kB]
Get:5 http://archive.ubuntu.com/ubuntu focal-updates/main amd64 perl amd64 5.30.0-9ubuntu0.2 [224 kB]
Get:6 http://archive.ubuntu.com/ubuntu focal/main amd64 libapr1 amd64 1.6.5-1ubuntu1 [91.4 kB]
Get:7 http://archive.ubuntu.com/ubuntu focal/main amd64 libexpat1 amd64 2.2.9-1build1 [73.3 kB]
Get:8 http://archive.ubuntu.com/ubuntu focal-updates/main amd64 libssl1.1 amd64 1.1.1f-1ubuntu2.4 [1319 kB]
Get:9 http://archive.ubuntu.com/ubuntu focal/main amd64 libaprutil1 amd64 1.6.1-4ubuntu2 [84.7 kB]
Get:10 http://archive.ubuntu.com/ubuntu focal-updates/main amd64 libsqlite3-0 amd64 3.31.1-4ubuntu0.2 [549 kB]
Get:11 http://archive.ubuntu.com/ubuntu focal/main amd64 libaprutil1-dbd-sqlite3 amd64 1.6.1-4ubuntu2 [10.5 kB]
Get:12 http://archive.ubuntu.com/ubuntu focal/main amd64 libroken18-heimdal amd64 7.7.0+dfsg-1ubuntu1 [41.8 kB]
Get:13 http://archive.ubuntu.com/ubuntu focal/main amd64 libasn1-8-heimdal amd64 7.7.0+dfsg-1ubuntu1 [181 kB]
Get:14 http://archive.ubuntu.com/ubuntu focal/main amd64 libheimbase1-heimdal amd64 7.7.0+dfsg-1ubuntu1 [29.7 kB]
Get:15 http://archive.ubuntu.com/ubuntu focal/main amd64 libhcrypto4-heimdal amd64 7.7.0+dfsg-1ubuntu1 [87.9 kB]
Get:16 http://archive.ubuntu.com/ubuntu focal/main amd64 libwind0-heimdal amd64 7.7.0+dfsg-1ubuntu1 [48.0 kB]
Get:17 http://archive.ubuntu.com/ubuntu focal/main amd64 libhx509-5-heimdal amd64 7.7.0+dfsg-1ubuntu1 [107 kB]
Get:18 http://archive.ubuntu.com/ubuntu focal/main amd64 libkrb5-26-heimdal amd64 7.7.0+dfsg-1ubuntu1 [208 kB]
Get:19 http://archive.ubuntu.com/ubuntu focal/main amd64 libheimntlm0-heimdal amd64 7.7.0+dfsg-1ubuntu1 [15.1 kB]
Get:20 http://archive.ubuntu.com/ubuntu focal/main amd64 libgssapi3-heimdal amd64 7.7.0+dfsg-1ubuntu1 [96.1 kB]
Get:21 http://archive.ubuntu.com/ubuntu focal/main amd64 libsasl2-modules-db amd64 2.1.27+dfsg-2 [14.9 kB]
Get:22 http://archive.ubuntu.com/ubuntu focal/main amd64 libsasl2-2 amd64 2.1.27+dfsg-2 [49.3 kB]
Get:23 http://archive.ubuntu.com/ubuntu focal-updates/main amd64 libldap-common all 2.4.49+dfsg-2ubuntu1.8 [16.6 kB]
Get:24 http://archive.ubuntu.com/ubuntu focal-updates/main amd64 libldap-2.4-2 amd64 2.4.49+dfsg-2ubuntu1.8 [155 kB]
Get:25 http://archive.ubuntu.com/ubuntu focal/main amd64 libaprutil1-ldap amd64 1.6.1-4ubuntu2 [8736 B]
Get:26 http://archive.ubuntu.com/ubuntu focal-updates/main amd64 libbrotli1 amd64 1.0.7-6ubuntu0.1 [267 kB]
Get:27 http://archive.ubuntu.com/ubuntu focal-updates/main amd64 libkrb5support0 amd64 1.17-6ubuntu4.1 [30.9 kB]
Get:28 http://archive.ubuntu.com/ubuntu focal-updates/main amd64 libk5crypto3 amd64 1.17-6ubuntu4.1 [79.9 kB]
Get:29 http://archive.ubuntu.com/ubuntu focal/main amd64 libkeyutils1 amd64 1.6-6ubuntu1 [10.2 kB]
Get:30 http://archive.ubuntu.com/ubuntu focal-updates/main amd64 libkrb5-3 amd64 1.17-6ubuntu4.1 [330 kB]
Get:31 http://archive.ubuntu.com/ubuntu focal-updates/main amd64 libgssapi-krb5-2 amd64 1.17-6ubuntu4.1 [121 kB]
Get:32 http://archive.ubuntu.com/ubuntu focal/main amd64 libnghttp2-14 amd64 1.40.0-1build1 [78.7 kB]
Get:33 http://archive.ubuntu.com/ubuntu focal/main amd64 libpsl5 amd64 0.21.0-1ubuntu1 [51.5 kB]
Get:34 http://archive.ubuntu.com/ubuntu focal/main amd64 librtmp1 amd64 2.4+20151223.gitfa8646d.1-2build1 [54.9 kB]
Get:35 http://archive.ubuntu.com/ubuntu focal-updates/main amd64 libssh-4 amd64 0.9.3-2ubuntu2.1 [170 kB]
Get:36 http://archive.ubuntu.com/ubuntu focal-updates/main amd64 libcurl4 amd64 7.68.0-1ubuntu2.5 [234 kB]
Get:37 http://archive.ubuntu.com/ubuntu focal/main amd64 libjansson4 amd64 2.12-1build1 [28.9 kB]
Get:38 http://archive.ubuntu.com/ubuntu focal/main amd64 liblua5.2-0 amd64 5.2.4-1.1build3 [106 kB]
Get:39 http://archive.ubuntu.com/ubuntu focal-updates/main amd64 tzdata all 2021a-0ubuntu0.20.04 [295 kB]
Get:40 http://archive.ubuntu.com/ubuntu focal/main amd64 libicu66 amd64 66.1-2ubuntu2 [8520 kB]
Get:41 http://archive.ubuntu.com/ubuntu focal-updates/main amd64 libxml2 amd64 2.9.10+dfsg-5ubuntu0.20.04.1 [640 kB]
Get:42 http://archive.ubuntu.com/ubuntu focal-updates/main amd64 apache2-bin amd64 2.4.41-4ubuntu3.3 [1179 kB]
Get:43 http://archive.ubuntu.com/ubuntu focal-updates/main amd64 apache2-data all 2.4.41-4ubuntu3.3 [159 kB]
Get:44 http://archive.ubuntu.com/ubuntu focal-updates/main amd64 apache2-utils amd64 2.4.41-4ubuntu3.3 [84.0 kB]
Get:45 http://archive.ubuntu.com/ubuntu focal/main amd64 mime-support all 3.64ubuntu1 [30.6 kB]
Get:46 http://archive.ubuntu.com/ubuntu focal-updates/main amd64 apache2 amd64 2.4.41-4ubuntu3.3 [95.5 kB]
Get:47 http://archive.ubuntu.com/ubuntu focal-updates/main amd64 openssl amd64 1.1.1f-1ubuntu2.4 [620 kB]
Get:48 http://archive.ubuntu.com/ubuntu focal-updates/main amd64 ca-certificates all 20210119~20.04.1 [146 kB]
Get:49 http://archive.ubuntu.com/ubuntu focal/main amd64 libmagic-mgc amd64 1:5.38-4 [218 kB]
Get:50 http://archive.ubuntu.com/ubuntu focal/main amd64 libmagic1 amd64 1:5.38-4 [75.9 kB]
Get:51 http://archive.ubuntu.com/ubuntu focal/main amd64 file amd64 1:5.38-4 [23.3 kB]
Get:52 http://archive.ubuntu.com/ubuntu focal/main amd64 netbase all 6.1 [13.1 kB]
Get:53 http://archive.ubuntu.com/ubuntu focal-updates/main amd64 xz-utils amd64 5.2.4-1ubuntu1 [82.5 kB]
Get:54 http://archive.ubuntu.com/ubuntu focal-updates/main amd64 krb5-locales all 1.17-6ubuntu4.1 [11.4 kB]
Get:55 http://archive.ubuntu.com/ubuntu focal/main amd64 publicsuffix all 20200303.0012-1 [111 kB]
Get:56 http://archive.ubuntu.com/ubuntu focal/main amd64 libsasl2-modules amd64 2.1.27+dfsg-2 [49.1 kB]
Get:57 http://archive.ubuntu.com/ubuntu focal/main amd64 ssl-cert all 1.0.39 [17.0 kB]
[91mdebconf: delaying package configuration, since apt-utils is not installed
[0mFetched 24.1 MB in 1s (16.4 MB/s)
Selecting previously unselected package perl-modules-5.30.
(Reading database ... 
(Reading database ... 5%
(Reading database ... 10%
(Reading database ... 15%
(Reading database ... 20%
(Reading database ... 25%
(Reading database ... 30%
(Reading database ... 35%
(Reading database ... 40%
(Reading database ... 45%
(Reading database ... 50%
(Reading database ... 55%
(Reading database ... 60%
(Reading database ... 65%
(Reading database ... 70%
(Reading database ... 75%
(Reading database ... 80%
(Reading database ... 85%
(Reading database ... 90%
(Reading database ... 95%
(Reading database ... 100%
(Reading database ... 4127 files and directories currently installed.)
Preparing to unpack .../00-perl-modules-5.30_5.30.0-9ubuntu0.2_all.deb ...
Unpacking perl-modules-5.30 (5.30.0-9ubuntu0.2) ...
Selecting previously unselected package libgdbm6:amd64.
Preparing to unpack .../01-libgdbm6_1.18.1-5_amd64.deb ...
Unpacking libgdbm6:amd64 (1.18.1-5) ...
Selecting previously unselected package libgdbm-compat4:amd64.
Preparing to unpack .../02-libgdbm-compat4_1.18.1-5_amd64.deb ...
Unpacking libgdbm-compat4:amd64 (1.18.1-5) ...
Selecting previously unselected package libperl5.30:amd64.
Preparing to unpack .../03-libperl5.30_5.30.0-9ubuntu0.2_amd64.deb ...
Unpacking libperl5.30:amd64 (5.30.0-9ubuntu0.2) ...
Selecting previously unselected package perl.
Preparing to unpack .../04-perl_5.30.0-9ubuntu0.2_amd64.deb ...
Unpacking perl (5.30.0-9ubuntu0.2) ...
Selecting previously unselected package libapr1:amd64.
Preparing to unpack .../05-libapr1_1.6.5-1ubuntu1_amd64.deb ...
Unpacking libapr1:amd64 (1.6.5-1ubuntu1) ...
Selecting previously unselected package libexpat1:amd64.
Preparing to unpack .../06-libexpat1_2.2.9-1build1_amd64.deb ...
Unpacking libexpat1:amd64 (2.2.9-1build1) ...
Selecting previously unselected package libssl1.1:amd64.
Preparing to unpack .../07-libssl1.1_1.1.1f-1ubuntu2.4_amd64.deb ...
Unpacking libssl1.1:amd64 (1.1.1f-1ubuntu2.4) ...
Selecting previously unselected package libaprutil1:amd64.
Preparing to unpack .../08-libaprutil1_1.6.1-4ubuntu2_amd64.deb ...
Unpacking libaprutil1:amd64 (1.6.1-4ubuntu2) ...
Selecting previously unselected package libsqlite3-0:amd64.
Preparing to unpack .../09-libsqlite3-0_3.31.1-4ubuntu0.2_amd64.deb ...
Unpacking libsqlite3-0:amd64 (3.31.1-4ubuntu0.2) ...
Selecting previously unselected package libaprutil1-dbd-sqlite3:amd64.
Preparing to unpack .../10-libaprutil1-dbd-sqlite3_1.6.1-4ubuntu2_amd64.deb ...
Unpacking libaprutil1-dbd-sqlite3:amd64 (1.6.1-4ubuntu2) ...
Selecting previously unselected package libroken18-heimdal:amd64.
Preparing to unpack .../11-libroken18-heimdal_7.7.0+dfsg-1ubuntu1_amd64.deb ...
Unpacking libroken18-heimdal:amd64 (7.7.0+dfsg-1ubuntu1) ...
Selecting previously unselected package libasn1-8-heimdal:amd64.
Preparing to unpack .../12-libasn1-8-heimdal_7.7.0+dfsg-1ubuntu1_amd64.deb ...
Unpacking libasn1-8-heimdal:amd64 (7.7.0+dfsg-1ubuntu1) ...
Selecting previously unselected package libheimbase1-heimdal:amd64.
Preparing to unpack .../13-libheimbase1-heimdal_7.7.0+dfsg-1ubuntu1_amd64.deb ...
Unpacking libheimbase1-heimdal:amd64 (7.7.0+dfsg-1ubuntu1) ...
Selecting previously unselected package libhcrypto4-heimdal:amd64.
Preparing to unpack .../14-libhcrypto4-heimdal_7.7.0+dfsg-1ubuntu1_amd64.deb ...
Unpacking libhcrypto4-heimdal:amd64 (7.7.0+dfsg-1ubuntu1) ...
Selecting previously unselected package libwind0-heimdal:amd64.
Preparing to unpack .../15-libwind0-heimdal_7.7.0+dfsg-1ubuntu1_amd64.deb ...
Unpacking libwind0-heimdal:amd64 (7.7.0+dfsg-1ubuntu1) ...
Selecting previously unselected package libhx509-5-heimdal:amd64.
Preparing to unpack .../16-libhx509-5-heimdal_7.7.0+dfsg-1ubuntu1_amd64.deb ...
Unpacking libhx509-5-heimdal:amd64 (7.7.0+dfsg-1ubuntu1) ...
Selecting previously unselected package libkrb5-26-heimdal:amd64.
Preparing to unpack .../17-libkrb5-26-heimdal_7.7.0+dfsg-1ubuntu1_amd64.deb ...
Unpacking libkrb5-26-heimdal:amd64 (7.7.0+dfsg-1ubuntu1) ...
Selecting previously unselected package libheimntlm0-heimdal:amd64.
Preparing to unpack .../18-libheimntlm0-heimdal_7.7.0+dfsg-1ubuntu1_amd64.deb ...
Unpacking libheimntlm0-heimdal:amd64 (7.7.0+dfsg-1ubuntu1) ...
Selecting previously unselected package libgssapi3-heimdal:amd64.
Preparing to unpack .../19-libgssapi3-heimdal_7.7.0+dfsg-1ubuntu1_amd64.deb ...
Unpacking libgssapi3-heimdal:amd64 (7.7.0+dfsg-1ubuntu1) ...
Selecting previously unselected package libsasl2-modules-db:amd64.
Preparing to unpack .../20-libsasl2-modules-db_2.1.27+dfsg-2_amd64.deb ...
Unpacking libsasl2-modules-db:amd64 (2.1.27+dfsg-2) ...
Selecting previously unselected package libsasl2-2:amd64.
Preparing to unpack .../21-libsasl2-2_2.1.27+dfsg-2_amd64.deb ...
Unpacking libsasl2-2:amd64 (2.1.27+dfsg-2) ...
Selecting previously unselected package libldap-common.
Preparing to unpack .../22-libldap-common_2.4.49+dfsg-2ubuntu1.8_all.deb ...
Unpacking libldap-common (2.4.49+dfsg-2ubuntu1.8) ...
Selecting previously unselected package libldap-2.4-2:amd64.
Preparing to unpack .../23-libldap-2.4-2_2.4.49+dfsg-2ubuntu1.8_amd64.deb ...
Unpacking libldap-2.4-2:amd64 (2.4.49+dfsg-2ubuntu1.8) ...
Selecting previously unselected package libaprutil1-ldap:amd64.
Preparing to unpack .../24-libaprutil1-ldap_1.6.1-4ubuntu2_amd64.deb ...
Unpacking libaprutil1-ldap:amd64 (1.6.1-4ubuntu2) ...
Selecting previously unselected package libbrotli1:amd64.
Preparing to unpack .../25-libbrotli1_1.0.7-6ubuntu0.1_amd64.deb ...
Unpacking libbrotli1:amd64 (1.0.7-6ubuntu0.1) ...
Selecting previously unselected package libkrb5support0:amd64.
Preparing to unpack .../26-libkrb5support0_1.17-6ubuntu4.1_amd64.deb ...
Unpacking libkrb5support0:amd64 (1.17-6ubuntu4.1) ...
Selecting previously unselected package libk5crypto3:amd64.
Preparing to unpack .../27-libk5crypto3_1.17-6ubuntu4.1_amd64.deb ...
Unpacking libk5crypto3:amd64 (1.17-6ubuntu4.1) ...
Selecting previously unselected package libkeyutils1:amd64.
Preparing to unpack .../28-libkeyutils1_1.6-6ubuntu1_amd64.deb ...
Unpacking libkeyutils1:amd64 (1.6-6ubuntu1) ...
Selecting previously unselected package libkrb5-3:amd64.
Preparing to unpack .../29-libkrb5-3_1.17-6ubuntu4.1_amd64.deb ...
Unpacking libkrb5-3:amd64 (1.17-6ubuntu4.1) ...
Selecting previously unselected package libgssapi-krb5-2:amd64.
Preparing to unpack .../30-libgssapi-krb5-2_1.17-6ubuntu4.1_amd64.deb ...
Unpacking libgssapi-krb5-2:amd64 (1.17-6ubuntu4.1) ...
Selecting previously unselected package libnghttp2-14:amd64.
Preparing to unpack .../31-libnghttp2-14_1.40.0-1build1_amd64.deb ...
Unpacking libnghttp2-14:amd64 (1.40.0-1build1) ...
Selecting previously unselected package libpsl5:amd64.
Preparing to unpack .../32-libpsl5_0.21.0-1ubuntu1_amd64.deb ...
Unpacking libpsl5:amd64 (0.21.0-1ubuntu1) ...
Selecting previously unselected package librtmp1:amd64.
Preparing to unpack .../33-librtmp1_2.4+20151223.gitfa8646d.1-2build1_amd64.deb ...
Unpacking librtmp1:amd64 (2.4+20151223.gitfa8646d.1-2build1) ...
Selecting previously unselected package libssh-4:amd64.
Preparing to unpack .../34-libssh-4_0.9.3-2ubuntu2.1_amd64.deb ...
Unpacking libssh-4:amd64 (0.9.3-2ubuntu2.1) ...
Selecting previously unselected package libcurl4:amd64.
Preparing to unpack .../35-libcurl4_7.68.0-1ubuntu2.5_amd64.deb ...
Unpacking libcurl4:amd64 (7.68.0-1ubuntu2.5) ...
Selecting previously unselected package libjansson4:amd64.
Preparing to unpack .../36-libjansson4_2.12-1build1_amd64.deb ...
Unpacking libjansson4:amd64 (2.12-1build1) ...
Selecting previously unselected package liblua5.2-0:amd64.
Preparing to unpack .../37-liblua5.2-0_5.2.4-1.1build3_amd64.deb ...
Unpacking liblua5.2-0:amd64 (5.2.4-1.1build3) ...
Selecting previously unselected package tzdata.
Preparing to unpack .../38-tzdata_2021a-0ubuntu0.20.04_all.deb ...
Unpacking tzdata (2021a-0ubuntu0.20.04) ...
Selecting previously unselected package libicu66:amd64.
Preparing to unpack .../39-libicu66_66.1-2ubuntu2_amd64.deb ...
Unpacking libicu66:amd64 (66.1-2ubuntu2) ...
Selecting previously unselected package libxml2:amd64.
Preparing to unpack .../40-libxml2_2.9.10+dfsg-5ubuntu0.20.04.1_amd64.deb ...
Unpacking libxml2:amd64 (2.9.10+dfsg-5ubuntu0.20.04.1) ...
Selecting previously unselected package apache2-bin.
Preparing to unpack .../41-apache2-bin_2.4.41-4ubuntu3.3_amd64.deb ...
Unpacking apache2-bin (2.4.41-4ubuntu3.3) ...
Selecting previously unselected package apache2-data.
Preparing to unpack .../42-apache2-data_2.4.41-4ubuntu3.3_all.deb ...
Unpacking apache2-data (2.4.41-4ubuntu3.3) ...
Selecting previously unselected package apache2-utils.
Preparing to unpack .../43-apache2-utils_2.4.41-4ubuntu3.3_amd64.deb ...
Unpacking apache2-utils (2.4.41-4ubuntu3.3) ...
Selecting previously unselected package mime-support.
Preparing to unpack .../44-mime-support_3.64ubuntu1_all.deb ...
Unpacking mime-support (3.64ubuntu1) ...
Selecting previously unselected package apache2.
Preparing to unpack .../45-apache2_2.4.41-4ubuntu3.3_amd64.deb ...
Unpacking apache2 (2.4.41-4ubuntu3.3) ...
Selecting previously unselected package openssl.
Preparing to unpack .../46-openssl_1.1.1f-1ubuntu2.4_amd64.deb ...
Unpacking openssl (1.1.1f-1ubuntu2.4) ...
Selecting previously unselected package ca-certificates.
Preparing to unpack .../47-ca-certificates_20210119~20.04.1_all.deb ...
Unpacking ca-certificates (20210119~20.04.1) ...
Selecting previously unselected package libmagic-mgc.
Preparing to unpack .../48-libmagic-mgc_1%3a5.38-4_amd64.deb ...
Unpacking libmagic-mgc (1:5.38-4) ...
Selecting previously unselected package libmagic1:amd64.
Preparing to unpack .../49-libmagic1_1%3a5.38-4_amd64.deb ...
Unpacking libmagic1:amd64 (1:5.38-4) ...
Selecting previously unselected package file.
Preparing to unpack .../50-file_1%3a5.38-4_amd64.deb ...
Unpacking file (1:5.38-4) ...
Selecting previously unselected package netbase.
Preparing to unpack .../51-netbase_6.1_all.deb ...
Unpacking netbase (6.1) ...
Selecting previously unselected package xz-utils.
Preparing to unpack .../52-xz-utils_5.2.4-1ubuntu1_amd64.deb ...
Unpacking xz-utils (5.2.4-1ubuntu1) ...
Selecting previously unselected package krb5-locales.
Preparing to unpack .../53-krb5-locales_1.17-6ubuntu4.1_all.deb ...
Unpacking krb5-locales (1.17-6ubuntu4.1) ...
Selecting previously unselected package publicsuffix.
Preparing to unpack .../54-publicsuffix_20200303.0012-1_all.deb ...
Unpacking publicsuffix (20200303.0012-1) ...
Selecting previously unselected package libsasl2-modules:amd64.
Preparing to unpack .../55-libsasl2-modules_2.1.27+dfsg-2_amd64.deb ...
Unpacking libsasl2-modules:amd64 (2.1.27+dfsg-2) ...
Selecting previously unselected package ssl-cert.
Preparing to unpack .../56-ssl-cert_1.0.39_all.deb ...
Unpacking ssl-cert (1.0.39) ...
Setting up libexpat1:amd64 (2.2.9-1build1) ...
Setting up libkeyutils1:amd64 (1.6-6ubuntu1) ...
Setting up libpsl5:amd64 (0.21.0-1ubuntu1) ...
Setting up perl-modules-5.30 (5.30.0-9ubuntu0.2) ...
Setting up mime-support (3.64ubuntu1) ...
Setting up libmagic-mgc (1:5.38-4) ...
Setting up libssl1.1:amd64 (1.1.1f-1ubuntu2.4) ...
debconf: unable to initialize frontend: Dialog
debconf: (TERM is not set, so the dialog frontend is not usable.)
debconf: falling back to frontend: Readline
Setting up libbrotli1:amd64 (1.0.7-6ubuntu0.1) ...
Setting up libsqlite3-0:amd64 (3.31.1-4ubuntu0.2) ...
Setting up libsasl2-modules:amd64 (2.1.27+dfsg-2) ...
Setting up libnghttp2-14:amd64 (1.40.0-1build1) ...
Setting up libmagic1:amd64 (1:5.38-4) ...
Setting up libapr1:amd64 (1.6.5-1ubuntu1) ...
Setting up krb5-locales (1.17-6ubuntu4.1) ...
Setting up file (1:5.38-4) ...
Setting up libldap-common (2.4.49+dfsg-2ubuntu1.8) ...
Setting up libjansson4:amd64 (2.12-1build1) ...
Setting up libkrb5support0:amd64 (1.17-6ubuntu4.1) ...
Setting up libsasl2-modules-db:amd64 (2.1.27+dfsg-2) ...
Setting up tzdata (2021a-0ubuntu0.20.04) ...
debconf: unable to initialize frontend: Dialog
debconf: (TERM is not set, so the dialog frontend is not usable.)
debconf: falling back to frontend: Readline

Current default time zone: 'Europe/Kiev'
Local time is now:      Mon Jun 28 12:58:02 EEST 2021.
Universal Time is now:  Mon Jun 28 09:58:02 UTC 2021.
Run 'dpkg-reconfigure tzdata' if you wish to change it.

Setting up librtmp1:amd64 (2.4+20151223.gitfa8646d.1-2build1) ...
Setting up xz-utils (5.2.4-1ubuntu1) ...
update-alternatives: using /usr/bin/xz to provide /usr/bin/lzma (lzma) in auto mode
update-alternatives: warning: skip creation of /usr/share/man/man1/lzma.1.gz because associated file /usr/share/man/man1/xz.1.gz (of link group lzma) doesn't exist
update-alternatives: warning: skip creation of /usr/share/man/man1/unlzma.1.gz because associated file /usr/share/man/man1/unxz.1.gz (of link group lzma) doesn't exist
update-alternatives: warning: skip creation of /usr/share/man/man1/lzcat.1.gz because associated file /usr/share/man/man1/xzcat.1.gz (of link group lzma) doesn't exist
update-alternatives: warning: skip creation of /usr/share/man/man1/lzmore.1.gz because associated file /usr/share/man/man1/xzmore.1.gz (of link group lzma) doesn't exist
update-alternatives: warning: skip creation of /usr/share/man/man1/lzless.1.gz because associated file /usr/share/man/man1/xzless.1.gz (of link group lzma) doesn't exist
update-alternatives: warning: skip creation of /usr/share/man/man1/lzdiff.1.gz because associated file /usr/share/man/man1/xzdiff.1.gz (of link group lzma) doesn't exist
update-alternatives: warning: skip creation of /usr/share/man/man1/lzcmp.1.gz because associated file /usr/share/man/man1/xzcmp.1.gz (of link group lzma) doesn't exist
update-alternatives: warning: skip creation of /usr/share/man/man1/lzgrep.1.gz because associated file /usr/share/man/man1/xzgrep.1.gz (of link group lzma) doesn't exist
update-alternatives: warning: skip creation of /usr/share/man/man1/lzegrep.1.gz because associated file /usr/share/man/man1/xzegrep.1.gz (of link group lzma) doesn't exist
update-alternatives: warning: skip creation of /usr/share/man/man1/lzfgrep.1.gz because associated file /usr/share/man/man1/xzfgrep.1.gz (of link group lzma) doesn't exist
Setting up libk5crypto3:amd64 (1.17-6ubuntu4.1) ...
Setting up libsasl2-2:amd64 (2.1.27+dfsg-2) ...
Setting up libroken18-heimdal:amd64 (7.7.0+dfsg-1ubuntu1) ...
Setting up liblua5.2-0:amd64 (5.2.4-1.1build3) ...
Setting up netbase (6.1) ...
Setting up libkrb5-3:amd64 (1.17-6ubuntu4.1) ...
Setting up apache2-data (2.4.41-4ubuntu3.3) ...
Setting up openssl (1.1.1f-1ubuntu2.4) ...
Setting up publicsuffix (20200303.0012-1) ...
Setting up libheimbase1-heimdal:amd64 (7.7.0+dfsg-1ubuntu1) ...
Setting up libgdbm6:amd64 (1.18.1-5) ...
Setting up libaprutil1:amd64 (1.6.1-4ubuntu2) ...
Setting up libicu66:amd64 (66.1-2ubuntu2) ...
Setting up libasn1-8-heimdal:amd64 (7.7.0+dfsg-1ubuntu1) ...
Setting up libaprutil1-dbd-sqlite3:amd64 (1.6.1-4ubuntu2) ...
Setting up libhcrypto4-heimdal:amd64 (7.7.0+dfsg-1ubuntu1) ...
Setting up ca-certificates (20210119~20.04.1) ...
debconf: unable to initialize frontend: Dialog
debconf: (TERM is not set, so the dialog frontend is not usable.)
debconf: falling back to frontend: Readline
Updating certificates in /etc/ssl/certs...
129 added, 0 removed; done.
Setting up libwind0-heimdal:amd64 (7.7.0+dfsg-1ubuntu1) ...
Setting up ssl-cert (1.0.39) ...
debconf: unable to initialize frontend: Dialog
debconf: (TERM is not set, so the dialog frontend is not usable.)
debconf: falling back to frontend: Readline
Setting up libgssapi-krb5-2:amd64 (1.17-6ubuntu4.1) ...
Setting up libgdbm-compat4:amd64 (1.18.1-5) ...
Setting up libssh-4:amd64 (0.9.3-2ubuntu2.1) ...
Setting up libperl5.30:amd64 (5.30.0-9ubuntu0.2) ...
Setting up libxml2:amd64 (2.9.10+dfsg-5ubuntu0.20.04.1) ...
Setting up apache2-utils (2.4.41-4ubuntu3.3) ...
Setting up libhx509-5-heimdal:amd64 (7.7.0+dfsg-1ubuntu1) ...
Setting up perl (5.30.0-9ubuntu0.2) ...
Setting up libkrb5-26-heimdal:amd64 (7.7.0+dfsg-1ubuntu1) ...
Setting up libheimntlm0-heimdal:amd64 (7.7.0+dfsg-1ubuntu1) ...
Setting up libgssapi3-heimdal:amd64 (7.7.0+dfsg-1ubuntu1) ...
Setting up libldap-2.4-2:amd64 (2.4.49+dfsg-2ubuntu1.8) ...
Setting up libaprutil1-ldap:amd64 (1.6.1-4ubuntu2) ...
Setting up libcurl4:amd64 (7.68.0-1ubuntu2.5) ...
Setting up apache2-bin (2.4.41-4ubuntu3.3) ...
Setting up apache2 (2.4.41-4ubuntu3.3) ...
Enabling module mpm_event.
Enabling module authz_core.
Enabling module authz_host.
Enabling module authn_core.
Enabling module auth_basic.
Enabling module access_compat.
Enabling module authn_file.
Enabling module authz_user.
Enabling module alias.
Enabling module dir.
Enabling module autoindex.
Enabling module env.
Enabling module mime.
Enabling module negotiation.
Enabling module setenvif.
Enabling module filter.
Enabling module deflate.
Enabling module status.
Enabling module reqtimeout.
Enabling conf charset.
Enabling conf localized-error-pages.
Enabling conf other-vhosts-access-log.
Enabling conf security.
Enabling conf serve-cgi-bin.
Enabling site 000-default.
invoke-rc.d: could not determine current runlevel
invoke-rc.d: policy-rc.d denied execution of start.
Processing triggers for libc-bin (2.31-0ubuntu9.2) ...
Processing triggers for ca-certificates (20210119~20.04.1) ...
Updating certificates in /etc/ssl/certs...
0 added, 0 removed; done.
Running hooks in /etc/ca-certificates/update.d...
done.
Removing intermediate container db365ac0d192
 ---> 8390296268cc
Step 6/16 : ENV DEVOPS=rekusha
 ---> Running in b961ac845cdc
Removing intermediate container b961ac845cdc
 ---> bdcad5bde23d
Step 7/16 : RUN echo -e "Alexandr Rekun<br>Sandbox 2021<br>env DEVOPS = $DEVOPS" > index.html
 ---> Running in dc6149f2d11d
Removing intermediate container dc6149f2d11d
 ---> 483fb40f2423
Step 8/16 : RUN mv index.html /var/www/html/index.html
 ---> Running in fd1da436f048
Removing intermediate container fd1da436f048
 ---> 19a35fad7e74
Step 9/16 : COPY task3mainproc.sh task3mainproc.sh
 ---> 1bea68cf2d66
Step 10/16 : RUN chmod a+x task3mainproc.sh
 ---> Running in 849407b17a09
Removing intermediate container 849407b17a09
 ---> 83e29ec34fbe
Step 11/16 : COPY task3helperproc.sh task3helperproc.sh
 ---> 77975f32cdf5
Step 12/16 : RUN chmod a+x task3helperproc.sh
 ---> Running in 4c591cea2fd7
Removing intermediate container 4c591cea2fd7
 ---> 5c8a8d4e5e10
Step 13/16 : COPY task3wraperscript.sh task3wraperscript.sh
 ---> 488e64f3f39f
Step 14/16 : RUN chmod a+x task3wraperscript.sh
 ---> Running in 990e13fc3b26
Removing intermediate container 990e13fc3b26
 ---> f8932d0bd25e
Step 15/16 : CMD ./task3wraperscript.sh
 ---> Running in 11f4993ec301
Removing intermediate container 11f4993ec301
 ---> 003c83ccfc64
Step 16/16 : EXPOSE 80
 ---> Running in 91a2f0045fa9
Removing intermediate container 91a2f0045fa9
 ---> eb2a5aecbc60
Successfully built eb2a5aecbc60
Successfully tagged task3extra:fromjenkinspipeline
+ sudo docker images
REPOSITORY          TAG                   IMAGE ID       CREATED        SIZE
task3extra          fromjenkinspipeline   eb2a5aecbc60   1 second ago   215MB
ubuntu              20.04                 9873176a8ff5   10 days ago    72.7MB
jenkins/ssh-agent   latest                30c405b39b48   3 months ago   518MB
[Pipeline] }
[Pipeline] // stage
[Pipeline] }
[Pipeline] // node
[Pipeline] End of Pipeline
Finished: SUCCESS   
```
7. Передать переменную PASSWORD=QWERTY! В зашифрованном виде в докер контейнер. 
   сокрытие делается с помощью рагее установленного плагина Mask passwords путем добавления в него пары ключ:значение (значение которых надо скрыть)   
   при создании задания не забыть в настройках указать галку на этот плагин
   в итоге выполнения простого скрипта с подстановкой переменной PASSWORD и PASSWORD1
```
echo PASSWORD = $PASSWORD Mask Passwords
echo PASSWORD1 = $PASSWORD1 Without Mask Passwords
```
на выходе получим
```
Started by user rekusha
Running as SYSTEM
Building remotely on java-docker-slave-0000efx4r5yir on docker-cloud1 (java-docker-slave) in workspace /home/jenkins/workspace/secret env
[secret env] $ /bin/sh -xe /tmp/jenkins9134709384592289965.sh
+ echo PASSWORD = ******** Mask Passwords
PASSWORD = ******** Mask Passwords
+ echo PASSWORD1 = NotASecret Without Mask Passwords
PASSWORD1 = NotASecret Without Mask Passwords
Finished: SUCCESS
```
   
----------------
   
   ## EXTRA:  
1. Написать pipeline который будет на дополнительной виртуальной машине запускать докер контейнер из вашего докерфайла.   
   сделано в основной части  
   
2. Написать ансибл скрипт который будет разворачивать дженкинс.  
   сделано в основной части  
   
3. Развернуть локальный docker registry загрузить в него докер образ, выгрузить докер образ из docker registry и запустить контейнер на окружении (с использованием Jenkinsfile) 
   
```
sudo docker run -d -p 5000:5000 --restart=always --name doc-rep registry:2
```
   - скачается образ и запустится на 5000 порту с автоматическим перезапуском при старте докера. все в минимальной конфигурации репозиторий развернут  
  
sudo docker tag <myimagename> <host ip>:5000/<myimagename:v1>  - добавляем тэг для локального образа. формат тэга  
   
[docker tag <имя локального образа> <repositori ip|name>:port/<имя как будет хранится в репозитории>:<доп тэг для версионности>]  
после присвоения тэга локальному образу можно его пушить в репозиторий  
```
sudo docker push 192.168.0.221:5000/<myimagename>
```
в ответ имеем
```
The push refers to repository [192.168.0.221:5000/myimagename]
Get https://192.168.0.221:5000/v2/: http: server gave HTTP response to HTTPS client
```
ЕСЛИ надо (мне надо) разрешить http без секъюра то:
```
sudo nano /etc/docker/daemon.json
{
    "insecure-registries": ["192.168.0.221:5000"]
}

sudo systemctl restart docker
```
снова пушим
```
sudo docker push 192.168.0.221:5000/<myimagename>
The push refers to repository [192.168.0.19:5000/microsevice_v1]
042a80566ff4: Layer already exists
d7994f7c0aa0: Layer already exists
13cb14c2acd3: Layer already exists
latest: digest: sha256:0aef9e0f6891b6b83ef62beeb6a97247fc9bd1057fba91476fea834b781eac2f size: 1203
```
  
посмотреть список images в репозитории можно воспользоваться curl или браузером:  
```
curl -X GET http://192.168.0.221:5000/v2/_catalog 
```
в ответ имеем json со списком образов в репозитории  

теперь в Dockefile указываем 'FROM 192.168.0.221:5000/<myimagename>' чтобы при сборке образ брался из нашего репозитория  
   
   Jenkins_extra_3 - пайплайн для всего выше описанного + создание и запуск контейнера из локального репозитория
```
pipeline {
    agent { label 'slave-host' }

    stages {
        stage('create doc_rep repository') {
            steps {
                sh'''
                    docker run -d -p 5000:5000 --restart=always --name doc_rep registry:2
                '''
            }
        }
        stage('pull test image'){
            steps{
                sh'''
                    docker pull hello-world
                '''
            }
        }
        stage('push image to doc_rep (local repository)'){
            steps{
                sh'''
                    docker tag hello-world 192.168.0.221:5000/hello-world_v1
                    docker push 192.168.0.221:5000/hello-world_v1
                    docker rmi hello-world
                    docker rmi 192.168.0.221:5000/hello-world_v1
                '''
            }
        }
        stage('pull from doc_rep (local repository)'){
            steps{
                sh'''
                    docker pull 192.168.0.221:5000/hello-world_v1
                    docker images
                '''
            }
        }
        stage('deploy test image'){
            steps{
                sh'''
                    docker run --rm -d --name test_deploy 192.168.0.221:5000/hello-world_v1
                '''
            }
        }
    }
}
```
   
4. Настроить двухстороннюю интеграцию между Jenkins и вашим Git репозиторием. Jenkins проект будет запускаться автоматически при наличии изменений в вашем репозитории а также в Git будет виден статус последней сборки из дженкинса (успешно/неуспешно/в процессе).  

   понадобится доустановить плагины   
   Embeddable Build Status   
   Role-based Authorization Strategy   
   Authorize Project   
     
   далее в "настройки дженкинс" - "глобальные настроки безопасности" - "авторизация"  
   указываем "матричное распределение прав" и в появившейся таблице пользователей выставляем права аутентифицированных пользователей в административные, анонимным пользователям указываем только "ViewStatus"  
     
   после всего проделанного идем в свой репозиторий github, выбираем Settings - Webhooks - Add webhook и заполняем адрес, формат и при каких событиях гит будет нам слать хуки  
   http://178.159.233.40:12200/github-webhook/  
   application/json  
   just the push event  
   active (галочку ставим)  
   
   в дженкинсе при создании пайплайна указываем два чекбокса  
   GitHub (указываем урл проекта 'git@github.com:rekusha/exadel.git')  
   GitHub hook trigger for GITScm polling 
   в теле проекта пишем наш код (в моем случае долго думал и выдал 'sh -c date')
   сохраняем все это и из пункта Embeddable Build Status вставляем ссылку статуса в нужное нам место чтоб отображался значек статуса проекта (с изменениями под наш конкретный случай)  
   
   <a href='http://178.159.233.40:12200/job/extra4/'><img src='http://178.159.233.40:12200/buildStatus/icon?job=extra4'></a>
   
   
