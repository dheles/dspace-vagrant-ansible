#!/usr/bin/env bash

# master script for dspace database deployment
# runs various provisioning scripts directly in leiu of the Vagrantfile

function usage
{
  echo "usage: _deploy_app [[-au APPLICATION_USER] [-ta TOMCAT_ADMIN] [-tp TOMCAT_ADMIN_PASSWORD] [-ah APP_HOSTNAME] [-d DOMAIN] [-ai APP_IP] [-di DB_IP] [-dh DB_HOSTNAME] [-dn DB_NAME] [-du DB_USER] [-dp DB_PASSWORD]] | [-h]]"
}

# set defaults:
APPLICATION_USER="dspace"
TOMCAT_ADMIN="CHANGEME"
TOMCAT_ADMIN_PASSWORD="CHANGEME"
APP_IP="10.10.40.101"
APP_HOSTNAME="DSPACE"
DOMAIN="CHANGEME.EDU"
DB_IP="10.10.40.102"
DB_HOSTNAME="DB"
DB_NAME="dspace"
DB_USER="dspace"
DB_PASS=$(openssl rand -base64 33 | sed -e 's/[\/\:]//g')

# process arguments:
while [ "$1" != "" ]; do
  case $1 in
    -au | --user )            shift
                              APPLICATION_USER=$1
                              ;;
    -ta | --tomcat_admin )    shift
                              TOMCAT_ADMIN=$1
                              ;;
    -tp | --tomcat_password ) shift
                              TOMCAT_ADMIN_PASSWORD=$1
                              ;;
    -ai | --app_ip )          shift
                              APP_IP=$1
                              ;;
    -ah | --app_hostname )    shift
                              APP_HOSTNAME=$1
                              ;;
    -d | --domain )           shift
                              DOMAIN=$1
                              ;;
    -di | --db_ip )           shift
                              DB_IP=$1
                              ;;
    -dh | --db_hostname )     shift
                              DB_HOSTNAME=$1
                              ;;
    -dn | --db_name )         shift
                              DB_NAME=$1
                              ;;
    -du | --db_user )         shift
                              DB_USER=$1
                              ;;
    -dp | --db_pass )         shift
                              DB_PASS=$1
                              ;;
    -h | --help )             usage
                              exit
                              ;;
    * )                       usage
                              exit 1
  esac
  shift
done

# prerequisites
bash prereqs.sh -au $APPLICATION_USER -ta $TOMCAT_ADMIN -tp $TOMCAT_ADMIN_PASSWORD -ah $APP_HOSTNAME -d $DOMAIN -ai $APP_IP

# install prerequisites for the Mirage2 xmlui theme
bash prereqs_mirage2.sh -au $APPLICATION_USER

# -- EITHER --

  # # install database (if not using external db server)
  # DB_HOSTNAME="localhost" # this will be needful when configuring dspace below
  # bash db_install.sh  -dn $DB_NAME -du $DB_USER
  # # db create
  # bash db_create.sh -dn $DB_NAME -du $DB_USER -dp $DB_PASS

# --- OR ---

  # install and configure database client for external db server
  bash db_client.sh -di $DB_IP -dh $DB_HOSTNAME -d $DOMAIN -dn $DB_NAME -du $DB_USER -dp $DB_PASS -au $APPLICATION_USER

# install dspace
bash build_dspace.sh -au $APPLICATION_USER -dh $DB_HOSTNAME -d $DOMAIN -dn $DB_NAME -du $DB_USER -dp $DB_PASS
