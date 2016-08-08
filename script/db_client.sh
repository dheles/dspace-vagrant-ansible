#!/usr/bin/env bash

function usage
{
  echo "usage: db_client [[[-di DB_IP] [-dh DB_HOSTNAME] [-d DOMAIN] [-dn DB_NAME] [-du DB_USER] [-dp DB_PASSWORD] [-au APPLICATION_USER]] | [-h]]"
}

# set defaults:
DB_IP="192.168.1.101"
DB_HOSTNAME="DB"
DOMAIN="changeme.edu"
DB_NAME="dspace"
DB_USER="dspace"
DB_PASS="CHANGE_MY_PASSWORD"
APPLICATION_USER="dspace"

# process arguments:
while [ "$1" != "" ]; do
  case $1 in
    -di | --ip )         shift
                        DB_IP=$1
                        ;;
    -dh | --hostname )  shift
                        DB_HOSTNAME=$1
                        ;;
    -d | --domain )     shift
                        DOMAIN=$1
                        ;;
    -dn | --db_name )   shift
                        DB_NAME=$1
                        ;;
    -du | --db_user )      shift
                        DB_USER=$1
                        ;;
    -dp | --db_pass )  shift
                        DB_PASS=$1
                        ;;
    -au | --appuser )   shift
                        APPLICATION_USER=$1
                        ;;
    -h | --help )       usage
                        exit
                        ;;
    * )                 usage
                        exit 1
  esac
  shift
done

# set remaining vars
DB_FQDN="$DB_HOSTNAME.$DOMAIN"
APPLICATION_USER_HOME="/home/$APPLICATION_USER"

echo "--> Installing postgres client"
sudo yum update -y
sudo yum install -y postgresql

# hosts file
if ! grep $DB_IP /etc/hosts ; then
  echo "$DB_IP $DB_FQDN $DB_HOSTNAME" | sudo tee -a /etc/hosts
fi

# .pgpass
# TODO: parameterize PRESERVE_DB
PRESERVE_DB=false
if $PRESERVE_DB && grep $DB_FQDN $APPLICATION_USER_HOME/.pgpass ; then
  echo "--> pgpass already configured"
else
  PG_CRED="$DB_FQDN:*:$DB_NAME:$DB_USER:$DB_PASS"
  echo $PG_CRED | sudo tee $APPLICATION_USER_HOME/.pgpass > /dev/null
  sudo chmod 0600 $APPLICATION_USER_HOME/.pgpass
  sudo chown $APPLICATION_USER: $APPLICATION_USER_HOME/.pgpass
fi

# test connection
if sudo su - $APPLICATION_USER bash -c "psql -h $DB_FQDN -U dspace -d dspace --no-password -l" | grep $DB_NAME ; then
  echo "--> Successful connection to $DB_NAME database"
else
  echo "--> Error: Failed connection to $DB_NAME database"
fi
