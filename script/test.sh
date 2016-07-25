#!/usr/bin/env bash

function usage
{
  echo "usage: test [[[-dn DB_NAME] [-au USER] [-ap PASSWORD]] | [-h]]"
}

# set defaults:
DB_NAME="CHANGE_MY_DB_NAME"
USER="CHANGE_MY_USERNAME"
PASSWORD="CHANGE_MY_PASSWORD"

# process arguments:
while [ "$1" != "" ]; do
  case $1 in
    -dn | --db )         shift
                        DB_NAME=$1
                        ;;
    -du | --user )       shift
                        USER=$1
                        ;;
    -dp | --password )   shift
                        PASSWORD=$1
                        ;;
    -h | --help )       usage
                        exit
                        ;;
    * )                 usage
                        exit 1
  esac
  shift
done

DSPACE_INSTALL="/opt/dspace"
CATALINA_HOME="/usr/local/tomcat"
# NOTE: the first app in the array will be configured as the root context
APP_ARRAY=("xmlui" "solr" "oai" "rdf" "rest" "sword" "swordv2")
RELOADABLE="true"
CACHINGALLOWED="false"
# TODO: parameterize
PRODUCTION=false
if $PRODUCTION ; then
  RELOADABLE="false"
  CACHINGALLOWED="true"
fi
for index in ${!APP_ARRAY[*]}
do
  echo "--> Configuring ${APP_ARRAY[$index]}..."
  app_conf=$(cat <<-EOF
<?xml version='1.0'?>
<Context
  docBase="$DSPACE_INSTALL/webapps/${APP_ARRAY[$index]}"
  reloadable="$RELOADABLE"
  cachingAllowed="$CACHINGALLOWED"/>
EOF
  )
  app_conf_filename="${APP_ARRAY[$index]}.xml"
  if [ $index -eq 0 ] ; then
    app_conf_filename="ROOT.xml"
  fi
  echo "$app_conf" | sudo tee $CATALINA_HOME/conf/Catalina/localhost/$app_conf_filename
done
APPLICATION_USER="dspace"
sudo chown -R $APPLICATION_USER: $CATALINA_HOME/conf/Catalina/localhost/

# PRESERVE_BUILD=false
# DSPACE_INSTALL=true
# echo "PRESERVE_BUILD=$PRESERVE_BUILD"
# echo "DSPACE_INSTALL=$DSPACE_INSTALL"
# if [ $PRESERVE_BUILD ] && [ $DSPACE_INSTALL ] ; then
#   echo "wtf"
# else
#   echo "that's what i thought"
# fi

# ASSETSTORE_ARRAY=("/mnt/dspace/storage/assetstore" "/mnt/dspace/storage/assetstore1/")
# for index in ${!ASSETSTORE_ARRAY[*]}
# do
#   if [ $index -eq 0 ] ; then
#     sed -i '' 's|^assetstore.dir *=.*|assetstore.dir='"${ASSETSTORE_ARRAY[$index]}"'|' build.properties
#   else
#     additional_assetstore_setting="assetstore.dir.$index=${ASSETSTORE_ARRAY[$index]}"
#     # sed -i '' 's|^'"$additional_assetstore_setting"'|''|' build.properties
#     # awk "!/$additional_assetstore_setting/" build.properties > temp && mv temp build.properties
#     grep -v "$additional_assetstore_setting" build.properties > temp && mv temp build.properties
#     sed -i '' -e '/^assetstore.dir *=.*/ a\
#     '"${additional_assetstore_setting}"'' build.properties
#     true
#   fi
# done

# echo "--> Configuring..."
# echo "the password for user $USER in the $DB_NAME database is $PASSWORD"
# echo "was that supposed to be a secret?"
# echo "oops."
# echo "--> ...Done Configuring"

# test

# selector='<Connector port="8080" protocol="HTTP/1.1"'
# addition='URIEncoding="UTF-8"'
# echo $selector
# sed -i '' -e '/<Connector port=\"8080\" protocol=\"HTTP\/1.1\"/ a\
# \         URIEncoding="UTF-8"' test.txt

# sed -i '' 's/^[[:space:].*<theme .*/GONE/' test.txt

# sed -i '' 's/^[[:space:]]*<theme .*/<!-- & -->/' test.txt
# sed -i '' -e '/<\/themes>/ i\
# \      <theme name="Mirage 2" regex=".*" path="Mirage2\/" \/>' test.txt

# sed -i '' -e '/^\# TYPE/ a\
# host   dspace             dspace        127.0.0.1\/32            md5' test.txt
