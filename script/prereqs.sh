#!/usr/bin/env bash

function usage
{
  echo "usage: prereqs [[[-au APPLICATION_USER] [-ta TOMCAT_ADMIN] [-tp TOMCAT_ADMIN_PASSWORD] [-ah HOSTNAME] [-d DOMAIN] [-ai IP]] | [-h]]"
}

# set defaults:
ADMIN="deploy"
APPLICATION_USER="dspace"
# TODO: fully parameterize and test
APPLICATION_USER_GUID="1002"
TOMCAT_ADMIN="CHANGEME"
TOMCAT_ADMIN_PASSWORD="CHANGEME"
HOSTNAME="DSPACE"
DOMAIN="changeme.edu"
IP="10.10.40.101"

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
    -ah | --hostname )        shift
                              HOSTNAME=$1
                              ;;
    -d | --domain )           shift
                              DOMAIN=$1
                              ;;
    -ai | --ip )              shift
                              IP=$1
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
ADMIN_HOME="/home/$ADMIN"
APACHE_MIRROR="http://mirror.cc.columbia.edu/pub/software/apache"
INSTALL_DIR="/usr/local"
FQDN="$HOSTNAME.$DOMAIN"

# surprised this is needed, but it is; lest we reinstall things
source /etc/profile

sudo yum update -y

# install prereqs
# TODO: review list
echo "--> Installing prereqs..."
sudo yum install -y wget
sudo yum install -y unzip
sudo yum install -y git
sudo yum install -y epel-release
# NOTE: just my personal preference, not actually required:
sudo yum install -y vim-enhanced screen
echo "--> prereqs installed."

# hostname
echo "--> checking hostname"
if ! hostnamectl status | grep $FQDN ; then
  sudo hostnamectl set-hostname $FQDN
  hostnamectl status
fi
# hosts file
if ! grep $IP /etc/hosts ; then
  echo "$IP $FQDN $HOSTNAME" | sudo tee -a /etc/hosts
fi

# java
JAVA_VERSION="1.7.0"
JAVA_HOME="/usr/lib/jvm/java"
# if java -version 2>&1 | grep -q $JAVA_VERSION; then
#   echo "--> java $JAVA_VERSION already installed, moving on."
# else
  echo "--> Installing java $JAVA_VERSION..."
	sudo yum install -y java-$JAVA_VERSION-openjdk-devel
	echo -e "export JAVA_HOME=$JAVA_HOME" | sudo tee /etc/profile.d/java.sh
	source /etc/profile
  if java -version 2>&1 | grep -q $JAVA_VERSION ; then
    echo "--> java now installed."
  else
    echo "ERROR: attempted to install java $JAVA_VERSION, but something went wrong"
  fi
# fi

# maven
MAVEN_VERSION="3.3.9"
if mvn -version | grep $MAVEN_VERSION ; then
  echo "--> maven $MAVEN_VERSION already installed, moving on."
