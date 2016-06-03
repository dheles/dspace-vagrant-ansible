#!/usr/bin/env bash

function usage
{
  echo "usage: prereqs [[[-a ADMIN ] [-u APPLICATION_USER]] | [-h]]"
}

# set defaults:
ADMIN="vagrant"
APPLICATION_USER="dspace"
INSTALL_DIR="/usr/local"

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

# set remaining vars
ADMIN_HOME="/home/$ADMIN"

sudo yum update -y

# install prereqs
# TODO: review list
echo "--> Installing prereqs..."
sudo yum install -y wget
sudo yum install -y vim-enhanced
sudo yum install -y unzip
sudo yum install -y git
sudo yum install -y epel-release
echo "--> prereqs are now installed."

# java
JAVA_VERSION="1.7.0"
if java -version 2>&1 | grep -q $JAVA_VERSION; then
  echo "--> java $JAVA_VERSION already installed, moving on."
else
  echo "--> Installing java $JAVA_VERSION..."
	sudo yum install -y java-$JAVA_VERSION-openjdk-devel
  if java -version | grep $JAVA_VERSION ; then
    echo "--> java now installed."
  else
    echo "ERROR: attempted to install java $JAVA_VERSION, but something went wrong"
  fi
fi

# maven
MAVEN_VERSION="3.3.9"
if mvn -version | grep $MAVEN_VERSION ; then
  echo "--> maven $MAVEN_VERSION already installed, moving on."
else
  echo "--> Installing maven $MAVEN_VERSION..."
  cd $ADMIN_HOME
  wget -q http://mirror.cc.columbia.edu/pub/software/apache/maven/maven-3/$MAVEN_VERSION/binaries/apache-maven-$MAVEN_VERSION-bin.tar.gz
  sudo tar -zxf apache-maven-$MAVEN_VERSION-bin.tar.gz -C $INSTALL_DIR
  rm apache-maven-$MAVEN_VERSION-bin.tar.gz
  cd $INSTALL_DIR
  sudo ln -s apache-maven-$MAVEN_VERSION maven
  cd $INSTALL_DIR
	echo -e "export M2_HOME=/usr/local/maven" | sudo tee -a /etc/profile.d/maven.sh
	echo -e "export PATH=\$PATH:\$M2_HOME/bin" | sudo tee -a /etc/profile.d/maven.sh
	source /etc/profile
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
  wget -q http://mirror.cc.columbia.edu/pub/software/apache/ant/binaries/apache-ant-1.9.7-bin.tar.gz
  sudo tar -zxf apache-ant-$ANT_VERSION-bin.tar.gz -C $INSTALL_DIR
  rm apache-ant-$ANT_VERSION-bin.tar.gz
  cd $INSTALL_DIR
  sudo ln -s apache-ant-$ANT_VERSION ant
  cd $INSTALL_DIR
	echo -e "export ANT_HOME=/usr/local/ant" | sudo tee -a /etc/profile.d/ant.sh
	echo -e "export PATH=\$PATH:\$ANT_HOME/bin" | sudo tee -a /etc/profile.d/ant.sh
	source /etc/profile
  if ant -version | grep $ANT_VERSION ; then
    echo "--> ant now installed."
  else
    echo "ERROR: attempted to install ant $ANT_VERSION, but something went wrong"
  fi
fi

# tomcat
# apache
