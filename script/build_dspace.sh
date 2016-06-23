#!/usr/bin/env bash

function usage
{
  echo "usage: dspace [[[-a ADMIN ] [-u APPLICATION_USER]] | [-h]]"
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

# set the remaining vars
DSPACE_VERSION="5.5"
INSTALL_DIR="/opt"
DSPACE_INSTALL="$INSTALL_DIR/dspace"
APPLICATION_USER_DB_PASSWORD=$(openssl rand -base64 33)
APPLICATION_DB_NAME="dspace"
APPLICATION_USER_HOME="/home/$APPLICATION_USER"
# DSPACE_SOURCE="dspace-$DSPACE_VERSION-src-release"
DSPACE_SOURCE="dspace-$DSPACE_VERSION"
REPO="https://github.com/jhu-sheridan-libraries/DSpace.git"
BRANCH="styling"
MAIL_SERVER="SMTP.CHANGEME.EDU"
MAIL_ADMIN="CHANGEME@CHANGEME.EDU"
ADMIN_EMAIL="ADMIN@CHANGEME.EDU"
ADMIN_FIRSTNAME="CHANGE"
ADMIN_LASTNAME="ME"
ADMIN_PASSWORD="CHANGEME"
ADMIN_LANGUAGE="English"

# TODO: figure out an appropriate check for this:
if  $DSPACE_INSTALL/bin/dspace version | grep $DSPACE_VERSION ; then
  echo "--> dspace $DSPACE_VERSION already installed, moving on."
else
  echo "--> Installing dspace $DSPACE_VERSION..."
  # TODO: database setup
  # TODO: if this can and should be broken out into a separate script (e.g. for a remote DB), do so
  # configure database
  # TODO: figure out an appropriate check for this:
  if $DSPACE_INSTALL/bin/dspace database test | grep "Connected successfully"; then
    echo "--> Database already configured, moving on."
  else
    echo "--> Configuring database..."

  	# drop the databases and user in case they already exist. i damn potent.
  	sudo su - postgres bash -c "dropdb $APPLICATION_DB_NAME;"
  	sudo su - postgres bash -c "psql -c \"DROP USER IF EXISTS $APPLICATION_USER;\""

    # create the database user
  	sudo su - postgres bash -c "psql -c \"CREATE USER $APPLICATION_USER WITH CREATEDB PASSWORD '$APPLICATION_USER_DB_PASSWORD';\""

  	# create the database
  	sudo su - postgres bash -c "createdb -O $APPLICATION_USER --encoding=UNICODE $APPLICATION_DB_NAME;"

    # TODO: consider persisting db credentials in environment vars

    echo "--> Database now configured."
  fi

  # prepare install location:
  # NOTE: at the moment, we are blowing away the build each time we run this script...
  # there may be merit in less drastic measures
  if [ -d "$DSPACE_INSTALL" ]; then
    sudo rm -rf $DSPACE_INSTALL
  fi
  sudo mkdir $DSPACE_INSTALL
  sudo chown $APPLICATION_USER: $DSPACE_INSTALL

  # get the source, if we need it:
  cd $APPLICATION_USER_HOME
  if [ ! -d $DSPACE_SOURCE ]; then
    # NOTE: to get release, rather than repo:
    # wget -q https://github.com/DSpace/DSpace/releases/download/dspace-$DSPACE_VERSION/$DSPACE_SOURCE.tar.gz
    # tar -zxf $DSPACE_SOURCE.tar.gz
    # rm $DSPACE_SOURCE.tar.gz
    if [ ! -z "$BRANCH" ]; then
      BRANCH="--branch $BRANCH"
    fi
    echo "cloning: $REPO $BRANCH $DSPACE_SOURCE"
  	git clone $REPO $BRANCH $DSPACE_SOURCE
    # TODO: necessary?
  	sudo chown -R $APPLICATION_USER: $DSPACE_SOURCE
  fi
  # make sure we have what we need before proceeding
  if [ ! -d $DSPACE_SOURCE ]; then
    echo "ERROR: attempted to get $DSPACE_SOURCE, but failed. installation cannot proceed."
  else
    # TODO: remove old versions

    # initial configuration:
    echo "--> Configuring build..."
    pushd $DSPACE_SOURCE
      sed -i 's|^dspace.install.dir.*|dspace.install.dir='"$DSPACE_INSTALL"'|' build.properties
      sed -i 's/^dspace.name.*/dspace.name=JScholarship \(DSpace '"$DSPACE_VERSION"' - Build\)/' build.properties
      sed -i 's/^db.username.*/db.username='"$APPLICATION_USER"'/' build.properties
      sed -i 's/^db.password.*/db.password='"$APPLICATION_USER_DB_PASSWORD"'/' build.properties
      sed -i 's/^mail.server[[:space:]]*=.*/mail.server='"$MAIL_SERVER"'/' build.properties
      # sed -i s/mail.from.address.*/mail.from.address=$MAIL_FROM_ADDRESS/ build.properties
      sed -i 's/^mail.admin.*/mail.admin='"$MAIL_ADMIN"'/' build.properties
      sed -i 's/^mail.from.address.*/mail.from.address=\$\{mail.admin\}/' build.properties
      sed -i 's/^mail.feedback.recipient.*/mail.feedback.recipient=\$\{mail.admin\}/' build.properties
      sed -i 's/^mail.alert.recipient.*/mail.alert.recipient=\$\{mail.admin\}/' build.properties
      sed -i 's/^mail.registration.notify.*/mail.registration.notify=\$\{mail.admin\}/' build.properties

      # enable the Mirage 2 theme:
      echo "--> Enabling Mirage 2..."
      sed -i 's/^[[:space:]]*<theme .*/<!-- & -->/' dspace/config/xmlui.xconf
      sed -i -e '/<\/themes>/ i\
      \      <theme name="Mirage 2" regex=".*" path="Mirage2\/" \/>' dspace/config/xmlui.xconf
    popd

    # Build the Installation Package
    echo "--> Building..."
    sudo chown -R $APPLICATION_USER: $DSPACE_SOURCE
    sudo su - $APPLICATION_USER bash -c "cd $DSPACE_SOURCE && mvn package -Dmirage2.on=true"

    # install dspace
    echo "--> Installing..."
    sudo su - $APPLICATION_USER bash -c "cd $DSPACE_SOURCE/dspace/target/dspace-installer && ant fresh_install"

    # deploy web applications
    echo "--> Deploying..."
    CATALINA_HOME=/usr/local/tomcat
    cd $CATALINA_HOME/webapps
    sudo rm -rf lni/ solr/ oai/ swordv2/ jspui/ sword/ xmlui/
    sudo cp -R $DSPACE_INSTALL/webapps/* $CATALINA_HOME/webapps
  fi
fi

# initial setup
# these can safely run repeatedly, unless you don't want to migrate the database yet for some reason
if true ; then
  # initialize database:
  echo "--> Initializing..."
  $DSPACE_INSTALL/bin/dspace database info
  $DSPACE_INSTALL/bin/dspace database migrate

  # add administrator account
  $DSPACE_INSTALL/bin/dspace create-administrator -e $ADMIN_EMAIL -f $ADMIN_FIRSTNAME -l $ADMIN_LASTNAME -c $ADMIN_LANGUAGE -p $ADMIN_PASSWORD
fi
