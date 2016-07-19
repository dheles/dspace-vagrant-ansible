#!/usr/bin/env bash

# part 3 script (run on dev app server)
# NOTE: restest db connectivity before beginning
# NOTE: will need to turn off the app (or at least its connectivity to the database)
# for the previous step (db restore) to succeed. therefore, this script assumes
# it's starting with the tomcat service stopped

function usage
{
  echo "usage: db_upgrade [-h]"
}

# process arguments:
while [ "$1" != "" ]; do
  case $1 in
    -h | --help )                 usage
                                  exit
                                  ;;
    * )                           usage
                                  exit 1
  esac
  shift
done

# set defaults:
# TODO: parameterize(?)
INSTALL_DIR="/opt"
DSPACE_INSTALL="$INSTALL_DIR/dspace"

# upgrade db
echo "--> Upgrading database..."
$DSPACE_INSTALL/bin/dspace database info
$DSPACE_INSTALL/bin/dspace database migrate
$DSPACE_INSTALL/bin/dspace database info

sudo systemctl restart tomcat
sudo systemctl status tomcat
if [ "`sudo systemctl is-active tomcat`" != "active" ] ; then
  echo "ERROR: tomcat service failed to restart"
fi

# TODO: devise a way of testing dspace availability
