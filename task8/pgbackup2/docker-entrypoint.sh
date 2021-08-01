#!/bin/bash
mkdir $BACKUP_DIR
gcsfuse --key-file=$KEY_PATH $BASKET_NAME $BACKUP_DIR
pg_dump --dbname=postgresql://$SQL_USER:$SQL_PASSWORD@$SQL_HOST:$SQL_PORT/$SQL_DB > $BACKUP_DIR/"$SQL_DB-$ENV_NSP$(date -u +"%FT%H%MZ").sql"
exec fusermount -u $BACKUP_DIR
