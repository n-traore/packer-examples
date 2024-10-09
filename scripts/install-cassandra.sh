#!/bin/bash

# Suppress terminal interactive errors
# see : https://www.debian-fr.org/t/debconf-utilisation-de-linterface-readline-en-remplacement/74484/3
export DEBIAN_FRONTEND=noninteractive

# Update packages repo
echo "Updating packages list..."
apt-get update


echo "Installing apt packages..."
apt-get install -y curl apt-transport-https gnupg2 ufw

#--------- JAVA 11
# download and extract java 11
JAVA_VER_DL="11.0.2"
if [ ! -f "/usr/local/bin/jdk-${JAVA_VER_DL}" ]; then
  echo "Downloading and installing Java..." # link https://jdk.java.net/archive/
  wget https://download.java.net/java/GA/jdk11/9/GPL/openjdk-${JAVA_VER_DL}_linux-x64_bin.tar.gz -P /tmp/
  tar xvf /tmp/openjdk-${JAVA_VER_DL}_linux-x64_bin.tar.gz -C /tmp
  mv /tmp/jdk-${JAVA_VER_DL} /usr/local/bin/ ;
fi

#--------- CASSANDRA
# download, install and enable cassandra
# correct instructions here : https://cassandra.apache.org/doc/latest/cassandra/getting_started/installing.html
echo "Downloading and installing cassandra..."
curl https://downloads.apache.org/cassandra/KEYS | apt-key add -
echo "deb https://debian.cassandra.apache.org 40x main" | tee -a /etc/apt/sources.list.d/cassandra.sources.list
apt-get update
apt-get install cassandra -y

# modify cassandra's java home var to java 11 version
# see : https://stackoverflow.com/questions/36433835/getting-cassandra-to-use-an-alternate-java-install
sed -i "s/^#JAVA_HOME.*/JAVA_HOME=\/usr\/local\/bin\/jdk-$JAVA_VER_DL/" /usr/share/cassandra/cassandra.in.sh

# enable cassandra
systemctl enable cassandra

# Finishing up
echo "Done installing packages, cleaning up..."
apt autoremove && apt-get clean
rm -rf /tmp/*gz
