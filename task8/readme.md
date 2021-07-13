try to ci/cd wagtail (https://github.com/wagtail/wagtail) with dicker, gitlab, kubernetis  
  
1. do app docer-compose local  
<pre>
$ python3 -m venv venv  
$ source venv/bin/activate  
$ pip install --upgrade pip  
$ pip install wagtail  
$ wagtail start app  
$ deactivate  
$ rm -r venv/  
</pre>

<details><summary>$ nano .env.dev</summary>
<pre>
DEBUG=True
SECRET_KEY=[Your SECRET_KEY]
DJANGO_ALLOWED_HOSTS=localhost 127.0.0.1 [::1]

SQL_ENGINE=django.db.backends.postgresql_psycopg2
SQL_DATABASE=demo_wagtail
SQL_USER=demouser
SQL_PASSWORD=DemoPass
SQL_HOST=db
SQL_PORT=5432
DATABASE=postgres
</pre></details>

<details><summary>$ nano .env.dev.db</summary>
<pre>
POSTGRES_USER=demouser
POSTGRES_PASSWORD=DemoPass
POSTGRES_DB=demo_wagtail
</pre></details>

<pre>
$ echo 'psycopg2-binary==2.8.6' >> app/requirements.txt
</pre>

<details><summary>$ nano app/app/settings/dev.py</summary>
<pre>
remove DATABASES section
</pre></details>

<details><summary>$ nano app/app/settings/base.py</summary>
<pre>
# Add Database PostgreSQL
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

<details><summary>$ nano app/entrypoint.sh</summary>
<pre>
#!/bin/sh

if [ "$DATABASE" = "postgres" ]
then
    echo "Waiting for postgres..."

    while ! nc -z $SQL_HOST $SQL_PORT; do
      sleep 0.1
    done

    echo "PostgreSQL started"
fi

python manage.py makemigrations --settings=app.settings.dev
python manage.py migrate --settings=app.settings.dev

exec "$@"
</pre></details>

<details><summary>$ nano app/Dockerfile</summary>
<pre>
FROM python:3.8.5-alpine3.12

WORKDIR /usr/src/app

ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONUNBUFFERED 1

RUN apk update \
    && apk add postgresql-dev gcc python3-dev musl-dev libffi-dev openssl-dev \
    && apk add jpeg-dev libwebp-dev zlib-dev freetype-dev lcms2-dev openjpeg-dev tiff-dev tk-dev tcl-dev libxml2-dev libxslt-dev libxml2

RUN pip install --upgrade pip
COPY ./requirements.txt /usr/src/app/requirements.txt
RUN pip install -r requirements.txt

# Postgres Entrypoint
COPY entrypoint.sh /usr/src/app/entrypoint.sh
ENTRYPOINT ["sh", "/usr/src/app/entrypoint.sh"]
</pre></details>

<details><summary>$ nano docker-compose.yml</summary>
<pre>
version: '3.7'

services:
  web:
    build: app
    command: python manage.py runserver 0.0.0.0:8000 --settings=app.settings.dev
    volumes:
      - ./app/:/usr/src/app/
    ports:
      - 8000:8000
    env_file:
      - .env.dev
    depends_on:
      - db
      
  db:
    image: postgres:12.2-alpine
    restart: always
    ports:
      - "5432:5432"
    volumes:
      - postgres_data:/var/lib/postgresql/data/
    env_file:
      - .env.dev.db

volumes:
    postgres_data:
</pre></details>
<pre>
$ docker-compose up -d --build  
</pre>
At this moment we have working web project at port 8000 with posgres db in different container

For create admin user execute
<pre>
docker-compose exec web python manage.py createsuperuser --settings=app.settings.dev
</pre>
