#!/usr/bin/env bash

# NOTE: don't use this yet. needs work... parking my progress for now.
# we probably don't want to modify build.properties
# (which does not have an assetstore property by default),
# but rather dspace.cfg and that probably in the source,
# updating the runtime config via ant update-config
# TODO: try it and test...

function usage
{
  echo "usage: app_assetstore [[[-aa ASSETSTORE_ARRAY]] | [-h]]"
}

# set defaults:
ASSETSTORE_ARRAY=("/mnt/dspace/storage/assetstore" "/mnt/dspace/storage/assetstore1/")

# process arguments:
while [ "$1" != "" ]; do
  case $1 in
    -au | --app_user )  shift
                        APPLICATION_USER=$1
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

for index in ${!ASSETSTORE_ARRAY[*]}
do
  if [ $index -eq 0 ] ; then
    sed -i 's|^assetstore.dir *=.*|assetstore.dir='"${ASSETSTORE_ARRAY[$index]}"'|' build.properties
  else
    additional_assetstore_setting="assetstore.dir.$index=${ASSETSTORE_ARRAY[$index]}"
    # remove any previous occurence, to ensure idempotency
    grep -v "$additional_assetstore_setting" build.properties > temp && mv temp build.properties
    sed -i -e '/^assetstore.dir *=.*/ a\
    '"${additional_assetstore_setting}"'' build.properties
  fi
done
