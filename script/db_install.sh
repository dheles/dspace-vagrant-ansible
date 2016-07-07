#!/usr/bin/env bash

function usage
{
  echo "usage: db_install [[[-dn DB_NAME] [-du DB_USER]] | [-h]]"
}

# set defaults:
DB_NAME="dspace"
DB_USER="dspace"

# process arguments:
while [ "$1" != "" ]; do
  case $1 in
    -dn | --db_name )   shift
                        DB_NAME=$1
                        ;;
    -du | --db_user )   shift
                        DB_USER=$1
                        ;;
    -h | --help )       usage
                        exit
                        ;;
    * )                 usage
                        exit 1
  esac
  shift
done

# install postgres. configuration happens later, to coincide with application config
POSTGRES_VERSION="9.2" # heed only minor version
if pg_config --version | grep $POSTGRES_VERSION ; then
  echo "--> postgres $POSTGRES_VERSION already installed, moving on."
else
  echo "--> Installing postgres $POSTGRES_VERSION..."
	sudo yum install -y postgresql-server
	sudo postgresql-setup initdb

  # TODO: review:
  POSTGRES_AUTHENTICATION=$(cat <<-EOF
local   all       postgres    ident
host    $DB_NAME  $DB_USER    0.0.0.0/0    md5

EOF
  )
  echo "$POSTGRES_AUTHENTICATION" | sudo tee /var/lib/pgsql/data/pg_hba.conf
  # echo -e "local\tall\tpostgres\tident\nhost\tdspace\tdspace\t127.0.0.1/32\tmd5" | sudo tee /var/lib/pgsql/data/pg_hba.conf

  # TODO: review:
  POSTGRES_CONFIG=$(cat <<-EOF

listen_addresses = '*'

EOF
  )
  echo "$POSTGRES_CONFIG" | sudo tee -a /var/lib/pgsql/data/postgresql.conf

	sudo systemctl enable postgresql.service
	sudo systemctl start postgresql.service
  if pg_config --version | grep $POSTGRES_VERSION ; then
    echo "--> postgres now installed."
  else
    echo "ERROR: attempted to install postgres $POSTGRES_VERSION, but something went wrong"
  fi
fi
