#!/usr/bin/env bash

# NOTE: this isn't particularly robust yet.
# it works with the limited set of circumstances I happen to encounter in my environment
# e.g. assumes "public" is the relevant zone. YMMV

function usage
{
  echo "usage: db_firewall [-h]"
}

# process arguments:
while [ "$1" != "" ]; do
  case $1 in
    -h | --help )             usage
                              exit
                              ;;
    * )                       usage
                              exit 1
  esac
  shift
done

ERROR_MSG="ERROR: attempted to configure firewall, but something went wrong"
sudo systemctl enable firewalld.service
sudo systemctl start firewalld.service
firewall-cmd --state
if [ $? -eq 0 ] ; then
  echo "--> firewall now installed."
  firewall-cmd --zone=public --add-service=postgresql --permanent && echo "--> postgresql service added to firewall" || echo "$ERROR_MSG adding postgresql service"
  firewall-cmd --reload && echo "--> firewall configured" || echo "$ERROR_MSG during reload"
  firewall-cmd --zone=public --list-all
else
  echo "$ERROR_MSG starting the service"
fi
