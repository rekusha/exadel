try to ci/cd wagtail (https://github.com/wagtail/wagtail) with docker, gitlab, kubernetis in google cloud

env: 2 linux instance with clear ubuntu 20.10 (1 - for work, 2 - for gitlab runners)

<details><summary>подготовка рабочего окружения (файлов проекта)</summary>
  
создаем репозторий на gitlab (https://gitlab.com/rekusha/exadel_task8)  
клонируем его на локальную машину  
  <pre>
  $ mkdir task8 && cd task8
  $ git clone https://gitlab.com/rekusha/exadel_task8.git  
  </pre>
перемещаемся в папку репозитория  
  <pre>
  $ cd exadel_task8  
  </pre>
  
подготавливаем файлы приложения:  
<pre>
$ sudo apt update
$ sudo apt install python3-pip python3-venv 
$ python3 -m venv venv  
$ source venv/bin/activate  
$ pip install --upgrade pip  
$ pip install wagtail  
$ wagtail start app  
$ deactivate  
$ rm -r venv/  

>>>> одной строкой: sudo apt update && sudo apt install python3-pip python3-venv && python3 -m venv venv && source venv/bin/activate && pip install --upgrade pip && pip install wagtail && wagtail start app && deactivate && rm -r venv/
</pre>

  Добавим зависимость для работы прилодения с postgresql  
<pre>
$ echo 'psycopg2-binary==2.8.6' >> app/requirements.txt
</pre>

<details><summary>$ nano app/app/settings/base.py</summary>
изменить секцию DATABASE на:
<pre>
DATABASES = {
    'default': {
        'ENGINE': os.environ.get("SQL_ENGINE"),
        'NAME': os.environ.get("SQL_DATABASE"),
        'USER': os.environ.get("SQL_USER"),
        'PASSWORD': os.environ.get("SQL_PASSWORD"),
        'HOST': os.environ.get("SQL_HOST"),
        'PORT': os.environ.get("SQL_PORT"),
    }
}
</pre></details>

<details><summary>$ nano app/Dockerfile (образ по умолчанию может не существовать, поэтому меняем)</summary>
change FROM to:
<pre>
python:3.9.6-slim-buster
</pre></details>

<details><summary>$ nano app/.env.test (минимальное тестовое окружение для проверки образа после сборки)</summary>
<pre>
DEBUG=True
DJANGO_ALLOWED_HOSTS=localhost 127.0.0.1 [::1]
SQL_ENGINE=django.db.backends.sqlite3
SQL_DATABASE=$SQL_DATABASE
SQL_USER=$SQL_USER
SQL_PASSWORD=$SQL_PASSWORD
</pre></details>

<details><summary> подготовка контейнера nginx (думаю потом можно будет перенести настройку в кубернетис с помощю конфигов)</summary>
<pre>
$ mkdir -p config/nginx
$ nano config/nginx/nginx.conf
</pre>

<pre>
upstream app {server app:8000;}

server {listen 80;
	location / {proxy_pass http://app;}
#	location /static/ {alias /home/app/static/;}
}
</pre>

<pre>
$ nano config/nginx/Dockerfile
</pre>

<pre>
FROM nginx:1.19.0-alpine

COPY ./nginx.conf /etc/nginx/conf.d/default.conf
</pre></details>

<details><summary> gitlab переменные окружения</summary>  
Для сборки и проверки работы нашего образа, нам понадобятся некоторые переменные, которые не зотелось бы светить в коде, поэтому добавим их в переменные окружения гитлаба
<pre>
settings - CI/CD - Variables - Add variable
SQL_USER: demouser
SQL_PASSWORD: DemoPass
POSTGRES_USER: demouser
POSTGRES_PASSWORD: DemoPass
SECRET_KEY: [Your SECRET_KEY]
</pre></details>
	
<details><summary>$ nano .gitlab-ci.yml (подготовка пайплайна для CI)</summary>
	
<pre>
variables:
  RUNNNER_INSTANCE_URL: http://localhost:8000/
  STATUS_CODE: '200'
  APP_NAME: app
  CI_GROUP: rekusha
  CI_REP_NAME: exadel_task8
  TEST_CONTAINER: container1 
  KUBER_CLUSTER_NAME: project8
  KUBER_PROJECT_NAME: app

stages:
  - build
  - test
  - deploy

build_job:
  stage: build
  script:
    - docker build -t $CI_REGISTRY/$CI_GROUP/$CI_REP_NAME/$APP_NAME:latest app/
  tags:
     - shell2test
     
unit_test:
  stage: test
  script:
    - docker run -i --rm --env-file app/.env.test -p 8000:8000 $CI_REGISTRY/$CI_GROUP/$CI_REP_NAME/$APP_NAME:latest python3 manage.py test
  tags:
     - shell2test

status_code_test:
  stage: test
  script:
    - docker run -d --rm --env-file app/.env.test -p 8000:8000 --name $TEST_CONTAINER $CI_REGISTRY/$CI_GROUP/$CI_REP_NAME/$APP_NAME:latest
    - sleep 20
    - export RESPONSE=$(curl --write-out "%{http_code}\n" --silent --output /dev/null $RUNNNER_INSTANCE_URL)
    - echo $RESPONSE
    - docker stop $TEST_CONTAINER
    - if [ $RESPONSE -eq $STATUS_CODE ]; then echo 'app response is correct'; else echo 'Something is wrong'; exit 1; fi
  tags:
     - shell2test

push_to_repository:
  stage: deploy
  script:
    - docker login -u $CI_REGISTRY_USER -p $CI_REGISTRY_PASSWORD $CI_REGISTRY
    - docker push $CI_REGISTRY/$CI_GROUP/$CI_REP_NAME/$APP_NAME:latest
    - docker tag $CI_REGISTRY/$CI_GROUP/$CI_REP_NAME/$APP_NAME:latest $CI_REGISTRY/$CI_GROUP/$CI_REP_NAME/$APP_NAME:$CI_COMMIT_SHORT_SHA
    - docker push $CI_REGISTRY/$CI_GROUP/$CI_REP_NAME/$APP_NAME:$CI_COMMIT_SHORT_SHA
  tags:
     - shell2test

deploy_to_gcloud:
  stage: deploy
  script:
    - helm upgrade --install app project-deploy-helm/
    - kubectl get pods
  tags:
     - shell2test
</pre></details>

<pre>
git config --global user.email "you@example.com"
git config --global user.name "Your Name"
git add .
git commit -m "push files to repo"
git push
</pre></details>


<details><summary>Настройка gitlab shell ранеда </summary>  
установка шелл ранера описывается на странице документации (https://docs.gitlab.com/runner/install/linux-repository.html)  
установка производится на подготовленном инстансе для ранеров (ubuntu 20.10 чистая установка)

<pre>
$ curl -L "https://packages.gitlab.com/install/repositories/runner/gitlab-runner/script.deb.sh" | sudo bash
$ sudo apt-get install gitlab-runner
$ sudo gitlab-runner register
вносим данные для регистрации ранера
https://gitlab.com/
токен которій получаете в гитлаб репозитории Settings - CI/CD - Runners - Specific runners - And this registration token: (там же передвинуть ползунок для отключения использования общедоступных ранеров)
gitlab-runner - описание ранера
shell2test - тэг ранера по которому можно будет назначить работу конкретно на этот ранер
shell - указываем экзекьютора который будет выполнятся на ранере

> Runner registered successfully.

так как в проекте подразумевается использование доккера, то ставим и докер
$ sudo apt-get update
$ sudo apt-get install -y apt-transport-https ca-certificates curl gnupg lsb-release
$ curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
$ echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
$ sudo apt-get update && sudo apt-get install docker-ce docker-ce-cli containerd.io
$ sudo groupadd docker
$ sudo usermod -aG docker $USER 
$ sudo usermod -aG docker gitlab-runner
$ newgrp docker 
$ sudo systemctl enable docker.service && sudo systemctl enable containerd.service
$ sudo EDITOR=nano visudo

в конец файла добавить строку
gitlab-runner ALL=(ALL:ALL) NOPASSWD:ALL

</pre></details>

<details><summary>Подготовка Kubernetes </summary>  

Используем GoogleCloud.  
После создания аккаунта и активации службы ComputerEngine(Virtual Machines) необходимо установить google cloud sdk. (на обеих инстансах /ранер и "рабочая")  
<pre>
$ echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" | sudo tee -a /etc/apt/sources.list.d/google-cloud-sdk.list
$ sudo apt-get install -y apt-transport-https ca-certificates gnupg
$ curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key --keyring /usr/share/keyrings/cloud.google.gpg add -
$ sudo apt-get update && sudo apt-get install -y google-cloud-sdk
$ gcloud init


соглашаемся залогиниться в нужную учетку
переходим по ссылке
логинимся в нужныю учетную запись гугла
соглашаемся с предоставлением ресурсов
копируем ответную строку и вставляем в поле нп клиенте
после чего соглашаемся выбрать регион и указываем на нужный нам регион (14)

>> Your project default Compute Engine zone has been set to [europe-west4-a].
>> You can change it by running [gcloud config set compute/zone NAME].
>>
>> Your project default Compute Engine region has been set to [europe-west4].
>>You can change it by running [gcloud config set compute/region NAME].
>>
>> Created a default .boto configuration file at [/root/.boto]. See this file and
>> [https://cloud.google.com/storage/docs/gsutil/commands/config] for more
>> information about configuring Google Cloud Storage.
>> Your Google Cloud SDK is configured and ready to use!


Активируем Kubernetes:
$ gcloud services enable container.googleapis.com

Устанавливаем kubectl: (на обеих машинах)
$ sudo apt install kubectl

Устанавливаем Helm Charts: (на обеих машинах)
wget https://get.helm.sh/helm-v3.6.3-linux-amd64.tar.gz
tar -xf helm-v3.6.3-linux-amd64.tar.gz
cd linux-amd64/
sudo mv helm /bin/

создаем кластер:
$ gcloud container clusters create task8



</pre></details>
