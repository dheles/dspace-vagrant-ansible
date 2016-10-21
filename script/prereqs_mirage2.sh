#!/usr/bin/env bash

function usage
{
  echo "usage: prereqs_mirage2 [[[-au APPLICATION_USER] | [-h]]"
}

# set defaults:
APPLICATION_USER="dspace"

# process arguments:
while [ "$1" != "" ]; do
  case $1 in
    -au | --user )             shift
                              APPLICATION_USER=$1
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
INSTALL_DIR="/usr/local"

# https://github.com/DSpace/DSpace/tree/master/dspace-xmlui-mirage2

# git (no particular version)
if git --version | grep "[[:digit:]]" ; then
  echo "--> git already installed, moving on."
else
  echo "--> Installing git..."
  sudo yum install -y git
  if git --version | grep "[[:digit:]]" ; then
    echo "--> git now installed."
  else
    echo "ERROR: attempted to install git, but something went wrong"
  fi
fi

# ruby (no particular version)
if ruby -v | grep "[[:digit:]]" ; then
  echo "--> ruby already installed, moving on."
else
  echo "--> Installing ruby..."
  sudo yum install -y ruby ruby-devel
  if ruby -v | grep "[[:digit:]]" ; then
    echo "--> ruby now installed."
  else
    echo "ERROR: attempted to install ruby, but something went wrong"
  fi
fi

# TODO: devise check
sudo yum install -y ruby-devel gcc

# node (no particular version)
if node -v | grep "[[:digit:]]" ; then
  echo "--> node already installed, moving on."
else
  echo "--> Installing node..."
  sudo yum install -y epel-release
  sudo yum install -y nodejs npm --enablerepo=epel
  if node -v | grep "[[:digit:]]" ; then
    echo "--> node now installed."
  else
    echo "ERROR: attempted to install node, but something went wrong"
  fi
fi

# adjust npm default directory and permissions:
# https://docs.npmjs.com/getting-started/fixing-npm-permissions#option-1-change-the-permission-to-npms-default-directory
npm config set prefix $INSTALL_DIR
sudo su - $APPLICATION_USER bash -c "npm config set prefix $INSTALL_DIR"
if [ ! -d "$(npm config get prefix)/lib/node_modules" ] ; then
  mkdir "$(npm config get prefix)/lib/node_modules"
fi
# NOTE: this proved inadequate:
# sudo chown -R $APPLICATION_USER: $(npm config get prefix)/{lib/node_modules,bin,share}
# ls -ltrah "$(npm config get prefix)/lib/node_modules"
sudo chown -R $APPLICATION_USER: $INSTALL_DIR

# set GEM_HOME & GEM_PATH for all users and put the gem executable directory in everyone's PATH
echo -e "export GEM_HOME=$INSTALL_DIR/share/gems" | sudo tee /etc/profile.d/ruby.sh
echo -e "export GEM_PATH=$INSTALL_DIR/share/gems" | sudo tee -a /etc/profile.d/ruby.sh
echo -e "export PATH=\$PATH:\$GEM_HOME/bin"       | sudo tee -a /etc/profile.d/ruby.sh
source /etc/profile

# install remaining prerequisites
npm update -g npm

# bower (no particular version)
if sudo su - $APPLICATION_USER bash -c "bower -v" | grep "[[:digit:]]" ; then
  echo "--> bower already installed, moving on."
else
  sudo su - $APPLICATION_USER bash -c "npm install -g bower"
  if sudo su - $APPLICATION_USER bash -c "bower -" | grep "[[:digit:]]" ; then
    echo "--> bower installed"
  else
    echo "ERROR: attempted to install bower, but something went wrong"
  fi
fi

# grunt
# TODO: confirm this is not needed: (alt: path /usr/local/bin/grunt)
sudo npm install -g grunt

if sudo su - $APPLICATION_USER bash -c "grunt --version" | grep "[[:digit:]]" ; then
  echo "--> grunt-cli already installed, moving on."
else
  echo "--> Installing grunt-cli"
  sudo npm install -g grunt-cli
  if sudo su - $APPLICATION_USER bash -c "grunt --version" | grep "[[:digit:]]" ; then
    echo "--> grunt-cli installed"
  else
    echo "ERROR: attempted to install grunt-cli, but something went wrong"
  fi
fi

# # set GEM_HOME & GEM_PATH for all users and put the gem executable directory in everyone's PATH
# echo -e "export GRUNT_HOME=$INSTALL_DIR"      | sudo tee /etc/profile.d/grunt.sh
# echo -e "export PATH=\$PATH:\$GRUNT_HOME" | sudo tee -a /etc/profile.d/grunt.sh
# source /etc/profile


# sass & compass
# NOTE: updating system ruby to latest w/o specifying version.
# pros & cons... however, compass stopped installing,
# and was a documented step that helped get back on track
sudo su - $APPLICATION_USER bash -c "gem update --system"

SASS_VERSION="3.3.14"
if sudo su - $APPLICATION_USER bash -c "sass -v" | grep $SASS_VERSION ; then
  echo "--> sass already installed, moving on."
else
  sudo su - $APPLICATION_USER bash -c "gem install sass -v $SASS_VERSION --no-document"
  if sudo su - $APPLICATION_USER bash -c "sass -v" | grep $SASS_VERSION ; then
    echo "--> sass installed"
  else
    echo "ERROR: attempted to install sass, but something went wrong"
  fi
fi
COMPASS_VERSION="1.0.1"
if sudo su - $APPLICATION_USER bash -c "compass -v" | grep $COMPASS_VERSION ; then
  echo "--> compass already installed, moving on."
else
  sudo su - $APPLICATION_USER bash -c "gem install compass -v $COMPASS_VERSION --no-document"
  if sudo su - $APPLICATION_USER bash -c "compass -v" | grep $COMPASS_VERSION ; then
    echo "--> compass installed"
  else
    echo "ERROR: attempted to install compass, but something went wrong"
  fi
fi
