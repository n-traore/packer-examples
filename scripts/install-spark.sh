#!/bin/bash

# Suppress terminal interactive errors
# see : https://www.debian-fr.org/t/debconf-utilisation-de-linterface-readline-en-remplacement/74484/3
export DEBIAN_FRONTEND=noninteractive

# Update packages repo
echo "Updating packages list..."
apt-get update


echo "Installing apt packages..."
apt-get install -y curl apt-transport-https gnupg2 ufw

# download and extract spark
echo "Downloading and installing spark..."
SPARK_VER_DL="3.4.3"
su - $SUDO_USER -c "wget https://dlcdn.apache.org/spark/spark-${SPARK_VER_DL}/spark-${SPARK_VER_DL}-bin-hadoop3.tgz -P /tmp/"

su - $SUDO_USER -c "tar xvf /tmp/spark-${SPARK_VER_DL}-bin-hadoop3.tgz -C /tmp"

mv /tmp/spark-${SPARK_VER_DL}-bin-hadoop3 /opt/spark

# writing env variables to /etc/environment
export SPARK_HOME=/opt/spark

echo "# Environment variables defined for spark" >> /etc/environment
echo "\nSPARK_HOME=$SPARK_HOME" >> /etc/enviro:nment
echo "PYSPARK_PYTHON=/usr/bin/python3" >> /etc/environment
echo "PATH=$PATH:$SPARK_HOME/bin:$SPARK_HOME/sbin" >> /etc/environment

echo "#!/bin/bash" >> /etc/profile.d/set_global_path.sh
echo "\nexport PATH=$PATH:$SPARK_HOME/bin:$SPARK_HOME/sbin" >> /etc/profile.d/set_global_path.sh

# using su here in order to avoid the copy command running as root
su - $SUDO_USER -c "cp /opt/spark/conf/spark-env.sh.template /opt/spark/conf/spark-env.sh"

# Add spark master host and spark local ip environment variables code so they can be read from session.
echo "SPARK_MASTER_HOST=\$SPARK_MASTER_HOST_IP" >> /opt/spark/conf/spark-env.sh
echo "SPARK_LOCAL_IP=\$SPARK_WORKER_MACHINE_IP" >> /opt/spark/conf/spark-env.sh

# Finishing up
echo "Done installing packages, cleaning up..."
apt-get autoremove && apt-get clean
rm -rf /tmp/*gz
