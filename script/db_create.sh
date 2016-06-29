#!/usr/bin/env bash

function usage
{
  echo "usage: db_config [[[-d DB_NAME] [-u USER] [-p PASSWORD]] | [-h]]"
}

# set defaults:
DB_NAME="CHANGE_MY_DB_NAME"
USER="CHANGE_MY_USERNAME"
PASSWORD="CHANGE_MY_PASSWORD"

# process arguments:
while [ "$1" != "" ]; do
  case $1 in
    -d | --db )         shift
                        DB_NAME=$1
                        ;;
    -u | --user )       shift
                        USER=$1
                        ;;
    -p | --password )   shift
                        PASSWORD=$1
                        ;;
    -h | --help )       usage
                        exit
                        ;;
    * )                 usage
                        exit 1
  esac
  shift
done

# NOTE: clearly, we are creating the database anew each time this script runs.
# this is useful and necessary under present circumstances, as we are generating
# the db password and passing it here and to the application with each provisioning
# if our needs change, we will need to take a different approach
PRESERVE_DB=false
if $PRESERVE_DB && sudo su - postgres bash -c "psql -l" | grep $DB_NAME ; then
  echo "--> Database $DB_NAME already created, moving on."
else
  echo "--> Creating database $DB_NAME..."

  # drop the databases and user in case they already exist. i damn potent.
  sudo su - postgres bash -c "dropdb $DB_NAME;"
  sudo su - postgres bash -c "dropuser $USER;"

  # create the database user
  sudo su - postgres bash -c "psql -c \"CREATE USER $USER WITH PASSWORD '$PASSWORD';\""

  # create the database
  sudo su - postgres bash -c "createdb -O $USER --encoding=UNICODE $DB_NAME;"

  echo "--> Database now created."
fi
