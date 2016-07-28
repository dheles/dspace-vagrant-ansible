#!/usr/bin/env bash

# TODO: merge into prereqs?
# TODO: arguments... use 'em or lose 'em

function usage
{
  echo "usage: app_psi-probe [[[-au APPLICATION_USER] [-ta TOMCAT_ADMIN] [-tp TOMCAT_ADMIN_PASSWORD]] | [-h]]"
}

# set defaults:
APPLICATION_USER="dspace"
TOMCAT_ADMIN="CHANGEME"
TOMCAT_ADMIN_PASSWORD="CHANGEME"

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
    -h | --help )             usage
                              exit
                              ;;
    * )                       usage
                              exit 1
  esac
  shift
done

# set remaining vars
CORE_INSTALL_DIR="/usr/local"
CATALINA_HOME="$CORE_INSTALL_DIR/tomcat"
ROLES_CONFIG="$CATALINA_HOME/conf/tomcat-users.xml"
REPO="https://github.com/psi-probe/psi-probe"
BRANCH=""
APP_INSTALL_DIR="/opt"
APP_NAME="psi-probe"
WAR_PATH="web/target/probe.war"
APP_DIR=$APP_INSTALL_DIR/$APP_NAME

echo "--> Configuring Tomcat for $APP_NAME..."
# add roles
# NOTE: presumes manager-gui and a user with the role has already been added (currently done in prereqs.sh)
ROLE_ARRAY=("probeuser" "poweruser" "poweruserplus" "manager-gui")
for index in ${!ROLE_ARRAY[*]}
do
  if ! grep -q "rolename=\"${ROLE_ARRAY[$index]}" $ROLES_CONFIG ; then
    sed -i '/<\/tomcat-users>/ i\
    \  <role rolename=\"'${ROLE_ARRAY[$index]}'\"\/>' $ROLES_CONFIG
  fi
done

# add user
if ! grep -q "username=\"$TOMCAT_ADMIN" $ROLES_CONFIG ; then
  sed -i '/<\/tomcat-users>/ i\
  \  <user username=\"'$TOMCAT_ADMIN'\" password=\"'$TOMCAT_ADMIN_PASSWORD'\" roles=\"manager-gui\"\/>' $ROLES_CONFIG
fi

# enable remote jmx
TOMCAT_CONFIG="/etc/systemd/system/tomcat.service"
if ! grep -q "jmxremote=true" $TOMCAT_CONFIG ; then
  sed -i "/CATALINA_OPTS.*/ s/'$/ -Dcom.sun.management.jmxremote=true'/" $TOMCAT_CONFIG
fi

sudo systemctl stop tomcat

if [ ! -z "$BRANCH" ]; then
  BRANCH="--branch $BRANCH"
fi
echo "cloning: $REPO $BRANCH $APP_DIR"
git clone $REPO $BRANCH $APP_DIR
sudo chown -R $APPLICATION_USER: $APP_DIR

echo "--> Building $APP_NAME..."
sudo su - $APPLICATION_USER bash -c "cd $APP_DIR && mvn package"
sudo chown -R $APPLICATION_USER: $APP_DIR

echo "--> Configuring $APP_NAME..."
app_conf=$(cat <<-EOF
<?xml version="1.0" encoding="UTF-8"?>
<Context privileged="true"
  docBase="$APP_DIR/$WAR_PATH" />
EOF
)
APP_CONFIG=$CATALINA_HOME/conf/Catalina/localhost/$APP_NAME.xml
echo "$app_conf" | sudo tee $APP_CONFIG
sudo chown -R $APPLICATION_USER: $APP_CONFIG

sudo systemctl start tomcat