else
  echo "--> Installing maven $MAVEN_VERSION..."
  cd $ADMIN_HOME
  wget -q $APACHE_MIRROR/maven/maven-3/$MAVEN_VERSION/binaries/apache-maven-$MAVEN_VERSION-bin.tar.gz
  sudo tar -zxf apache-maven-$MAVEN_VERSION-bin.tar.gz
  # make sure we have what we need before proceeding
  if [ -d "apache-maven-$MAVEN_VERSION" ]; then
    # remove old versions
    sudo rm -rf $INSTALL_DIR/*maven*
    sudo mv apache-maven-$MAVEN_VERSION $INSTALL_DIR
    rm apache-maven-$MAVEN_VERSION-bin.tar.gz
    cd $INSTALL_DIR
    sudo ln -s apache-maven-$MAVEN_VERSION maven
  	echo -e "export M2_HOME=/usr/local/maven" | sudo tee /etc/profile.d/maven.sh
  	echo -e "export PATH=\$PATH:\$M2_HOME/bin" | sudo tee -a /etc/profile.d/maven.sh
  	source /etc/profile
  fi
  if mvn -version | grep $MAVEN_VERSION ; then
    echo "--> maven now installed."
  else
    echo "ERROR: attempted to install maven $MAVEN_VERSION, but something went wrong"
  fi
fi

# ant
ANT_VERSION="1.9.7"
if ant -version | grep $ANT_VERSION ; then
  echo "--> ant $ANT_VERSION already installed, moving on."
else
  echo "--> Installing ant $ANT_VERSION..."
  cd $ADMIN_HOME
  wget -q $APACHE_MIRROR/ant/binaries/apache-ant-$ANT_VERSION-bin.tar.gz
  sudo tar -zxf apache-ant-$ANT_VERSION-bin.tar.gz
  # make sure we have what we need before proceeding
  if [ -d "apache-ant-$ANT_VERSION" ]; then
    # remove old versions
    sudo rm -rf $INSTALL_DIR/*ant*
    sudo mv apache-ant-$ANT_VERSION $INSTALL_DIR
    rm apache-ant-$ANT_VERSION-bin.tar.gz
    cd $INSTALL_DIR
    sudo ln -s apache-ant-$ANT_VERSION ant
  	echo -e "export ANT_HOME=/usr/local/ant" | sudo tee /etc/profile.d/ant.sh
  	echo -e "export PATH=\$PATH:\$ANT_HOME/bin" | sudo tee -a /etc/profile.d/ant.sh
  	source /etc/profile
  fi
  if ant -version | grep $ANT_VERSION ; then
    echo "--> ant now installed."
  else
    echo "ERROR: attempted to install ant $ANT_VERSION, but something went wrong"
  fi
fi

# system user
sudo useradd -m -c "$APPLICATION_USER system account" -u $APPLICATION_USER_GUID $APPLICATION_USER

# tomcat
TOMCAT_VERSION="8.5.5"
CATALINA_HOME=$INSTALL_DIR/tomcat
if sh $CATALINA_HOME/bin/version.sh | grep $TOMCAT_VERSION ; then
  echo "--> tomcat $TOMCAT_VERSION already installed, moving on."
else
  echo "--> Installing tomcat $TOMCAT_VERSION..."
  cd $ADMIN_HOME
  # wget -q $APACHE_MIRROR/tomcat/tomcat-8/v$TOMCAT_VERSION/bin/apache-tomcat-$TOMCAT_VERSION.tar.gz
  wget -q http://archive.apache.org/dist/tomcat/tomcat-8/v$TOMCAT_VERSION/bin/apache-tomcat-$TOMCAT_VERSION.tar.gz
  sudo tar -zxf apache-tomcat-$TOMCAT_VERSION.tar.gz
  # make sure we have what we need before proceeding
  if [ -d "apache-tomcat-$TOMCAT_VERSION" ]; then
    # remove old versions
    sudo rm -rf $INSTALL_DIR/*tomcat*
    sudo mv apache-tomcat-$TOMCAT_VERSION $INSTALL_DIR
    rm apache-tomcat-$TOMCAT_VERSION.tar.gz
    cd $INSTALL_DIR
    sudo ln -s apache-tomcat-$TOMCAT_VERSION tomcat
    sudo chown -R $APPLICATION_USER: $CATALINA_HOME/
    # set environment vars for users:
  	echo -e "export CATALINA_HOME=$CATALINA_HOME" | sudo tee /etc/profile.d/tomcat.sh
  	source /etc/profile
    # tomcat config
    sed -i -e '/<Connector port=\"8080\" protocol=\"HTTP\/1.1\"/ a\
    \           URIEncoding="UTF-8"' $CATALINA_HOME/conf/server.xml
    # authorization for tomcat manager app; NOTE: not for production
    sed -i -e "/<\/tomcat-users>/ i\
    \  <role rolename=\"manager-gui\"\/> \n\  <user username=\"$TOMCAT_ADMIN\" password=\"$TOMCAT_ADMIN_PASSWORD\" roles=\"manager-gui\"\/>" $CATALINA_HOME/conf/tomcat-users.xml
    # systemd service configuration:
    systemd_service=$(cat <<-EOF
# Systemd unit file for tomcat
[Unit]
Description=Apache Tomcat Web Application Container
After=syslog.target network.target

[Service]
Type=forking

User=$APPLICATION_USER
Group=$APPLICATION_USER
Environment=TOMCAT_USER=$APPLICATION_USER
Environment=JAVA_HOME=$JAVA_HOME
Environment='JAVA_OPTS=-Djava.awt.headless=true -Dfile.encoding=UTF-8'
Environment=CATALINA_HOME=$CATALINA_HOME
Environment='CATALINA_OPTS=-Xms1024m -Xmx1024m -XX:MaxPermSize=512m -server -XX:+UseParallelGC'
Environment=CATALINA_PID=$CATALINA_HOME/temp/tomcat.pid
PIDFile=$CATALINA_HOME/temp/tomcat.pid

ExecStart=$CATALINA_HOME/bin/startup.sh
ExecStop=

[Install]
WantedBy=multi-user.target
EOF
    )
    echo "$systemd_service" | sudo tee /etc/systemd/system/tomcat.service
    sudo systemctl daemon-reload
    sudo systemctl restart tomcat
    sudo systemctl enable tomcat
    sudo systemctl status tomcat
  fi
  if sh $CATALINA_HOME/bin/version.sh | grep $TOMCAT_VERSION ; then
    echo "--> tomcat now installed."
  else
    echo "ERROR: attempted to install tomcat $TOMCAT_VERSION, but something went wrong"
  fi
  if [ "`sudo systemctl is-active tomcat`" != "active" ] ; then
    echo "ERROR: tomcat is installed, but the service is not running"
  fi
fi
