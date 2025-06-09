#!/bin/bash

set -e

### CONFIGURATION ###
REPO_URL="https://github.infra.cloudera.com/GOES/pvc-community-edition-aws.git"
REPO_DIR="pvc-community-edition-aws"
VENV_DIR="$HOME/cdp-navigator"
CONFIG_FILE="config.yml"
CONFIG_TEMPLATE="config-template.yml"
LICENSE_FILE="license.txt"
SSH_KEY_FILE="$HOME/.ssh/id_rsa"

### FUNCTIONS ###
print_usage() {
  echo "Usage: $0 [deploy|teardown] --region <aws-region> --prefix <name-prefix> --owner_email <email> --password <common-password> [--sso]"
  echo
  echo "Example:"
  echo "  $0 deploy --region us-west-2 --prefix demo-pvc --owner_email you@example.com --password 'Str0ngP@ssword!' --sso"
  exit 1
}

check_prerequisites() {
  echo "🔍 Checking prerequisites..."
  command -v aws >/dev/null 2>&1 || { echo "❌ AWS CLI is not installed. Please install it."; exit 1; }
  command -v git >/dev/null 2>&1 || { echo "❌ git is not installed. Please install it."; exit 1; }
  command -v pip3 >/dev/null 2>&1 || { echo "❌ pip3 is not installed. Please install it."; exit 1; }
  command -v python3 >/dev/null 2>&1 || { echo "❌ python3 is not installed. Please install it."; exit 1; }
  
  echo "🔍 Checking Docker..."
  # Check if docker command exists
  if ! command -v docker &> /dev/null; then
    echo "❌ Docker is not installed. Please install Docker and try again."
    exit 1
  fi
  
  # Check if Docker daemon is running
  if ! docker info > /dev/null 2>&1; then
    echo "❌ Docker daemon is not running. Please start Docker and try again."
    exit 1
  fi
  
  echo "✅ Docker is installed and running."
}

setup_virtualenv() {
  echo "🔧 Setting up Python virtual environment..."
  pip3 install --quiet virtualenv
  python3 -m venv "$VENV_DIR"
  source "$VENV_DIR/bin/activate"
  pip3 install --quiet ansible-core ansible-navigator virtualenv
}

configure_aws() {
  if [[ "$USE_SSO" == true ]]; then
    echo "🔐 Using AWS SSO for login..."
    unset AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY AWS_CREDENTIAL_EXPIRATION AWS_SESSION_TOKEN
    aws sso login
    eval $(aws configure export-credentials --format env)
  else
    echo "🔐 Using static AWS credentials from default profile."
  fi
}

prepare_files() {
  echo "📂 Validating required files..."
  [[ -f "$LICENSE_FILE" ]] || { echo "❌ License file '$LICENSE_FILE' not found."; exit 1; }
  [[ -f "$SSH_KEY_FILE" ]] || {
    echo "🔑 SSH private key not found. Generating a new one..."
    ssh-keygen -t rsa -b 4096 -f "$SSH_KEY_FILE"
  }

  export SSH_PRIVATE_KEY_FILE="$SSH_KEY_FILE"
  export CDP_LICENSE_FILE="$LICENSE_FILE"
}

prepare_config() {
  echo "📝 Preparing configuration..."
  cp "$CONFIG_TEMPLATE" "$CONFIG_FILE"
  sed -i "s|<unique-deployment-name>|$NAME_PREFIX|g" "$CONFIG_FILE"
  sed -i "s|<aws-region-code>|$AWS_REGION|g" "$CONFIG_FILE"
  sed -i "s|<secure-password>|$COMMON_PASSWORD|g" "$CONFIG_FILE"
  sed -i "s|<your-email@cloudera.com>|$OWNER_EMAIL|g" "$CONFIG_FILE"
}

run_ansible() {
  if [[ "$ACTION" == "deploy" ]]; then
    echo "🚀 Deploying CDP PVC Community Edition..."
    ansible-navigator run infrastructure_setup.yml services_setup.yml cm_setup.yml ozone-cluster.yml -e "@$CONFIG_FILE"
  else
    echo "🧹 Tearing down the environment..."
    ansible-navigator run infrastructure_teardown.yml -e "@$CONFIG_FILE"
  fi
}

### MAIN SCRIPT ###
ACTION="$1"
shift || print_usage

[[ "$ACTION" == "deploy" || "$ACTION" == "teardown" ]] || print_usage

while [[ $# -gt 0 ]]; do
  case "$1" in
    --region) AWS_REGION="$2"; shift ;;
    --prefix) NAME_PREFIX="$2"; shift ;;
    --owner_email) OWNER_EMAIL="$2"; shift ;;
    --password) COMMON_PASSWORD="$2"; shift ;;
    --sso) USE_SSO=true ;;
    *) echo "Unknown argument: $1"; print_usage ;;
  esac
  shift
done

[[ -z "$AWS_REGION" || -z "$NAME_PREFIX" || -z "$OWNER_EMAIL" || -z "$COMMON_PASSWORD" ]] && print_usage

check_prerequisites

# Clone or update repo
if [[ -d "$REPO_DIR/.git" ]]; then
  echo "🔄 Repository already cloned. Pulling latest changes..."
  cd "$REPO_DIR"
  git pull
else
  echo "📥 Cloning repository..."
  git clone "$REPO_URL"
  cd "$REPO_DIR"
fi

setup_virtualenv
configure_aws
prepare_files
[[ "$ACTION" == "deploy" ]] && prepare_config
run_ansible

echo "✅ Done."
