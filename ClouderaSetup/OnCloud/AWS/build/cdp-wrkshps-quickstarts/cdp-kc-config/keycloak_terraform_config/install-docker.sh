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
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" |
  tee /etc/apt/sources.list.d/docker.list >/dev/null
apt-get update

apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Start and enable Docker service
systemctl start docker
systemctl enable docker

ls -l /etc/ssl/certs
mkdir -p /etc/ssl/certs

# Variables
SUBDOMAIN="${workshop_name}.${domain}"

# Decode SSL certificates passed from Terraform
echo "${wildcard_fullchain}" | base64 -d >/etc/ssl/certs/fullchain.pem
echo "${wildcard_privkey}" | base64 -d >/etc/ssl/certs/privkey.pem

# Run Keycloak Docker container with mounted SSL certificates
echo "Starting Keycloak Docker container..."

#docker run -d -p 5000:5000 --name hol_user_assignment_app clouderapartners/hol_user_assignment:latest
#docker run -d -p 80:8080 --name=keycloak -e KEYCLOAK_ADMIN=admin -e KEYCLOAK_ADMIN_PASSWORD=${keycloak_admin_password} keycloak/keycloak start-dev >> /tmp/kc_init.log
#sleep 40
#docker exec keycloak /opt/keycloak/bin/kcadm.sh config credentials --server http://localhost:8080 --realm master --user admin --password ${keycloak_admin_password} >> /tmp/kc_init.log
#sleep 5
#docker exec keycloak /opt/keycloak/bin/kcadm.sh update realms/master -s sslRequired=NONE --server http://localhost:8080 --realm master --user admin --password ${keycloak_admin_password} >> /tmp/kc_init.log

# Start the 'hol_user_assignment_app' container
docker run -d \
  --name hol_user_assignment_app \
  -p 5000:5000 \
  clouderapartners/hol_user_assignment:latest

# Start Keycloak with SSL enabled using Let's Encrypt certificates
docker run -d \
  -p 80:8080 -p 443:8443 \
  -v /etc/ssl/certs/fullchain.pem:/etc/x509/https/tls.crt \
  -v /etc/ssl/certs/privkey.pem:/etc/x509/https/tls.key \
  --name keycloak \
  -e KC_BOOTSTRAP_ADMIN_USERNAME=admin \
  -e KC_BOOTSTRAP_ADMIN_PASSWORD=${keycloak_admin_password} \
  -e KC_HTTPS_CERTIFICATE_FILE=/etc/x509/https/tls.crt \
  -e KC_HTTPS_CERTIFICATE_KEY_FILE=/etc/x509/https/tls.key \
  -e KC_HTTP_ENABLED=true \
  -e KC_HTTPS_ENABLED=true \
  -e KC_HOSTNAME_STRICT=false \
  -e KC_HOSTNAME=$SUBDOMAIN \
  keycloak/keycloak:latest start >>/tmp/kc_init.log

# Wait for Keycloak to initialize
sleep 40

# Configure Keycloak using 'kcadm.sh' script
docker exec keycloak /opt/keycloak/bin/kcadm.sh config credentials \
  --server http://localhost:8080 \
  --realm master \
  --user admin \
  --password ${keycloak_admin_password} >>/tmp/kc_init.log

# Wait for a few seconds before updating realm settings
sleep 5

# Update the Keycloak realm settings (disable SSL requirement)
docker exec keycloak /opt/keycloak/bin/kcadm.sh update realms/master \
  --server http://localhost:8080 \
  -s sslRequired=external \
  --realm master \
  --user admin \
  --password ${keycloak_admin_password} >>/tmp/kc_init.log

# Confirm Keycloak is running
if [[ $(docker ps --filter "name=keycloak" --format "{{.Names}}") == "keycloak" ]]; then
  echo "Keycloak started successfully on $SUBDOMAIN"
else
  echo "Failed to start Keycloak"
  exit 1
fi

echo "All SSL cert related operations completed successfully! KeyCloak is up and running"
