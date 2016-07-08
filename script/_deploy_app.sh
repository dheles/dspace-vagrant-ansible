#!/usr/bin/env bash

# master script for dspace database deployment
# runs various provisioning scripts directly in leiu of the Vagrantfile

function usage
{
  echo "usage: _deploy_app [[-au APPLICATION_USER] [-ta TOMCAT_ADMIN] [-tp TOMCAT_ADMIN_PASSWORD] [-ah APP_HOSTNAME] [-d DOMAIN]
                            [-di DB_IP] [-dh DB_HOSTNAME] [-dn DB_NAME] [-du DB_USER] [-dp DB_PASSWORD]] | [-h]]"
}

# set defaults:
APPLICATION_USER="dspace"
TOMCAT_ADMIN="CHANGEME"
TOMCAT_ADMIN_PASSWORD="CHANGEME"
APP_HOSTNAME="DSPACE"
DOMAIN="CHANGEME.EDU"
DB_IP="192.168.1.101"
DB_HOSTNAME="DB"
DOMAIN="CHANGEME.EDU"
DB_NAME="dspace"
DB_USER="dspace"
DB_PASS="CHANGE_MY_PASSWORD"

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
bash prereqs.sh -au $APPLICATION_USER -ta $TOMCAT_ADMIN -tp $TOMCAT_ADMIN_PASSWORD -ah $APP_HOSTNAME -d $DOMAIN

# install prerequisites for the Mirage2 xmlui theme
bash prereqs_mirage2.sh -au $APPLICATION_USER

# install and configure database client for external db server
bash db_client.sh -di $DB_IP -dh $DB_HOSTNAME -d $DOMAIN -dn $DB_NAME -du $DB_USER -dp $DB_PASSWORD -au $APPLICATION_USER

# install dspace
bash build_dspace.sh -au $APPLICATION_USER -dh $DB_HOSTNAME -d $DOMAIN -dn $DB_NAME -du $DB_USER -dp $DB_PASS
