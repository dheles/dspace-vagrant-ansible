#!/usr/bin/env bash

# TODO: SSL (https 443)

function usage
{
  echo "usage: app_apache [[[-ah HOSTNAME] [-d DOMAIN]] | [-h]]"
}

# set defaults:
APP_HOSTNAME="dspace-stage"
DOMAIN="library.jhu.edu"

# process arguments:
while [ "$1" != "" ]; do
  case $1 in
    -ah | --app_hostname )    shift
                        APP_HOSTNAME=$1
                        ;;
    -d | --domain )     shift
                        DOMAIN=$1
                        ;;
    -h | --help )       usage
                        exit
                        ;;
    * )                 usage
                        exit 1
  esac
  shift
done

# set remaining vars
FQDN="$APP_HOSTNAME.$DOMAIN"

# install apache
APACHE_VERSION="2" # heed only major version. fyi, current version as of this writing is 2.4.6
APACHE_VERSION_PATTERN="$APACHE_VERSION\." # avoid false positive in the server build date returned with the version
if httpd -v | grep $APACHE_VERSION_PATTERN ; then
  echo "--> apache $APACHE_VERSION already installed, moving on."
else
  sudo yum install -y httpd
  sudo systemctl enable httpd.service
  sudo systemctl start httpd.service
  sudo systemctl status httpd.service
fi

# TODO: figure out how to test this...
APACHE_CONFIGURED=false
if $APACHE_CONFIGURED; then
  echo "--> apache already configured, moving on."
else
  echo "--> Configuring apache..."
	app_conf=$(cat <<-EOF
  <VirtualHost *:80>
    ServerName $FQDN
    # TODO: ServerAlias

    ProxyPass         /  ajp://localhost:8009/
    ProxyPassReverse  /  ajp://localhost:8009/

    ErrorLog "/var/log/httpd/$APP_HOSTNAME-error.log"
    CustomLog "/var/log/httpd/$APP_HOSTNAME-access.log" combined
  </VirtualHost>
EOF
	)

	echo "$app_conf" | sudo tee /etc/httpd/conf.d/$APP_HOSTNAME.conf

	sudo systemctl restart httpd
  sudo systemctl status httpd
  # TODO: figure out how to return something to confirm it all worked...
fi
