#!/usr/bin/env bash

# test

# rails
RAILS_VERSION="4.2.6"
if rails -v | grep $RAILS_VERSION; then
  echo "--> rails $RAILS_VERSION already installed, moving on."
else
  echo "--> Installing rails $RAILS_VERSION ..."
fi

# java
JAVA_VERSION="1.7.0"
if java -version 2>&1 | grep $JAVA_VERSION ; then
  echo "--> java $JAVA_VERSION already installed, moving on."
else
  echo "--> Installing java $JAVA_VERSION..."
fi

# maven
MAVEN_VERSION="3.3.9"
if mvn -version 2>&1 | grep $MAVEN_VERSION ; then
  echo "--> maven $MAVEN_VERSION already installed, moving on."
else
  echo "--> Installing maven $MAVEN_VERSION..."
fi
# ant
# postgres
# apache
