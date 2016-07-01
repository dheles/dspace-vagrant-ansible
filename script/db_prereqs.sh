#!/usr/bin/env bash

function usage
{
  echo "usage: db_prereqs [[[-dh HOSTNAME] [-d DOMAIN]] | [-h]]"
}

# set defaults:
HOSTNAME="DB"
DOMAIN="CHANGEME.EDU"

# process arguments:
while [ "$1" != "" ]; do
  case $1 in
    -dh | --hostname )         shift
                              HOSTNAME=$1
                              ;;
    -d | --domain )           shift
                              DOMAIN=$1
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
FQDN="$HOSTNAME.$DOMAIN"

sudo yum update -y

# install prereqs
# TODO: review list
echo "--> Installing prereqs..."
# NOTE: just my personal preference, not actually required:
sudo yum install -y vim-enhanced
echo "--> prereqs are now installed."

# hostname
echo "--> checking hostname"
if ! hostnamectl status | grep $FQDN ; then
  sudo hostnamectl set-hostname $FQDN
  hostnamectl status
fi
