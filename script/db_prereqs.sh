#!/usr/bin/env bash

function usage
{
  echo "usage: db_prereqs [[[-a ADMIN ] [-u APPLICATION_USER] [-t TOMCAT_ADMIN] [-p TOMCAT_ADMIN_PASSWORD] [-n HOSTNAME]] | [-h]]"
}

# set defaults:
ADMIN="vagrant"
APPLICATION_USER="dspace"
HOSTNAME="DB.CHANGEME.EDU"

# process arguments:
while [ "$1" != "" ]; do
  case $1 in
    -a | --admin )            shift
                              ADMIN=$1
                              ;;
    -u | --user )             shift
                              APPLICATION_USER=$1
                              ;;
    -n | --hostname )         shift
                              HOSTNAME=$1
                              ;;
    -h | --help )             usage
                              exit
                              ;;
    * )                       usage
                              exit 1
  esac
  shift
done

# set remaining vars
ADMIN_HOME="/home/$ADMIN"
INSTALL_DIR="/usr/local"

sudo yum update -y

# install prereqs
# TODO: review list
echo "--> Installing prereqs..."
# NOTE: just my personal preference, not actually required:
sudo yum install -y vim-enhanced
echo "--> prereqs are now installed."

# set hostname
echo "--> setting hostname"
sudo hostnamectl set-hostname $HOSTNAME
hostnamectl status
