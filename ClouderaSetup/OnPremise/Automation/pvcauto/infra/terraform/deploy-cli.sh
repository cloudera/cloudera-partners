#!/usr/bin/env bash

if [[ $# -lt 4 ]]; then
  echo "Usage: $0 <DEPLOYMENT_MODE> <AWS_ACCESS_KEY> <AWS_SECRET_KEY> <KEY_PAIR_NAME> [AWS_REGION]"
  exit 1
fi

MODE="$1"
AWS_ACCESS_KEY="$2"
AWS_SECRET_KEY="$3"
KEY_NAME="$4"
AWS_REGION="${5:-us-east-1}"

BASE="$(pwd)"
CONFIG="$BASE/config/deployments.yml"
TF_DIR="$BASE/infra/terraform"
ANS_DIR="$BASE/infra/ansible"
TF_VARS="$TF_DIR/terraform.tfvars.json"
HOSTS_INI="$ANS_DIR/hosts.ini"


eval "$(
  python3 - "$CONFIG" "$MODE" <<'PYCODE'
import sys, yaml
cfg = yaml.safe_load(open(sys.argv[1])) or {}
for d in cfg.get("deployments", []):
    if d["name"] == sys.argv[2]:
        print(f'AMI_ID="{d["ami_id"]}"')
        print(f'INSTANCE_TYPE="{d["instance_type"]}"')
        print(f'INSTANCE_COUNT={d["instance_count"]}')
        print(f'VPC_ID="{d["vpc_id"]}"')
        print(f'REQUIRED_EIP={str(d["required_elastic_ip"]).lower()}')
        sys.exit(0)
sys.exit("Error: deployment mode not found in config")')
PYCODE
)"


cat > "$TF_VARS" <<EOF
{
  "deployment_mode":    "$MODE",
  "aws_access_key":     "$AWS_ACCESS_KEY",
  "aws_secret_key":     "$AWS_SECRET_KEY",
  "aws_region":         "$AWS_REGION",
  "ami_id":             "$AMI_ID",
  "instance_type":      "$INSTANCE_TYPE",
  "instance_count":     $INSTANCE_COUNT,
  "key_name":           "$KEY_NAME",
  "vpc_id":             "$VPC_ID",
  "required_elastic_ip": $REQUIRED_EIP
}
EOF

echo "Generated $TF_VARS"

# Terraform init & apply 
cd "$TF_DIR"
terraform init -input=false
terraform apply -auto-approve -input=false \
  -var-file=terraform.tfvars.json

# Capture instance IPs 
IPS_JSON="$(terraform output -json)"
IPS=( $(echo "$IPS_JSON" | python3 -c "import sys, json; print(' '.join(json.load(sys.stdin)['instance_ips']['value']))") )

if [ ${#IPS[@]} -eq 0 ]; then
  echo "❌ No instance IPs found in Terraform output."
  exit 1
fi

# Generate Ansible inventory 
cd "$ANS_DIR"
cat > hosts.ini <<EOL
[ec2_instances]
$(for ip in "${IPS[@]}"; do
  echo "$ip ansible_user=ec2-user ansible_private_key_file=~/.ssh/${KEY_NAME}.pem -o StrictHostKeyChecking=no"
done)
EOL

echo "✅ Wrote Ansible inventory to hosts.ini"

# Run Ansible playbook 
ansible-playbook -i hosts.ini playbook.yml

echo " Deployment complete!"
