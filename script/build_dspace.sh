#!/usr/bin/env bash

function usage
{
  echo "usage: build_dspace [[[-au APPLICATION_USER] [-dh DB_HOSTNAME] [-d DOMAIN] [-dn DB_NAME] [-du DB_USER] [-dp DB_PASSWORD]] | [-h]]"
}

# set defaults:
APPLICATION_USER="dspace"
DB_HOSTNAME="DB"
DOMAIN="CHANGEME.EDU"
DB_NAME="dspace"
DB_USER="dspace"
DB_PASS="CHANGE_MY_PASSWORD"
# since we are now provisioning db creation and application configuration separately,
# generating random passwords in the provisioning scripts will no longer work;
# we now generate one in the calling (vagrant) script and *must* pass it in
# DB_PASS=$(openssl rand -base64 33 | sed -e 's/\///g')

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

# set the remaining vars
DSPACE_VERSION="5.5"
INSTALL_DIR="/opt"
DSPACE_INSTALL="$INSTALL_DIR/dspace"
APPLICATION_USER_HOME="/home/$APPLICATION_USER"

# to install from a release:
# DSPACE_SOURCE="dspace-$DSPACE_VERSION-src-release"

# to install from a repo:
DSPACE_SOURCE="dspace-$DSPACE_VERSION"
REPO="https://github.com/jhu-sheridan-libraries/DSpace.git"
BRANCH="JHU"

if  echo $DB_HOSTNAME | grep "localhost" ; then
  DB_FQDN=$DB_HOSTNAME
else
  DB_FQDN="$DB_HOSTNAME.$DOMAIN"
fi
# TODO: parameterize
DB_PORT="5432"
DB_URL="jdbc:postgresql://$DB_FQDN:$DB_PORT/$DB_NAME"
MAIL_SERVER="SMTP.CHANGEME.EDU"
MAIL_ADMIN="CHANGEME@CHANGEME.EDU"
ADMIN_EMAIL="ADMIN@CHANGEME.EDU"
ADMIN_FIRSTNAME="CHANGE"
ADMIN_LASTNAME="ME"
ADMIN_PASSWORD="CHANGEME"
ADMIN_LANGUAGE="English"

if  $DSPACE_INSTALL/bin/dspace version | grep $DSPACE_VERSION ; then
  echo "--> dspace $DSPACE_VERSION already built and installed, moving on."
else
  echo "--> Building and installing dspace $DSPACE_VERSION..."

  # TODO: cleanup:
  # # TODO: if this can and should be broken out into a separate script (e.g. for a remote DB), do so
  # # configure database
  # if $DSPACE_INSTALL/bin/dspace database test | grep "Connected successfully"; then
  #   echo "--> Database already configured, moving on."
  # else
  #   echo "--> Configuring database..."
  #
  #   # TODO: use or lose...
  #
  # 	# # drop the databases and user in case they already exist. i damn potent.
  # 	# sudo su - postgres bash -c "dropdb $DB_NAME;"
  # 	# sudo su - postgres bash -c "psql -c \"DROP USER IF EXISTS $APPLICATION_USER;\""
  #   #
  #   # # create the database user
  # 	# sudo su - postgres bash -c "psql -c \"CREATE USER $APPLICATION_USER WITH CREATEDB PASSWORD '$APPLICATION_USER_DB_PASSWORD';\""
  #   #
  # 	# # create the database
  # 	# sudo su - postgres bash -c "createdb -O $APPLICATION_USER --encoding=UNICODE $DB_NAME;"
  #   #
  #   # # TODO: consider persisting db credentials in environment vars
  #
  #   echo "--> Database now configured."
  # fi

  PRESERVE_BUILD=true
  if [ $PRESERVE_BUILD ] && [ -d "$DSPACE_INSTALL" ] ; then
    echo "--> dspace already built, moving on."

    # until we get pgpass working, we still need to sync DB_PASS in the installer
    # TODO: parameterize:
    PRESERVE_DB=false
    if ! $PRESERVE_DB ; then
      echo "--> updating DB_PASS"
      sed -i 's/^db.password.*/db.password = '"$DB_PASS"'/' $APPLICATION_USER_HOME/$DSPACE_SOURCE/dspace/target/dspace-installer/config/dspace.cfg
    fi
  else
    echo "--> Building dspace..."

    # prepare install location:
    # NOTE: at the moment, we are blowing away the build each time we run this script...
    # there may be merit in less drastic measures
    # ...and in fact, there is...
    # TODO: fix:
    # if we don't need to create the db user (with a fresh password) above,
    # when we blow away the build that persisted that working password
    # in favor of a new one (with a new password), then the passwords get
    # out-of-sync and the application can no longer connect to the db
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
        sed -i 's|^db.url.*|db.url='"$DB_URL"'|' build.properties
        sed -i 's/^db.username.*/db.username='"$DB_USER"'/' build.properties
        # TODO: rework to make use of .pgpass:
        sed -i 's/^db.password.*/db.password='"$DB_PASS"'/' build.properties
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
      sudo su - $APPLICATION_USER bash -c "cd $DSPACE_SOURCE && mvn package -Dmirage2.on=true -Dmirage2.deps.included=false"
    fi
  fi

  # TODO: review: ever a reason not to install?
  # install dspace
  echo "--> Installing..."
  sudo su - $APPLICATION_USER bash -c "cd $DSPACE_SOURCE/dspace/target/dspace-installer && ant fresh_install"

  # deploy web applications
  echo "--> Deploying..."
  CATALINA_HOME=/usr/local/tomcat
  cd $CATALINA_HOME/webapps
  sudo rm -rf lni/ solr/ oai/ swordv2/ jspui/ sword/ xmlui/
  sudo cp -R $DSPACE_INSTALL/webapps/* $CATALINA_HOME/webapps
  sudo chown -R $APPLICATION_USER: $CATALINA_HOME/webapps

fi

# TODO: figure out most efficient way to keep DB_PASS in sync between db and app scripts,
# when we aren't just rebuilding everything

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
