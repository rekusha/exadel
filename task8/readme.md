try to ci/cd wagtail (https://github.com/wagtail/wagtail) with docker, gitlab, kubernetis in google cloud

env: 2 linux instance with clear ubuntu 20.10 (1 - for work, 2 - for gitlab runners)  
создаем репозторий на gitlab (https://gitlab.com/rekusha/exadel_task8)  

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

sudo passwd gitlab-runner - устанавливаем пароль на ранера

>> passwd: password updated successfully
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
логинимся в нужную учетную запись гугла
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
$ wget https://get.helm.sh/helm-v3.6.3-linux-amd64.tar.gz
$ tar -xf helm-v3.6.3-linux-amd64.tar.gz
$ cd linux-amd64/
$ sudo mv helm /bin/
$ cd ~ && rm -rf ~/linux-amd64/ && rm ~/helm-v3.6.3-linux-amd64.tar.gz

создаем кластер:
$ gcloud container clusters create task8

$ gcloud container clusters get-credentials task8 !!!!!!!!!!!!!!!!!!!!! подтягивает конфиг если он не подтянулся автоматом
</pre></details>

<details><summary>подготовка рабочего окружения (файлов проекта)</summary>
клонируем репозиторий на локальную машину  
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
SQL_DATABASE=DemoBase
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
    - kubectl get pods
    - helm upgrade app project-deploy-helm/ --install --set secrets.SQL_USER=$SQL_USER,secrets.SQL_PASSWORD=$SQL_PASSWORD,secrets.POSTGRES_USER=$POSTGRES_USER,secrets.POSTGRES_PASSWORD=$POSTGRES_PASSWORD,secrets.SECRET_KEY=$SECRET_KEY
  tags:
     - shell2test

</pre></details></details>

<details><summary> Helm Chart </summary>
	
<pre>
mkdir -p project-deploy-helm/templates
</pre>
<details><summary> nano project-deploy-helm/Chart.yaml </summary>

<pre>
apiVersion: v2
name: Project-task8-Deploy
description: Deploy with Kuber
type: application
version: 0.1.0
appVersion: "1.0"

keywords:
   - postgresql
   - wagtail

maintainers:
   - giturl: https://gitlab.com/rekusha/exadel_task8
   - container_registory: https://gitlab.com/rekusha/exadel_task8/container_registry
</pre></details>
<details><summary> nano project-deploy-helm/values.yaml </summary>
	
<pre>
#docker images:
containers:
  db_image: postgres:latest
  app_image: registry.gitlab.com/rekusha/exadel_task8/app
  grafana_image: grafana/grafana

#db default values 
db: 
  name: postgresql-db
  replicas: 1
  storage: 1Gi 
  env:
    postgres_db: demo_wagtail
    secret: task8-secret
  service:
    name: service-postgresql-db
    port: 5432
    targetPort: 5432

#wagtail default values 
app:
  name: wagtail
  env:
    sql_engine: django.db.backends.postgresql_psycopg2
    debug: '"true"'
    allowed_hosts: localhost 127.0.0.1 [::1]
    sql_port: '"5432"'
  service:
    name: service-wagtail
    port: 8000
    targetPort: 8000
  hpa:  
    minReplicas: 2
    maxReplicas: 4
    resource:
      cpu: 90

#grafana default values
grafana: 
  name: grafana
  replicas: 1
  service:
    name: service-grafana
    port: 3000
    targetPort: 3000

secrets:
  SQL_USER: user
  SQL_PASSWORD: password
  POSTGRES_USER: user
  POSTGRES_PASSWORD: password
  SECRET_KEY: aslgkjaklgjf

</pre></details>
<details><summary> nano project-deploy-helm/templates/deployment.yaml </summary>
	
<pre>
# PostgreSQL StatefulSet
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: {{ .Values.db.name }}
spec:
  serviceName: {{ .Values.db.name }}-service
  selector:
    matchLabels:
      app: {{ .Values.db.name }}
  replicas: {{ .Values.db.replicas }}
  template:
    metadata:
      labels:
        app: {{ .Values.db.name }}
    spec:
      containers:
        - name: {{ .Values.db.name }}
          image: {{ .Values.containers.db_image }}
          volumeMounts:
            - name: {{ .Values.db.name }}-disk
              mountPath: /data
          env:
            - name: POSTGRES_DB
              value: {{ .Values.db.env.postgres_db }}
            - name: POSTGRES_USER
              valueFrom:
                secretKeyRef:
                  name: {{ .Values.db.env.secret }}
                  key: POSTGRES_USER
            - name: POSTGRES_PASSWORD
              valueFrom:
                secretKeyRef:
                  name: {{ .Values.db.env.secret }}
                  key: POSTGRES_PASSWORD
        #    - name: POSTGRES_PASSWORD
        #      value: testpassword
        #    - name: PGDATA
        #      value: /data/pgdata
  # Volume Claim
  volumeClaimTemplates:
    - metadata:
        name: {{ .Values.db.name }}-disk
      spec:
        accessModes: ["ReadWriteOnce"]
        resources:
          requests:
            storage: {{ .Values.db.storage }}

--- 
# wagtail Deployment
apiVersion: apps/v1
kind: Deployment
metadata:
  name: {{ .Values.app.name }}
spec:
  selector:
    matchLabels:
      project: {{ .Values.app.name }}
 # replicas: 2
  template: 
    metadata:
      labels:
        project: {{ .Values.app.name }}
    spec:
      containers:
        - name: {{ .Values.app.name }}
          image: {{ .Values.containers.app_image }}
          env:
            - name: DEBUG
              value: {{ .Values.app.env.debug }}
            - name: DJANGO_ALLOWED_HOSTS
              value: {{ .Values.app.env.allowed_hosts }}
            - name: SQL_ENGINE
              value: {{ .Values.app.env.sql_engine }}
            - name: SQL_DATABASE
              value: {{ .Values.db.env.postgres_db }}
            - name: SQL_USER
              valueFrom:
                secretKeyRef:
                  name: {{ .Values.db.env.secret }}
                  key: SQL_USER
            - name: SQL_PASSWORD
              valueFrom:
                secretKeyRef:
                  name: {{ .Values.db.env.secret }}
                  key: SQL_PASSWORD
            - name: SQL_HOST
              value: {{ .Values.db.service.name }}
            - name: SQL_PORT
              value: {{ .Values.app.env.sql_port }}

---
# Grafana Deployment
apiVersion: apps/v1
kind: Deployment
metadata:
  name: {{ .Values.grafana.name }}
spec:
  selector:
    matchLabels:
      project: {{ .Values.grafana.name }}
  replicas: {{ .Values.grafana.replicas }}
  template: 
    metadata:
      labels:
        project: {{ .Values.grafana.name }}
    spec:
      containers:
        - name: {{ .Values.grafana.name }}
          image: {{ .Values.containers.grafana_image }}    

</pre></details>
<details><summary> nano project-deploy-helm/templates/hpa-v2.yaml </summary>

<pre>
apiVersion: autoscaling/v2beta1
kind: HorizontalPodAutoscaler
metadata:
  name: {{ .Values.app.name }}-scaling
spec:
  scaleTargetRef:
    apiVersion: apps/v2beta1v1
    kind: Deployment
    name: {{ .Values.app.name }}
  minReplicas: {{ .Values.app.hpa.minReplicas }}
  maxReplicas: {{ .Values.app.hpa.maxReplicas }}
  metrics:
  - type: Resource
    resource:
      name: cpu
      targetAverageUtilization: {{ .Values.app.hpa.resource.cpu }}
</pre></details>
<details><summary> nano project-deploy-helm/templates/secret.yaml </summary>
<pre>
---
apiVersion: v1
kind: Secret
metadata:
  name: task8-secret
type: Opaque
data:
  SQL_USER: {{ .Values.secrets.SQL_USER | b64enc }}
  SQL_PASSWORD: {{ .Values.secrets.SQL_PASSWORD | b64enc }}
  POSTGRES_USER: {{ .Values.secrets.POSTGRES_USER | b64enc }}
  POSTGRES_PASSWORD: {{ .Values.secrets.POSTGRES_PASSWORD | b64enc }}
  SECRET_KEY: {{ .Values.secrets.SECRET_KEY | b64enc }}

</pre></details>
<details><summary> nano project-deploy-helm/templates/service.yaml </summary>
	
<pre>
# PostgreSQL StatefulSet Service
apiVersion: v1
kind: Service
metadata:
  name: {{ .Values.db.service.name }}
spec:
  selector:
    app: {{ .Values.db.name }}
  type: LoadBalancer
  ports:
    - port: {{ .Values.db.service.port }}
      targetPort: {{ .Values.db.service.targetPort }}

--- 
apiVersion: v1
kind: Service
metadata:
  name: {{ .Values.app.service.name }}
spec:
  selector:
    project: {{ .Values.app.name }}
  type: LoadBalancer
  ports:
    - port: {{ .Values.app.service.port }}
      targetPort: {{ .Values.app.service.targetPort }}

--- 
apiVersion: v1
kind: Service
metadata:
  name: {{ .Values.grafana.service.name }}
spec:
  selector:
    project: {{ .Values.grafana.name }}
  type: LoadBalancer
  ports:
    - port: {{ .Values.grafana.service.port }}
      targetPort: {{ .Values.grafana.service.targetPort }}

</pre></details></details>
	
<pre>
git config --global user.email "you@example.com"
git config --global user.name "Your Name"
git add .
git commit -m "push files to repo"
git push
</pre>

на данном этапе у нас поднимается постгрес(готовый к работе), вагтэйл(еоннектится к постгресу) и графана(пока не настроенная)  

<details><summary> Создание serviceUser k8s для настройки бэкапов и графаны </summary>

<pre>
$ gcloud iam service-accounts create serviceuser  - создаст пользователя serviceuser 
Created service account [serviceuser].


соотнесем созданного пользователя с проектом и назначим ему нужные привилегии
$ gcloud projects add-iam-policy-binding exadel-task-8 --member="serviceAccount:serviceuser@exadel-task-8.iam.gserviceaccount.com" --role="roles/owner"
-----------
Updated IAM policy for project [exadel-task-8].
bindings:
...
- members:
  - serviceAccount:serviceuser@exadel-task-8.iam.gserviceaccount.com
  - user:rekusha@gmail.com
  role: roles/owner
...
-----------


генерируем файл ключей для доступа соданного пользователя к проекту
$ gcloud iam service-accounts keys create task8key.json --iam-account=serviceuser@exadel-task-8.iam.gserviceaccount.com
-----------
created key [8afc59f7c32614db04f72eee4509ceab931a3878] of type [json] as [task8key.json] for [serviceuser@exadel-task-8.iam.gserviceaccount.com]
-----------


в итоге у нас есть файл с кредами для аутентификации от имени созданного пользователя
$ cat task8key.json
-----------
{
  "type": "service_account",
  "project_id": "exadel-task-8",
  "private_key_id": "8afc59f7c32614db04f72eee4509ceab931a3878",
  "private_key": "-----BEGIN PRIVATE KEY-----|-----END PRIVATE KEY-----",
  "client_email": "serviceuser@exadel-task-8.iam.gserviceaccount.com",
  "client_id": "100352356826156311325",
  "auth_uri": "https://accounts.google.com/o/oauth2/auth",
  "token_uri": "https://oauth2.googleapis.com/token",
  "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
  "client_x509_cert_url": "https://www.googleapis.com/robot/v1/metadata/x509/backupuser%40exadel-task-8.iam.gserviceaccount.com"
}
-----------


kubectl create secret generic task8backup --from-file=key.json=task8key.json (копируем ключи в секреты кубернетиса)

</pre></details>



<details><summary> grafana </summary>

<pre>

</pre></details>


<details><summary> postgres backup </summary>

<pre>
Для хранения бэкапов следует создать корзину
$ gsutil mb -l europe-west4 gs://task8backup
Creating gs://task8backup/...
</pre>
	
для того чтобы выполнять резервное копирование надо создать CronJob которая будет понимать заранее подготовленный докер образ и передавать ему переменные необходимые для монтирования корзины созданной шагом выше и создания дампа бд после подключения к нужному ресурсу. для этого создадим Dockerfile собирающий все необходимое в одном контейнере и скрипт выполняющий по сути монтирование корзины, создание и запись бэкапа в корзину, отмонтирование корзины

<details><summary> Dockerfile</summary>	
$ mkdir ~/task8/pgbackup  
$ cd ~/task8/pgbackup  
$ nano Dockerfile  

<pre>
FROM ubuntu:20.04

ENV BACKUP_DIR=/home/postgres/backup
ENV PGTZ=Europe/Kiev

RUN apt-get update
RUN apt-get install -y lsb-release wget gnupg && apt-get clean all
RUN apt install -y vim bash-completion wget
RUN wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add -
RUN echo "deb http://apt.postgresql.org/pub/repos/apt/ `lsb_release -cs`-pgdg main" | tee /etc/apt/sources.list.d/pgdg.list
RUN apt update
RUN apt install -y postgresql-client

RUN lsb_release -c -s > /tmp/lsb_release
RUN GCSFUSE_REPO=$(cat /tmp/lsb_release); echo "deb http://packages.cloud.google.com/apt gcsfuse-$GCSFUSE_REPO main" | tee /etc/apt/sources.list.d/gcsfuse.list
RUN wget -O - https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -

RUN apt-get update
RUN apt-get install -y gcsfuse

RUN useradd -rm -d /home/postgres -s /bin/bash -g root -G sudo -u 1001 postgres

ADD docker-entrypoint.sh /home/postgres/docker-entrypoint.sh
RUN chmod +x /home/postgres/docker-entrypoint.sh && chown postgres /home/postgres/docker-entrypoint.sh

ENTRYPOINT ["/home/postgres/docker-entrypoint.sh"]

</pre></details>

	
<details><summary> docker-entrypoint.sh</summary>

<pre>
#!/bin/bash
mkdir $BACKUP_DIR
gcsfuse --key-file=$KEY_PATH $BASKET_NAME $BACKUP_DIR
pg_dump --dbname=postgresql://$SQL_USER:$SQL_PASSWORD@$SQL_HOST:$SQL_PORT/$SQL_DB > $BACKUP_DIR/"$SQL_DB-$(date -u +"%FT%H%MZ").sql"
exec fusermount -u $BACKUP_DIR
</pre></details>

<details><summary> собираем образ и пушим его в репозиторий </summary>
	
<pre>
$ docker login -u rekusha -p PASSWORD registry.gitlab.com
$ docker build -t registry.gitlab.com/rekusha/exadel_task8/pgdump:latest ./
$ docker push registry.gitlab.com/rekusha/exadel_task8/pgdump:latest
</pre></details>
  
	
<details><summary> $ nano project-deploy-helm/templates/postgresql-cloud-dump.yaml</summary>
	
<pre>
apiVersion: batch/v1beta1
kind: CronJob
metadata:
  name: postgres-backup
spec:
  schedule: "0 /2 * * *"
  successfulJobsHistoryLimit: 0
  failedJobsHistoryLimit: 0
  jobTemplate:
    spec:
      template:
        spec:
          containers:
          - name: postgres-backup 
            image: registry.gitlab.com/rekusha/exadel_task8/pgdump
	    env:
              - name: KEY_PATH
                value: /var/secrets/key.json
              - name: BASKET_NAME
                value: task8backup
              - name: SQL_USER
	        valueFrom:
                  secretKeyRef:
                    name: {{ .Values.db.env.secret }}
                    key: POSTGRES_USER
              - name: SQL_PASSWORD
                valueFrom:
                  secretKeyRef:
                    name: {{ .Values.db.env.secret }}
                    key: POSTGRES_PASSWORD
              - name: SQL_HOST
                value: {{ .Values.db.service.name }}
              - name: SQL_PORT
                value: {{ .Values.app.env.sql_port }}
              - name: SQL_DB
                value: {{ .Values.db.env.postgres_db }}
            
            securityContext:
              privileged: true
              capabilities:
                add: ["SYS_ADMIN"]
		
            volumeMounts:
              - name: secret-volume
                mountPath: /var/secrets
		
          restartPolicy: Never
          volumes:
            - name: secret-volume
              secret:
                secretName: task8backup
</pre></details></details>

