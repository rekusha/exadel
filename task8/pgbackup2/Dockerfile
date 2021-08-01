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
