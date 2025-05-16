#!/bin/bash

set -e
set -o pipefail

print_message() {
  echo ""
  echo "================================================================="
  echo "            🧾 $(basename "$0"): $1 🧾          "
  echo "================================================================="
  echo ""
}

# OUTPUT_FILE="inventory.ini"
# TF_OUTPUT=$(terraform output -json private_ips)
TF_OUTPUT=$(terraform output -json)

if [[ -z "$TF_OUTPUT" ]]; then
  echo "❌ No Terraform output found. Make sure 'private_ips' output exists."
  exit 1
fi

# Check if any instance group key starts with "pvc"
pvc_keys=$(echo "$TF_OUTPUT" | jq -r '.public_ips.value | keys[]' | grep '^pvc')

if [[ -z "$pvc_keys" ]]; then
  echo "Skipping inventory generation: no PVC instance group found."
  exit 0
fi

# TF_OUTPUT_FILE="terraform_output.json"

# if [[ ! -f "$TF_OUTPUT_FILE" ]]; then
#   echo "File $TF_OUTPUT_FILE not found!"
#   exit 1
# fi

# TF_OUTPUT=$(cat "$TF_OUTPUT_FILE")

# print_message "Generating Ansible inventory..."

# # Extract internal IPs from Terraform output
# extract_private_ips() {
#   local pattern=$1
#   echo "$TF_OUTPUT" | jq -r --arg pattern "$pattern" '
#     .private_ips.value
#     | to_entries[]
#     | select(.key | test($pattern))
#     | .value
#   ' | grep -v null
# }

# Extract Public IPs from Terraform output
extract_public_ips() {
  local pattern=$1
  echo "$TF_OUTPUT" | jq -r --arg pattern "$pattern" '
    .public_ips.value
    | to_entries[]
    | select(.key | test($pattern))
    | .value
  ' | grep -v null
}

# Function to print a section with hostnames and ansible_host values
generate_inventory_section() {
  local group=$1
  shift
  local ips=("$@")
  local name_prefix=$group

  echo "[$group]"

  local index=1
  for ip in "${ips[@]}"; do
    local hostname
    case "$group" in
      ipaserver)
        hostname="ipaserver"
        ;;
      cldr-mngr)
        hostname="cldr-mngr"
        ;;
      base-masters)
        hostname="pvcbase-master"
        ;;
      base-workers)
        hostname="pvcbase-worker${index}"
        ;;
      ecs-masters)
        hostname="pvcecs-master"
        ;;
      ecs-workers)
        hostname="pvcecs-worker${index}"
        ;;
    esac

    echo "$hostname ansible_host=$ip cldr_hostname=$hostname"
    index=$((index + 1))
  done

  echo
}

# # Collect all IPs
# ipa_server_ips=( $(extract_private_ips "^ipa_server") )
# cldr_mngr_ips=( $(extract_private_ips "^cldr_mngr") )
# pvcbase_master_ips=( $(extract_private_ips "^pvcbase_master") )
# pvcbase_worker_ips=( $(extract_private_ips "^pvcbase_worker") )
# pvcecs_master_ips=( $(extract_private_ips "^pvcecs_master") )
# pvcecs_worker_ips=( $(extract_private_ips "^pvcecs_worker") )

# Collect all IPs
ipa_server_ips=( $(extract_public_ips "^ipa_server") )
cldr_mngr_ips=( $(extract_public_ips "^cldr_mngr") )
pvcbase_master_ips=( $(extract_public_ips "^pvcbase_master") )
pvcbase_worker_ips=( $(extract_public_ips "^pvcbase_worker") )
pvcecs_master_ips=( $(extract_public_ips "^pvcecs_master") )
pvcecs_worker_ips=( $(extract_public_ips "^pvcecs_worker") )

# Generate actual inventory output
generate_inventory_section "ipaserver" "${ipa_server_ips[@]}"
generate_inventory_section "cldr-mngr" "${cldr_mngr_ips[@]}"
generate_inventory_section "base-masters" "${pvcbase_master_ips[@]}"
generate_inventory_section "base-workers" "${pvcbase_worker_ips[@]}"
generate_inventory_section "ecs-masters" "${pvcecs_master_ips[@]}"
generate_inventory_section "ecs-workers" "${pvcecs_worker_ips[@]}"

## Generate semicolon-commented legacy entries
#echo "; [ipaserver]"
#for ip in "${ipa_server_ips[@]}"; do echo "; $ip cldr_hostname=ipaserver"; done
#echo
#
#echo "; [cldr-mngr]"
#for ip in "${cldr_mngr_ips[@]}"; do echo "; $ip cldr_hostname=cldr-mngr"; done
#echo "; # cldr-mngr ansible_host=192.168.1.100 ansible_user=ec2-user"
#echo
#
#echo "; [base-masters]"
#for ip in "${pvcbase_master_ips[@]}"; do echo "; $ip cldr_hostname=pvcbase-master"; done
#echo
#
#echo "; [base-workers]"
#i=1
#for ip in "${pvcbase_worker_ips[@]}"; do
#  echo "; $ip cldr_hostname=pvcbase-worker${i}"
#  ((i++))
#done
#echo
#
#echo "; [ecs-masters]"
#for ip in "${pvcecs_master_ips[@]}"; do echo "; $ip cldr_hostname=pvcecs-master"; done
#echo
#
#echo "; [ecs-workers]"
#i=1
#for ip in "${pvcecs_worker_ips[@]}"; do
#  echo "; $ip cldr_hostname=pvcecs-worker${i}"
#  ((i++))
#done

# print_message "Inventory generated at: $OUTPUT_FILE"
# cat "$OUTPUT_FILE"
# print_message "Ansible inventory generation completed."
# print_message "Please check the inventory.ini file for the generated Ansible inventory."