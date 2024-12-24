#!/bin/bash

# Update package list and install necessary packages
apt-get update
#apt-get -y upgrade
apt-get -y install software-properties-common
apt-add-repository --yes --update ppa:ansible/ansible
apt-get -y install ansible openssl
#mkdir -p /usr/local/share/ca-certificates/

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

mkdir /root/kcsslcerts/
cd /root/kcsslcerts/

# Variables
ROOT_CA_KEY="rootCA.key"
ROOT_CA_CRT="rootCA.crt"
SERVER_KEY="server.key"
SERVER_CSR="server.csr"
SERVER_CRT="server.crt"
KEYSTORE_DIR="/etc/ssl/certs"
HOSTNAME="partnerworkshop.clouderapartners.com"
SERVER_PEM="server.pem"
CERT_PEM="server-cert.pem"
ROOT_CA_PASS="rootpassword"
SERVER_KEY_PASS="serverpassword"

# Function to generate Root CA (Non-Interactive)
generate_root_ca() {
  echo "Generating Root Certificate Authority (CA)..."
  
  # Generate Root CA private key (password protected)
  openssl genpkey -algorithm RSA -out ${ROOT_CA_KEY} -aes256 -pass pass:${ROOT_CA_PASS}

  # Generate Root CA certificate (self-signed)
  openssl req -x509 -new -nodes -key ${ROOT_CA_KEY} -sha256 -days 3650 -out ${ROOT_CA_CRT} \
    -subj "/C=US/ST=California/L=Santa Clara/O=Cloudera Inc./OU=PSE/CN=${HOSTNAME} CA" \
    -passin pass:${ROOT_CA_PASS}

  echo "Root CA generated successfully!"
}

# Function to generate Server Key and CSR (Non-Interactive)
generate_server_csr() {
  echo "Generating Server Key and CSR..."

  # Generate Server private key (password protected)
  openssl genpkey -algorithm RSA -out ${SERVER_KEY} -aes256 -pass pass:${SERVER_KEY_PASS}

  # Generate Server Certificate Signing Request (CSR)
  openssl req -new -key ${SERVER_KEY} -out ${SERVER_CSR} -subj "/C=US/ST=California/L=Santa Clara/O=Cloudera Inc./OU=PSE/CN=${HOSTNAME}" \
    -passin pass:${SERVER_KEY_PASS}

  echo "Server CSR generated successfully!"
}

# Function to sign the server CSR with the root CA (Non-Interactive)
sign_server_csr() {
  echo "Signing Server CSR with Root CA..."

  # Sign the CSR with the Root CA and generate the server certificate
  openssl x509 -req -in ${SERVER_CSR} -CA ${ROOT_CA_CRT} -CAkey ${ROOT_CA_KEY} -CAcreateserial -out ${SERVER_CRT} \
    -days 365 -sha256 -passin pass:${ROOT_CA_PASS}

  echo "Server certificate signed successfully!"
}

# Function to remove passphrase from the Server Private Key
remove_passphrase_from_key() {
  echo "Removing passphrase from the server private key..."

  # Remove passphrase from the server private key (non-interactive)
  openssl rsa -in ${SERVER_KEY} -out ${SERVER_PEM} -passin pass:${SERVER_KEY_PASS}

  echo "Passphrase removed from the server private key!"
}

# Function to convert the Server Certificate to PEM format
convert_to_pem() {
  echo "Converting server certificate to PEM format..."

  # Convert Server Certificate to PEM format
  openssl x509 -in ${SERVER_CRT} -out ${CERT_PEM}

  echo "PEM files created successfully!"
}

# Function to trust the Root CA (Linux)
trust_root_ca() {
  echo "Installing Root CA into system trust store..."

  # Copy the Root CA to the system's CA certificate store
  cp ${ROOT_CA_CRT} /usr/local/share/ca-certificates/${HOSTNAME}-CA.crt

  # Update the system's certificate store
  update-ca-certificates

  echo "Root CA installed successfully into trust store!"
}

# Main execution (Non-Interactive)
generate_root_ca
generate_server_csr
sign_server_csr
remove_passphrase_from_key
convert_to_pem
trust_root_ca

echo "All operations completed successfully!"
docker run -d -p 5000:5000 --name hol_user_assignment_app clouderapartners/hol_user_assignment:latest
#docker run -d -p 80:8080 --name=keycloak -e KEYCLOAK_ADMIN=admin -e KEYCLOAK_ADMIN_PASSWORD=${keycloak_admin_password} keycloak/keycloak start-dev >> /tmp/kc_init.log
docker run -d -p 80:8080 -p 443:8443 -v /root/kcsslcerts/server-cert.pem:/etc/x509/https/tls.crt -v /root/kcsslcerts/server.pem:/etc/x509/https/tls.key --name=keycloak -e KC_BOOTSTRAP_ADMIN_USERNAME=admin -e KC_BOOTSTRAP_ADMIN_PASSWORD=admin -e KC_HTTPS_CERTIFICATE_FILE=/etc/x509/https/tls.crt -e KC_HTTPS_CERTIFICATE_KEY_FILE=/etc/x509/https/tls.key -e KC_HTTP_ENABLED=true -e KC_HTTPS_ENABLED=true -e KC_HOSTNAME_STRICT=false keycloak/keycloak:latest start >> /tmp/kc_init.log
sleep 40
docker exec keycloak /opt/keycloak/bin/kcadm.sh config credentials --server http://localhost:8080 --realm master --user admin --password ${keycloak_admin_password} >> /tmp/kc_init.log
sleep 5
docker exec keycloak /opt/keycloak/bin/kcadm.sh update realms/master --server http://localhost:8080 -s sslRequired=external --realm master --user admin --password ${keycloak_admin_password} >> /tmp/kc_init.log
