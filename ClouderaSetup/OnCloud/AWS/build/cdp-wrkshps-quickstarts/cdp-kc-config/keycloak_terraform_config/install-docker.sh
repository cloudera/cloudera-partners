#!/bin/bash

# Update package list and install necessary packages
apt-get update
#apt-get -y upgrade
apt-get -y install software-properties-common
apt-add-repository --yes --update ppa:ansible/ansible
apt-get -y install ansible

# Add Docker's official GPG key:
apt-get -y install apt-transport-https ca-certificates curl 
install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
chmod a+r /etc/apt/keyrings/docker.asc

# Add the repository to Apt sources:
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
tee /etc/apt/sources.list.d/docker.list > /dev/null
apt-get update

apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin


# Start and enable Docker service
systemctl start docker
systemctl enable docker
docker run -d -p 5000:5000 --name hol_user_assignment_app clouderapartners/hol_user_assignment:latest
docker run -d -p 80:8080 --name=keycloak -e KEYCLOAK_ADMIN=admin -e KEYCLOAK_ADMIN_PASSWORD=${keycloak_admin_password} keycloak/keycloak start-dev >> /tmp/kc_init.log
sleep 40
docker exec keycloak /opt/keycloak/bin/kcadm.sh config credentials --server http://localhost:8080 --realm master --user admin --password ${keycloak_admin_password} >> /tmp/kc_init.log
sleep 5
docker exec keycloak /opt/keycloak/bin/kcadm.sh update realms/master -s sslRequired=NONE --server http://localhost:8080 --realm master --user admin --password ${keycloak_admin_password} >> /tmp/kc_init.log
