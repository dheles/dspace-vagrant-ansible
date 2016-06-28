#!/usr/bin/env bash

function usage
{
  echo "usage: db [[[-a ADMIN ] [-u APPLICATION_USER]] | [-h]]"
}

# set defaults:
ADMIN="vagrant"
APPLICATION_USER="dspace"

# process arguments:
while [ "$1" != "" ]; do
  case $1 in
    -a | --admin )    shift
                      ADMIN=$1
                      ;;
    -u | --user )     shift
                      APPLICATION_USER=$1
                      ;;
    -h | --help )     usage
                      exit
                      ;;
    * )               usage
                      exit 1
  esac
  shift
done

# install postgres. configuration happens later, to coincide with application config
POSTGRES_VERSION="9.2.15"
if pg_config --version | grep $POSTGRES_VERSION ; then
  echo "--> postgres $POSTGRES_VERSION already installed, moving on."
else
  echo "--> Installing postgres $POSTGRES_VERSION..."
	sudo yum install -y postgresql-server
	sudo postgresql-setup initdb

  echo -e "local\tall\tpostgres\tident\nhost\tdspace\tdspace\t127.0.0.1/32\tmd5" | sudo tee /var/lib/pgsql/data/pg_hba.conf

	sudo systemctl enable postgresql.service
	sudo systemctl start postgresql.service
  if pg_config --version | grep $POSTGRES_VERSION ; then
    echo "--> postgres now installed."
  else
    echo "ERROR: attempted to install postgres $POSTGRES_VERSION, but something went wrong"
  fi
fi
