#!/bin/bash -v
apt-get update -y
apt-get install -y software-properties-common curl > /tmp/install.log

# Install Java 8
add-apt-repository "deb http://ppa.launchpad.net/webupd8team/java/ubuntu xenial main"
apt-get update -y
apt-get install -y oracle-java8-installer > /tmp/install_java8.log

# Install Artifactory
echo "deb https://jfrog.bintray.com/artifactory-pro-debs xenial main" | tee -a /etc/apt/sources.list
curl https://bintray.com/user/downloadSubjectPublicKey?username=jfrog | apt-key add -
apt-get update -y
apt-get install -y jfrog-artifactory-pro > /tmp/install_artifactory.log

# Start Artifactory service
systemctl start artifactory.service