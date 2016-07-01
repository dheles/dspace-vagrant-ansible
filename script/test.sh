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

echo "--> Configuring..."
echo "the password for user $USER in the $DB_NAME database is $PASSWORD"
echo "was that supposed to be a secret?"
echo "oops."
echo "--> ...Done Configuring"

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
