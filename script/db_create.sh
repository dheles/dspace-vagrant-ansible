#!/usr/bin/env bash

function usage
{
  echo "usage: db_config [[[-dn DB_NAME] [-du DB_USER] [-dp DB_PASSWORD]] | [-h]]"
}

# set defaults:
DB_NAME="dspace"
DB_USER="dspace"
DB_PASS="CHANGE_MY_PASSWORD"
# since we are now provisioning db creation and application configuration separately,
# generating random passwords in the provisioning scripts will no longer work;
# we now generate them in the calling (vagrant) script
# DB_PASS=$(openssl rand -base64 33 | sed -e 's/\///g')

# process arguments:
while [ "$1" != "" ]; do
  case $1 in
    -dn | --db_name )   shift
                        DB_NAME=$1
                        ;;
    -du | --db_user )   shift
                        DB_USER=$1
                        ;;
    -dp | --db_pass )   shift
                        DB_PASS=$1
                        ;;
    -h | --help )       usage
                        exit
                        ;;
    * )                 usage
                        exit 1
  esac
  shift
done

# NOTE: we are creating the database anew each time this script runs.
# this is useful and necessary under present circumstances, as we are generating
# the db password and passing it here and to the application with each provisioning
# if our needs change, we will need to take a different approach
# TODO: parameterize PRESERVE_DB
PRESERVE_DB=false
if $PRESERVE_DB && sudo su - postgres bash -c "psql -l" | grep $DB_NAME ; then
  echo "--> Database $DB_NAME already created, moving on."
else
  echo "--> Creating database $DB_NAME..."

  # drop the databases and user in case they already exist. i damn potent.
  sudo su - postgres bash -c "dropdb $DB_NAME;"
  sudo su - postgres bash -c "dropuser $DB_USER;"

  # create the database user
  sudo su - postgres bash -c "psql -c \"CREATE USER $DB_USER WITH PASSWORD '$DB_PASS';\""

  # create the database
  sudo su - postgres bash -c "createdb -O $DB_USER --encoding=UNICODE $DB_NAME;"

  if sudo su - postgres bash -c "psql -l" | grep $DB_NAME ; then
    echo "--> Database now created."
  else
    echo "--> Error: attempted to create database $DB_NAME, but something went wrong."
  fi
fi
