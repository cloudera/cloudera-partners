#!/bin/bash

# How to run: OWNER=myname ENVIRONMENT=production ./run_terraform_wrapper.sh

# make sure aws credentials are set or if using sso then logged in to awscli.
set -e
set -o pipefail

GIT_REPO_NAME="cdp-onprem-automation"
GIT_REPO_URL="https://github.com/kuldeepsahu1105/$GIT_REPO_NAME.git"
echo "GIT_REPO_URL: $GIT_REPO_URL"
GIT_BRANCH="dev/terraform"

print_message() {
    echo ""
    echo "================================================================="
    echo "            🚀 $(echo "$0": "$1") 🚀          "
    echo "================================================================="
    echo ""
}

# ------------------------------
# 🛠 INSTALL TERRAFORM & AWSCLI V2 (macOS/Linux)
# ------------------------------
install_terraform() {
    print_message "Checking Terraform installation..."

    if command -v terraform &>/dev/null; then
        echo "✅ Terraform already installed: $(terraform version | head -n1)"
        return
    fi

    OS=$(uname | tr '[:upper:]' '[:lower:]')
    if [[ "$OS" == "darwin" ]]; then
        echo "🧰 Installing Terraform using Homebrew on macOS..."
        brew tap hashicorp/tap
        if [[ "$TERRAFORM_VERSION" == "latest" ]]; then
            brew install hashicorp/tap/terraform
        else
            brew install hashicorp/tap/terraform@$TERRAFORM_VERSION
            brew link --overwrite --force terraform@$TERRAFORM_VERSION
        fi
    elif [[ "$OS" == "linux" ]]; then
        echo "🧰 Installing Terraform $TERRAFORM_VERSION on Linux..."
        VERSION=$(curl -s https://checkpoint-api.hashicorp.com/v1/check/terraform | jq -r .current_version)
        [[ "$TERRAFORM_VERSION" != "latest" ]] && VERSION="$TERRAFORM_VERSION"
        curl -fsSL "https://releases.hashicorp.com/terraform/${VERSION}/terraform_${VERSION}_linux_amd64.zip" -o terraform.zip
        unzip terraform.zip
        sudo mv terraform /usr/local/bin/
        rm -f terraform.zip
    else
        echo "❌ Unsupported OS: $OS"
        exit 1
    fi
    echo "✅ Terraform installed: $(terraform version | head -n1)"
}

install_awscli() {
    print_message "Checking AWS CLI installation..."

    if command -v aws &>/dev/null && [[ "$(aws --version 2>&1)" == *"aws-cli/2"* ]]; then
        echo "✅ AWS CLI v2 already installed: $(aws --version)"
        return
    fi

    OS=$(uname | tr '[:upper:]' '[:lower:]')
    if [[ "$OS" == "darwin" ]]; then
        echo "🧰 Installing AWS CLI v2 using Homebrew on macOS..."
        brew install awscli
    elif [[ "$OS" == "linux" ]]; then
        echo "🧰 Installing AWS CLI v2 on Linux..."
        curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
        unzip awscliv2.zip
        sudo ./aws/install --update
        rm -rf aws awscliv2.zip
    else
        echo "❌ Unsupported OS: $OS"
        exit 1
    fi
    echo "✅ AWS CLI installed: $(aws --version)"
}

install_terraform
install_awscli

# ------------------------------
# ✅ AWS CREDENTIALS CHECK
# ------------------------------
print_message "Checking AWS credentials..."
if ! aws sts get-caller-identity &>/dev/null; then
    echo "❌ Error: AWS credentials not found or session expired. Run 'aws configure' or 'aws sso login'."
    exit 1
fi
echo "✅ AWS credentials are valid."

# ------------------------------
# 🔍 CHECK .tfvars.env FILE
# ------------------------------
print_message "Checking for .tfvars.env file..."
if [ ! -f ".tfvars.env" ]; then
    echo "❌ Error: .tfvars.env file not found in the current directory ($(pwd))."
    exit 1
else
    echo "✅ .tfvars.env file found."
fi

# ------------------------------
# 📁 CLONE AND CD INTO REPO
# ------------------------------
print_message "Checking Git installation..."
if ! command -v git &>/dev/null; then
    echo "❌ Git is not installed. Installing Git..."
    OS=$(uname | tr '[:upper:]' '[:lower:]')
    if [[ "$OS" == "darwin" ]]; then
        echo "🧰 Installing Git using Homebrew on macOS..."
        brew install git
    elif [[ "$OS" == "linux" ]]; then
        echo "🧰 Installing Git on Linux..."
        sudo apt-get update && sudo apt-get install -y git || sudo yum install -y git
    else
        echo "❌ Unsupported OS: $OS"
        exit 1
    fi
    echo "✅ Git installed: $(git --version)"
else
    echo "✅ Git already installed: $(git --version)"
fi

set -a
source .tfvars.env
set +a
# ------------------------------
# 🔧 OVERRIDABLE CONFIG SECTION
# ------------------------------
# AWS_REGION: Specify the AWS region for deployment (e.g., ap-southeast-1).
# OWNER: Tag to identify the resource owner.
# ENVIRONMENT: Deployment environment (e.g., development, staging, production).
# TERRAFORM_VERSION: Version of Terraform to use; 'latest' will use the most recent version.
AWS_REGION="${AWS_REGION:-ap-southeast-1}"
OWNER="${OWNER:-ksahu}"
ENVIRONMENT="${ENVIRONMENT:-development}"
TERRAFORM_VERSION="${TERRAFORM_VERSION:-latest}"

print_message "Verify environment name : '$ENVIRONMENT' is set from .tfvars.env file"

print_message "Cloning repository if needed..."

if [ ! -d "$GIT_REPO_NAME" ]; then
    git clone "$GIT_REPO_URL"
    cd $GIT_REPO_NAME || exit 1
    git checkout "$GIT_BRANCH"
    cd ..
else
    cd $GIT_REPO_NAME || exit 1
    git fetch origin
    git checkout "$GIT_BRANCH"
    git pull origin "$GIT_BRANCH"
    cd ..
fi

cd $GIT_REPO_NAME/cloudera-pvc-terraform || exit 1

# ------------------------------
# 🔧 OVERRIDABLE CONFIG SECTION
# ------------------------------
# Section moved to .tfvars.env file

# ------------------------------
# 🌱 SET TERRAFORM WORKSPACE
# ------------------------------
print_message "Setting Terraform workspace to '${ENVIRONMENT}'..."
if terraform workspace list | grep -q "${ENVIRONMENT}"; then
    terraform workspace select "${ENVIRONMENT}"
else
    terraform workspace new "${ENVIRONMENT}"
fi

# ------------------------------
# 🧠 DYNAMIC VARS ASSEMBLY
# ------------------------------
# This contains all the variables that are passed to Terraform in order
# i.e. COMMON_VARS, VPC_VARS, SG_VARS, EIP_VARS, KEYPAIR_VARS, INSTANCE_GROUPS_VARS
# Section moved to .tfvars.env file

# ------------------------------
# 🚀 TERRAFORM EXECUTION
# ------------------------------
print_message "Initializing Terraform..."
terraform init

print_message "Planning Terraform..."
terraform plan "${TF_VARS[@]}" -out=tfplan.out

print_message "Applying Terraform..."
echo "TF_DATA_DIR: $TF_DATA_DIR"
echo "PWD: $(pwd)"
ls -l terraform.tfstate* || true
echo
terraform apply -auto-approve tfplan.out

print_message "✅ Terraform provisioning complete!"

# ------------------------------
# 🧾 GENERATE INVENTORY
# ------------------------------
print_message "Running generate_inventory.sh..."
print_message "Generating Ansible inventory..."

# Resolve script's base directory
# SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# Resolve script's base directory
# Resolve script's base directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
echo "SCRIPT_DIR is: $SCRIPT_DIR"

# Check if generate_inventory.sh exists in the current script directory
if [ -f "$SCRIPT_DIR/generate_inventory.sh" ]; then
    GEN_SCRIPT="$SCRIPT_DIR/generate_inventory.sh"
# Else, check if it exists one level up in the cdp-onprem-automation directory
elif [ -f "$SCRIPT_DIR/../generate_inventory.sh" ]; then
    GEN_SCRIPT="$SCRIPT_DIR/../generate_inventory.sh"
else
    echo "❌ Error: generate_inventory.sh not found in $SCRIPT_DIR or its parent directory."
    exit 1
fi

# ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
# GEN_SCRIPT="$ROOT_DIR/generate_inventory.sh"
OUTPUT_FILE="ansible_inventory.ini"

if [ -f "$GEN_SCRIPT" ]; then
    # bash "$GEN_SCRIPT" > "$OUTPUT_FILE" 2>&1
    bash "$GEN_SCRIPT" | tee "$OUTPUT_FILE"
else
    echo "❌ Error: generate_inventory.sh not found at $GEN_SCRIPT"
    exit 1
fi

print_message "Inventory generated at: $OUTPUT_FILE"
cat "$OUTPUT_FILE"
print_message "Ansible inventory generation completed."
print_message "Please check the inventory.ini file for the generated Ansible inventory."

# ------------------------------
# Define source and destination paths
# ------------------------------
echo "PWD: $(pwd)"
src_inventory="./$OUTPUT_FILE"
ansible_dir="../ansible-cloudera-pvc"
dest_inventory="$ansible_dir/inventory.ini"

# Check if inventory.ini exists in current directory
if [ -f "$src_inventory" ]; then
    echo "✅ Found inventory.ini in current directory."

    # Check if ansible directory exists
    if [ -d "$ansible_dir" ]; then
        echo "✅ Found Ansible directory: $ansible_dir"

        # Check if destination path is valid (redundant but safe)
        if [ -d "$(dirname "$dest_inventory")" ]; then
            cp -vf "$src_inventory" "$dest_inventory"
            echo "📂 Copied $src_inventory to $dest_inventory"
        else
            echo "❌ Error: Destination directory $(dirname "$dest_inventory") not found."
            exit 1
        fi
    else
        echo "❌ Error: Ansible directory $ansible_dir not found."
        exit 1
    fi
else
    echo "❌ Error: inventory.ini not found in $(pwd)"
    exit 1
fi

# ------------------------------
# 🔐 PEM file check and copy
# ------------------------------
pem_file=$(find . -maxdepth 1 -type f \( -name "*.pem" \))
if [ -z "$pem_file" ]; then
    echo "❌ Error: No .pem or idrsa file found."
    # exit 1
else
    echo "✅ Found key file: $pem_file"
    # cp -vf "$pem_file" "$ansible_dir/$pem_file"
    # echo "📂 Copied $pem_file to $ansible_dir/$pem_file"

    cp -vf "$pem_file" "../../$pem_file"
    echo "📂 Copied $pem_file to ../../$pem_file"
fi

# # ------------------------------

# #!/bin/bash

# set -e
# set -o pipefail

# print_message() {
#   echo ""
#   echo "================================================================="
#   echo "            🚀 $(echo $0: $1) 🚀          "
#   echo "================================================================="
#   echo ""
# }

# # ------------------------------
# # 🔧 OVERRIDABLE CONFIG SECTION
# # ------------------------------
# AWS_REGION="${AWS_REGION:-ap-southeast-1}"
# OWNER="${OWNER:-ksahu-ygulati}"
# ENVIRONMENT="${ENVIRONMENT:-development}"
# TERRAFORM_VERSION="${TERRAFORM_VERSION:-latest}"

# # ------------------------------
# # ✅ INSTALL TERRAFORM & AWS CLI
# # ------------------------------
# install_tools() {
#   print_message "Checking Terraform and AWS CLI..."

#   # Check Terraform
#   if ! command -v terraform &> /dev/null; then
#     print_message "Installing Terraform..."
#     if [[ "$OSTYPE" == "darwin"* ]]; then
#       brew tap hashicorp/tap
#       brew install hashicorp/tap/terraform
#     else
#       sudo apt-get update && sudo apt-get install -y unzip wget
#       LATEST_URL=$(curl -s https://api.github.com/repos/hashicorp/terraform/releases/latest | grep browser_download_url | grep linux_amd64.zip | cut -d '"' -f 4)
#       wget -q "$LATEST_URL" -O terraform.zip
#       unzip -o terraform.zip
#       sudo mv terraform /usr/local/bin/
#       rm -f terraform.zip
#     fi
#   fi

#   # Check AWS CLI
#   if ! command -v aws &> /dev/null; then
#     print_message "Installing AWS CLI..."
#     if [[ "$OSTYPE" == "darwin"* ]]; then
#       brew install awscli
#     else
#       curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
#       unzip awscliv2.zip
#       sudo ./aws/install
#       rm -rf awscliv2.zip aws/
#     fi
#   fi

#   echo "✅ Tools ready."
# }

# install_tools

# # ------------------------------
# # ✅ AWS CREDENTIALS CHECK
# # ------------------------------
# print_message "Checking AWS credentials..."
# if ! aws sts get-caller-identity &>/dev/null; then
#   echo "❌ AWS credentials not found or session expired. Run 'aws configure' or 'aws sso login'."
#   exit 1
# fi
# echo "✅ AWS credentials are valid."

# # ------------------------------
# # 📁 CLONE AND CD INTO REPO
# # ------------------------------
# print_message "Cloning repository if needed..."
# if [ ! -d "pvc-automation" ]; then
#   git clone https://github.com/kuldeepsahu1105/pvc-automation.git
# fi
# cd pvc-automation/terraform-code/cloudera-pvc-terraform || exit 1

# # ------------------------------
# # 🛠️ Terraform Workspace Handling
# # ------------------------------
# print_message "Setting up Terraform workspace: $ENVIRONMENT"
# if terraform workspace list | grep -qw "$ENVIRONMENT"; then
#   terraform workspace select "$ENVIRONMENT"
# else
#   terraform workspace new "$ENVIRONMENT"
# fi
