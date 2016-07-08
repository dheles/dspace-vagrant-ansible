#!/usr/bin/env bash

# master script for dspace database deployment
# runs various provisioning scripts directly in leiu of the Vagrantfile

function usage
{
  echo "usage: _deploy_db [[[-dh HOSTNAME] [-d DOMAIN] [-dn DB_NAME] [-du DB_USER] [-dp DB_PASSWORD] [-di DB_IP]] | [-h]]"
}

# set defaults:
HOSTNAME="DB"
DOMAIN="CHANGEME.EDU"
DB_IP="192.168.1.102"
DB_NAME="dspace"
DB_USER="dspace"
DB_PASS=$(openssl rand -base64 33 | sed -e 's/[\/\:]//g')

# process arguments:
while [ "$1" != "" ]; do
  case $1 in
    -dh | --hostname )  shift
                        HOSTNAME=$1
                        ;;
    -d | --domain )     shift
                        DOMAIN=$1
                        ;;
    -di | --db_ip )     shift
                        DB_IP=$1
                        ;;
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

#db prerequisites
bash db_prereqs.sh -dh $HOSTNAME -d $DOMAIN -di $DB_IP

# db install
bash db_install.sh -dn $DB_NAME -du $DB_USER

# db create
bash db_create.sh -dn $DB_NAME -du $DB_USER -dp $DB_PASS
