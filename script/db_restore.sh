#!/usr/bin/env bash

# part 2 script (run on dev db server)
# restore db
# optionally anonymize it (TODO: if needed?)

# call the anonymizing script(?) or leave that to the master or vagrant file?
# backup the existing dspace database
# restore anonymized backup as the dsapce db
#

function usage
{
  echo "usage: db_restore [[[-dn DB_NAME] [-du DB_USER] [-bf BACKUP_FILENAME] [-af ANONYMIZED_FILENAME] | [-h]]"
}

# set defaults:
ADMIN="vagrant"
DB_NAME="dspace"
DB_USER="dspace"
DSPACE_VERSION="5.5"
BACKUP_FILENAME="dspace_fresh_install.sql"
BACKUP_FILENAME="dspace-$DSPACE_VERSION-fresh_install.sql"
RESTORE_FILENAME="anon_dump.sql"

# process arguments:
while [ "$1" != "" ]; do
  case $1 in
    -dn | --db_name )             shift
                                  DB_NAME=$1
                                  ;;
    -du | --db_user )             shift
                                  DB_USER=$1
                                  ;;
    -dv | --dspace_version )      shift
                                  DSPACE_VERSION=$1
                                  ;;
    -bf | --backup_filename )     shift
                                  BACKUP_FILENAME=$1
                                  ;;
    -rf | --restore_filename )    shift
                                  RESTORE_FILENAME=$1
                                  ;;
    -h | --help )                 usage
                                  exit
                                  ;;
    * )                           usage
                                  exit 1
  esac
  shift
done

# set remaining vars
ADMIN_HOME="/home/$ADMIN"
BACKUP_PATH="$ADMIN_HOME/db_backup"
BACKUP_FILE="$BACKUP_PATH/$BACKUP_FILENAME"
RESTORE_FILE="$BACKUP_PATH/$RESTORE_FILENAME"
NOW=$(date +"%Y_%m_%d_%T")
pg_dump --format=custom --oids --no-owner --no-acl --ignore-version -U $DB_USER $DB_NAME > $BACKUP_FILE-$NOW
sudo su - postgres bash -c "dropdb $DB_NAME"
sudo su - postgres bash -c "createdb -O $DB_USER --encoding=UNICODE $DB_NAME"
pg_restore -U $DB_USER -d $DB_NAME -O < $RESTORE_FILE


# sudo su postgres bash -c "pg_restore -U $DB_USER -d $DB_NAME -c -O < ./$BACKUP_FILENAME"
