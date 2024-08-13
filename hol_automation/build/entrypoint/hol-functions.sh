#!/bin/bash
# *************************************************************************************************************#
# Setting required path and variables.

USER_CONFIG_FILE="/userconfig/configfile"
KC_TF_CONFIG_DIR=$HOME_DIR/cdp-wrkshps-quickstarts/cdp-kc-config/keycloak_terraform_config
KC_ANS_CONFIG_DIR=$HOME_DIR/cdp-wrkshps-quickstarts/cdp-kc-config/keycloak_ansible_config
DS_CONFIG_DIR=$HOME_DIR/cdp-wrkshps-quickstarts/cdp-data-services
USER_ACTION=$1
validating_variables() {
   echo
   echo "                    ---------------------------------------------------------------------                "
   echo "                    Validating the Configfile and Verifying the Provided Input Parameters                "
   echo "                    ---------------------------------------------------------------------                "
   echo
   sleep 10
   if [ ! -f "/userconfig/configfile" ]; then
      echo "=================================================================================="
      echo "FATAL: Not able to find Config File ('configfile') inside /userconfig folder.
   Please make sure you have mounted the local directory using -v flag and you
   have created a file by name 'configfile' without any file extension like '.txt'.
   if you are running docker on windows then create the folder inside your
   'C:/Users/<Your_Windows_User_Name>/' and try again.
   Exiting......"
      echo "=================================================================================="
      exit 9999 # die with error code 9999

   fi
   # Cleaning up 'configfile' to remove ^M characters.
   sed -i 's/^M//g' $USER_CONFIG_FILE

   #--------------------------------------------------------------------------------------------------#

   # Function to check config file for missing keys and empty values
   check_config() {
      local USER_CONFIG_FILE="$1"

      # Define the required keys
      REQUIRED_KEYS=(
         "PROVISION_KEYCLOAK"
         "AWS_ACCESS_KEY_ID"
         "AWS_SECRET_ACCESS_KEY"
         "AWS_REGION"
         "AWS_KEY_PAIR"
         "WORKSHOP_NAME"
         "NUMBER_OF_WORKSHOP_USERS"
         "WORKSHOP_USER_PREFIX"
         "WORKSHOP_USER_DEFAULT_PASSWORD"
         "CDP_ACCESS_KEY_ID"
         "CDP_PRIVATE_KEY"
         "CDP_DEPLOYMENT_TYPE"
         "LOCAL_MACHINE_IP"
         "ENABLE_DATA_SERVICES"
      )
      echo "Provision_keycloak: $provision_keycloak"
      # Conditionally add Keycloak keys based on PROVISION_KEYCLOAK
      if [[ "$provision_keycloak" == "yes" ]]; then
         REQUIRED_KEYS+=(
            "KEYCLOAK_SERVER_NAME"
            "KEYCLOAK_ADMIN_PASSWORD"
            "KEYCLOAK_SECURITY_GROUP_NAME"
         )
      fi

      # Check if user-provided config file exists
      if [ ! -f "$USER_CONFIG_FILE" ]; then
         echo -e "\nUser config file not found :: $USER_CONFIG_FILE\n"
         return 1
      else
         echo -e "\nVerify Configfile Is Present ..... Passed"
      fi

      # Function to check if a key exists in the config file
      key_exists() {
         grep -q "^$1:" "$USER_CONFIG_FILE"
      }

      # Function to check if a key has a non-empty value in the config file
      key_has_value() {
         local value=$(grep "^$1:" "$USER_CONFIG_FILE" | cut -d ':' -f2- | sed 's/ //g')
         [ -n "$value" ]
      }

      # Check for missing keys and empty values
      local MISSING_KEYS=()
      local EMPTY_VALUES=()
      for key in "${REQUIRED_KEYS[@]}"; do
         if ! key_exists "$key"; then
            MISSING_KEYS+=("$key")
         elif ! key_has_value "$key"; then
            EMPTY_VALUES+=("$key")
         fi
      done

      # Report missing keys
      if [ ${#MISSING_KEYS[@]} -gt 0 ]; then
         echo -e "\nThe following keys are missing in the user config file:"
         for key in "${MISSING_KEYS[@]}"; do
            echo "- $key"
         done
         echo -e "Please update the 'configfile' and try again...\n"
      fi

      # Report keys with empty values
      if [ ${#EMPTY_VALUES[@]} -gt 0 ]; then
         echo -e "\nThe following keys have empty values in the user config file:"
         for key in "${EMPTY_VALUES[@]}"; do
            echo "- $key"
         done
         echo -e "Please update the 'configfile' and try again...\n"
      fi

      # Exising on missing keys
      if [ ${#MISSING_KEYS[@]} -gt 0 ] || [ ${#EMPTY_VALUES[@]} -gt 0 ]; then
         echo "========================================================================================="
         echo "EXITING......               "
         echo "========================================================================================="
         exit 1
      fi
   }

   #--------------------------------------------------------------------------------------------------#

   # Read variables from the text file

   while IFS=':' read -r key value; do
      if [[ $key && $value ]]; then
         key=$(echo "$key" | tr -d '[:space:]')     # Remove whitespace from the key
         value=$(echo "$value" | tr -d '[:space:]') # Remove whitespace from the value
         # Processing each variable
         case $key in
         PROVISION_KEYCLOAK)
            provision_keycloak=$(echo $value | tr '[:upper:]' '[:lower:]')
            ;;
         KEYCLOAK_SERVER_NAME)
            ec2_instance_name=$value
            ;;
         KEYCLOAK_ADMIN_PASSWORD)
            keycloak__admin_password=$value
            ;;
         AWS_ACCESS_KEY_ID)
            aws_access_key_id=$value
            ;;
         AWS_SECRET_ACCESS_KEY)
            aws_secret_access_key=$value
            ;;
         AWS_REGION)
            aws_region=$value
            ;;
         WORKSHOP_NAME)
            case $value in
            *_*)
               echo "=================================================================================="
               echo "FATAL: The value for Workshop Name parameter can not have underscore ('_').
   Please update the value in 'configfile' and try again."
               echo "=================================================================================="
               exit 1
               ;;
            *)
               workshop_name=$(echo "$value" | tr '[:upper:]' '[:lower:'])
               ;;
            esac
            ;;
         NUMBER_OF_WORKSHOP_USERS)
            number_of_workshop_users=$value
            ;;
         WORKSHOP_USER_PREFIX)
            workshop_user_prefix=$(echo "$value" | tr '[:upper:]' '[:lower:'])
            ;;
         WORKSHOP_USER_DEFAULT_PASSWORD)
            workshop_user_default_password=$value
            ;;
         CDP_ACCESS_KEY_ID)
            cdp_access_key_id=$value
            ;;
         CDP_PRIVATE_KEY)
            cdp_private_key=$value
            ;;
         AWS_KEY_PAIR)
            aws_key_pair=$value
            #echo "Found KeyPair File: $aws_key_pair.pem"
            ;;
         CDP_DEPLOYMENT_TYPE)
            if [[ "$value" == "public" || "$value" == "private" || "$value" == "semi-private" ]]; then
               deployment_template=$value
            else
               echo "=================================================================================="
               echo "FATAL: Invalid value for CDP Deployment Type. The allowed values are: 
               public (* all in lowercase *)
               private (* all in lowercase *)
               semi-private (* all in lowercase and one hyphen (-) *)

               ****Exiting****
               Please update the 'configfile' and try again."
               echo "=================================================================================="
               exit 9999
            fi
            ;;
         LOCAL_MACHINE_IP)
            local_ip=$value
            ;;
         KEYCLOAK_SECURITY_GROUP_NAME)
            keycloak_sg_name=$value
            ;;
         ENABLE_DATA_SERVICES)
            enable_data_services=$value
            ;;
         SIZE_OF_VIRTUAL_WAREHOUSE)
            size_of_virtual_warehouse=$value
            ;;
         CDE_INSTANCE_TYPE)
            cde_instance_type=$value
            ;;
         CDE_MIN_INSTANCES)
            cde_min_instances=$value
            ;;
         CDE_MAX_INSTANCES)
            cde_max_instances=$value
            ;;
         CDE_SPARK_VERSION)
            cde_spark_version=$value
            ;;
            # Can Add more cases if required.
         esac
      fi
   done <"$USER_CONFIG_FILE"

   # Call the function with the user-provided config file as an argument
   check_config "$USER_CONFIG_FILE"

   echo
   echo "                     -------------------------------------------------------------------                 "
   echo "                     Validated the Configfile and Verified the Provided Input Parameters                 "
   echo "                     -------------------------------------------------------------------                 "
   echo
}
#--------------------------------------------------------------------------------------------------------------#
# Function for checking .pem file.
key_pair_file() {
   # Checking if SSH Keypair File exists.
   if [[ ! -f "/userconfig/$aws_key_pair.pem" ]]; then
      echo "=================================================================================="
      echo "FATAL: SSH Key Pair File Not Found. Please place the '$aws_key_pair.pem' 
file in your config directory and try again.
EXITING....."
      echo "=================================================================================="
      exit 9999 # die with error code 9999
   fi
}
#-------------------------------------------------------------------------------------------------#
# Function to setup AWS & CDP CLI for user.
setup_aws_and_cdp_profile() {
   echo "               =================================================================================="
   echo "                                   Setting Up Your AWS & CDP Profile                               "
   echo "               =================================================================================="
   aws configure set aws_access_key_id $aws_access_key_id
   aws configure set aws_secret_access_key $aws_secret_access_key
   aws configure set default.region $aws_region
   cdp configure set cdp_access_key_id $cdp_access_key_id
   cdp configure set cdp_private_key $cdp_private_key
}
#---------------------------------------------------------------------------------------------------------------------#
# Function to verify AWS pre-requisites
aws_prereq() {
   vpc_limit=$(aws service-quotas get-service-quota \
      --service-code vpc \
      --output json \
      --region $aws_region \
      --quota-code L-F678F1CE | jq -r '.[]["Value"]')

   vpc_used=$(aws ec2 describe-vpcs --output json --region $aws_region | jq -r '.[] | length')
   echo -e "\nCurrent VPC count: $vpc_used"

   if [ $vpc_limit -gt $vpc_used ]; then
      echo -e "Check Available VPC ..... Passed"
   else
      echo
      echo "************************************************************************************************************************************************************"
      echo "* Fatal !! Can't Continue: The VPC limit has been reached in the $aws_region region. Either select any other region in 'configfile' or remove unused VPC's *"
      echo "************************************************************************************************************************************************************"
      exit
   fi
   eip_limit=$(aws service-quotas get-service-quota \
      --service-code ec2 \
      --output json \
      --region $aws_region \
      --quota-code L-0263D0A3 | jq -r '.[]["Value"]')
   eip_used=$(aws ec2 describe-addresses --output json --region $aws_region | jq -r '.[] | length')
   echo -e "\nCurrent ElasticIP count: $eip_used"

   if [[ $(($eip_limit - $eip_used)) -ge 5 ]]; then
      echo -e "Check Available EIP ..... Passed"
   else
      echo
      echo "*************************************************************************************************************************************************************************************************"
      echo "* Fatal !! Can't Continue: There are not enough free Elastic IP's available in the $aws_region region. Either select any other region in 'configfile' or release unused EIPs in $aws_region     *"
      echo "*************************************************************************************************************************************************************************************************"
      exit
   fi
   # Check current bucket count
   bucket_count=$(aws s3api list-buckets --query "Buckets | length(@)" --output text)
   echo -e "\nCurrent S3 bucket count: $bucket_count"

   remaining_buckets=$((100 - bucket_count))

   if [ $remaining_buckets -le 0 ]; then
      bucket_name="test-bucket-$(date +%s)"
      aws s3api create-bucket --bucket $bucket_name --region us-east-1 &>/dev/null

      if [ $? -eq 0 ]; then
         aws s3api delete-bucket --bucket $bucket_name --region us-east-1
         if [ $? -eq 0 ]; then
            echo -e "Check Available S3 Bucket ..... Passed"
         fi
      else
         echo
         echo "************************************************************************************************************************************************************"
         echo "* Fatal !! Can't Continue: The S3 bucket limit has been reached on your AWS account. Either increase quota or remove unused S3 Buckets *"
         echo "************************************************************************************************************************************************************"
         exit 1
      fi
   else
      echo -e "Check Available S3 Bucket ..... Passed"
   fi
}
#---------------------------------------------------------------------------------------------------------------------#
# Function to validate if resources are already present on AWS.
check_aws_sg_exists() {
   sg_name="$1"
   # Checking if Security Group exists.
   local sg_group_info=$(aws ec2 describe-security-groups --filters "Name=group-name,Values='$sg_name'" --output text 2>/dev/null)
   # Validating the output
   if [[ -n $sg_group_info ]]; then
      return 0
   else
      return 1
   fi
}
#---------------------------------------------------------------------------------------------------------------------#
# Function to verify CDP pre-requisites i.e. num_of_grps and num_of_saml_prvdrs
cdp_prereq() {
   # Check current CDP IAM Groups count
   cdp_group_count=$(cdp iam list-groups | jq -r '.groups[].groupName' | wc -l)
   echo -e "\nCurrent CDP Groups count: $cdp_group_count"

   if [ $cdp_group_count -gt 48 ]; then
      echo
      echo "************************************************************************************************************************************************************"
      echo "* Fatal !! Can't Continue: The CDP IAM Group count limit has been reached on your CDP account. Either increase quota or remove unused CDP IAM Groups *"
      echo "************************************************************************************************************************************************************"
      exit 1
   else
      echo -e "Check CDP IAM Group Count ..... Passed"
   fi

   # Check current CDP IAM Users count
   cdp_user_count=$(cdp iam list-users --max-items 10000 | jq -r '.users[].userId' | wc -l)
   echo -e "\nCurrent CDP Users count: $cdp_user_count"
   echo -e "Number of Workshop Users count: $number_of_workshop_users"

   remaining_users=$((1000 - $cdp_user_count))
   #echo -e "Number of Remaining Users count: $remaining_users"

   if [ $number_of_workshop_users -gt $remaining_users ]; then
      echo
      echo "************************************************************************************************************************************************************"
      echo "* Fatal !! Can't Continue: The CDP IAM Users count limit has been reached on your CDP account. Either increase quota or remove unused CDP IAM Users *"
      echo "************************************************************************************************************************************************************"
      exit 1
   else
      echo -e "Check CDP IAM Users Count ..... Passed"
   fi

   # Check current CDP SAML Providers count
   cdp_saml_provider_count=$(cdp iam list-saml-providers | jq -r '.samlProviders[].samlProviderName' | wc -l)
   echo -e "\nCurrent CDP SAML Identity Provider (IdP) count: $cdp_saml_provider_count"

   if [ $cdp_saml_provider_count -ge 10 ]; then
      echo
      echo "************************************************************************************************************************************************************"
      echo "* Fatal !! Can't Continue: The CDP SAML Providers count limit has been reached on your CDP account. Either increase quota or remove unused CDP SAML Providers *"
      echo "************************************************************************************************************************************************************"
      exit 1
   else
      echo -e "Check CDP SAML Identity Providers (IdP) Count ..... Passed\n"
   fi
}
#-------------------------------------------------------------------------------------------------#
# Function to provision EC2 Instance for Keycloak
setup_keycloak_ec2() {
   echo -e "\n               ==============================Provisioning Keycloak========================================="
   USER_NAMESPACE=$workshop_name
   mkdir -p /userconfig/.$USER_NAMESPACE

   if [ ! -d "/userconfig/.$USER_NAMESPACE/$KC_TF_CONFIG_DIR" ]; then
      cp -R "$KC_TF_CONFIG_DIR" "/userconfig/.$USER_NAMESPACE/"
   fi

   if [ ! -d "/userconfig/.$USER_NAMESPACE/$KC_ANS_CONFIG_DIR" ]; then
      cp -R "$KC_ANS_CONFIG_DIR" "/userconfig/.$USER_NAMESPACE/"
   fi

   cd /userconfig/.$USER_NAMESPACE/keycloak_terraform_config
   local sg_name="$1"
   if check_aws_sg_exists "$sg_name"; then
      echo "EC2 Security Group With the same name already exists. To avoid the failure the Security Group
name is now updated to $keycloak_sg_name-$workshop_name-sg"
      terraform init
      terraform apply -auto-approve \
         -var "instance_name=$ec2_instance_name" \
         -var "local_ip=$local_ip" \
         -var "instance_keypair=$aws_key_pair" \
         -var "aws_region=$aws_region" \
         -var "kc_security_group=$sg_name-$workshop_name-sg" \
         -var "keycloak_admin_password=$keycloak__admin_password"
      RETURN=$?
      if [ $RETURN -eq 0 ]; then
         KEYCLOAK_SERVER_IP=$(terraform output -raw elastic_ip)
         echo $KEYCLOAK_SERVER_IP >/userconfig/keycloak_ip
         return 0
      else
         return 1
      fi
   else
      terraform init
      terraform apply -auto-approve \
         -var "instance_name=$ec2_instance_name" \
         -var "local_ip=$local_ip" \
         -var "instance_keypair=$aws_key_pair" \
         -var "aws_region=$aws_region" \
         -var "kc_security_group=$sg_name" \
         -var "keycloak_admin_password=$keycloak__admin_password"

      RETURN=$?
      if [ $RETURN -eq 0 ]; then
         KEYCLOAK_SERVER_IP=$(terraform output -raw elastic_ip)
         echo $KEYCLOAK_SERVER_IP >/userconfig/keycloak_ip
         return 0
      else
         return 1
      fi
   fi
}
#--------------------------------------------------------------------------------------------------#
# Function to rollback keycloack EC2 Instance in case of failure during provision.
destroy_keycloak() {
   USER_NAMESPACE=$workshop_name
   echo -e "\n               ===================================Destroying Keycloak======================================="
   cd /userconfig/.$USER_NAMESPACE/keycloak_terraform_config
   terraform init
   terraform destroy -auto-approve \
      -var "instance_name=$ec2_instance_name" \
      -var "local_ip=$local_ip" \
      -var "instance_keypair=$aws_key_pair" \
      -var "aws_region=$aws_region" \
      -var "kc_security_group=$sg_name" \
      -var "keycloak_admin_password=$keycloak__admin_password"
   RETURN=$?
   if [ $RETURN -eq 0 ]; then
      rm -rf /userconfig/.$USER_NAMESPACE/keycloak_terraform_config
      rm -rf /userconfig/.$USER_NAMESPACE/keycloak_ansible_config
      rm -rf /userconfig/keycloak_ip
      return 0
   else
      return 1
   fi
}
#--------------------------------------------------------------------------------------------------#
# Function to provision CDP Environment.
provision_cdp() {
   echo -e "\n               ==============================Provisioning CDP Environment==================================="
   sleep 10
   USER_NAMESPACE=$workshop_name
   mkdir -p /userconfig/.$USER_NAMESPACE
   git clone https://github.com/cloudera-labs/cdp-tf-quickstarts.git -b main --single-branch --depth 1 /userconfig/.$USER_NAMESPACE/cdp-tf-quickstarts &>/dev/null
   cd /userconfig/.$USER_NAMESPACE/cdp-tf-quickstarts
   git sparse-checkout init --cone
   git sparse-checkout set aws
   git checkout @ &>/dev/null
   cd /userconfig/.$USER_NAMESPACE/cdp-tf-quickstarts/aws
   cdp_cidr="\"$local_ip\""
   #Adding outputs in quickstart outputs.tf
   file="outputs.tf"

   # Check if the public subnet output already exists
   public_subnet=$(grep "aws_public_subnet_ids" "$file")

   # Check if the private subnet output already exists
   private_subnet=$(grep "aws_private_subnet_ids" "$file")

   # Append the public subnet output if it does not exist
   if [ -z "$public_subnet" ]; then
      cat <<EOF >>"$file"
output "aws_public_subnet_ids" {
  value = module.cdp_aws_prereqs.aws_public_subnet_ids
}
EOF
   fi
   # Append the private subnet output if it does not exist
   if [ -z "$private_subnet" ]; then
      cat <<EOF >>"$file"
output "aws_private_subnet_ids" {
  value = module.cdp_aws_prereqs.aws_private_subnet_ids
}
EOF
   fi
   terraform init
   terraform apply --auto-approve \
      -var "env_prefix=${workshop_name}" \
      -var "aws_region=${aws_region}" \
      -var "aws_key_pair=${aws_key_pair}" \
      -var "deployment_template=${deployment_template}" \
      -var "ingress_extra_cidrs_and_ports={cidrs = ["${cdp_cidr}"],ports = [443, 22]}"
   cdp_provision_status=$?
   if [ $cdp_provision_status -eq 0 ]; then
      export ENV_PUBLIC_SUBNETS=$(terraform output -json aws_public_subnet_ids)
      export ENV_PRIVATE_SUBNETS=$(terraform output -json aws_private_subnet_ids)
      return 0
   else
      return 1
   fi

}
#--------------------------------------------------------------------------------------------------#
# Update the User Group.
update_cdp_user_group() {
   cdp iam update-group --group-name $workshop_name-aw-cdp-user-group --sync-membership-on-user-login
}
#--------------------------------------------------------------------------------------------------#
# Function to destroy CDP Environment.
destroy_cdp() {
   USER_NAMESPACE=$workshop_name
   echo -e "\n               ==============================Destroying CDP Environment Infrastructure========================================"
   cd /userconfig/.$USER_NAMESPACE/cdp-tf-quickstarts/aws
   cdp_cidr="\"$local_ip\""
   terraform init
   terraform destroy --auto-approve \
      -var "env_prefix=${workshop_name}" \
      -var "aws_region=${aws_region}" \
      -var "aws_key_pair=${aws_key_pair}" \
      -var "deployment_template=${deployment_template}" \
      -var "ingress_extra_cidrs_and_ports={cidrs = ["${cdp_cidr}"],ports = [443, 22]}"
   cdp_destroy_status=$?
   if [ $cdp_destroy_status -eq 0 ]; then
      rm -rf /userconfig/.$USER_NAMESPACE/cdp-tf-quickstarts/
      return 0
   else
      return 1
   fi
}
#--------------------------------------------------------------------------------------------------#
# Function to destroy Complete HOL Infrastructure.
destroy_hol_infra() {
   destroy_cdp
   cdp_destroy_status=$?
   if [ "$provision_keycloak" == "yes" ]; then
      destroy_keycloak
      keycloak_destroy_status=$?
   fi

   if [[ "$cdp_destroy_status" -eq 0 && "$keycloak_destroy_status" -eq 0 ]] || [[ "$cdp_destroy_status" -eq 0 && "$provision_keycloak" == "no" ]]; then
      rm -rf "/userconfig/.$USER_NAMESPACE"
      rm -rf "/userconfig/$workshop_name.txt"
      return 0
   else
      return 1
   fi
}

#--------------------------------------------------------------------------------------------------#
# Function to configure IDP Client
cdp_idp_setup_user() {
   echo "keycloak__admin_password:$keycloak__admin_password"
   KEYCLOAK_SERVER_IP=$(cat /userconfig/keycloak_ip)
   USER_NAMESPACE=$workshop_name
   cd /userconfig/.$USER_NAMESPACE/keycloak_ansible_config
   echo -e "\n               =========================Configuring IDP in CDP=============================================="
   sleep 5
   ansible-playbook create_keycloak_client.yml --extra-vars \
      "keycloak__admin_username=admin \
          keycloak__admin_password=$keycloak__admin_password \
          keycloak__domain=http://$KEYCLOAK_SERVER_IP \
          keycloak__cdp_idp_name=$workshop_name \
          keycloak__realm=master \
          keycloak__auth_realm=master"
   echo -e "\n               =========================Creating Users & Groups=============================================="
   sleep 5
   ansible-playbook keycloak_hol_user_setup.yml --extra-vars \
      "keycloak__admin_username=admin \
    keycloak__admin_password=$keycloak__admin_password \
    keycloak__domain=http://$KEYCLOAK_SERVER_IP \
    hol_keycloak_realm=master \
    hol_session_name=$workshop_name-aw-cdp-user-group \
    number_user_to_create=$number_of_workshop_users \
    username_prefix=$workshop_user_prefix \
    default_user_password=$workshop_user_default_password \
    reset_password_on_first_login=True"
   sleep 10
   echo -e "\n               ==========================Synchronising Keycloak Users In CDP=================================="
   for i in $(seq -f "%02g" 1 1 $number_of_workshop_users); do
      cdp iam create-user \
         --identity-provider-user-id $workshop_user_prefix$i \
         --email $workshop_user_prefix$i@clouderaexample.com \
         --saml-provider-name $workshop_name \
         --groups "$workshop_name-aw-cdp-user-group" \
         --first-name User-$workshop_user_prefix$i \
         --last-name $workshop_user_prefix$i
   done
   cdp environments sync-all-users --environment-names $workshop_name-cdp-env
   sleep 5
   echo -e "\n               ==========================Please Wait: Generating Report======================================="
   cd /userconfig/.$USER_NAMESPACE/keycloak_ansible_config
   ansible-playbook keycloak_hol_user_fetch.yml --extra-vars \
      "keycloak__admin_username=admin \
    keycloak__admin_password=$keycloak__admin_password \
    keycloak__domain=http://$KEYCLOAK_SERVER_IP \
    hol_keycloak_realm=master \
    hol_session_name=$workshop_name-aw-cdp-user-group"
   sleep 5
   echo -e "\n               =============================Fetching Details: Please Wait=========================="
   sample_keycloak_user1=$(cat /tmp/$workshop_name-aw-cdp-user-group.json | jq -r '.[0].username')
   sample_keycloak_user2=$(cat /tmp/$workshop_name-aw-cdp-user-group.json | jq -r '.[1].username')
   sleep 5
   echo "===============================================================" >>"/userconfig/$workshop_name.txt"
   echo "            Keycloak Details For $workshop_name HOL:           " >>"/userconfig/$workshop_name.txt"
   echo "===============================================================" >>"/userconfig/$workshop_name.txt"
   echo "Keycloak Server IP: $KEYCLOAK_SERVER_IP" >>"/userconfig/$workshop_name.txt"
   echo "Keycloak Admin URL: http://$KEYCLOAK_SERVER_IP" >>"/userconfig/$workshop_name.txt"
   echo "Keycloak Admin User: admin" >>"/userconfig/$workshop_name.txt"
   echo "Keycloak Admin Password: $keycloak__admin_password" >>"/userconfig/$workshop_name.txt"
   echo "Keycloak SSO URL: http://$KEYCLOAK_SERVER_IP/realms/master/protocol/saml/clients/cdp-sso" >>"/userconfig/$workshop_name.txt"
   echo "Numbers Of Users Created: $number_of_workshop_users" >>"/userconfig/$workshop_name.txt"
   echo "Sample Usernames: User1: $sample_keycloak_user1, User2: $sample_keycloak_user2" >>"/userconfig/$workshop_name.txt"
   echo "Default Password for HOL Users: $workshop_user_default_password " >>"/userconfig/$workshop_name.txt"
   echo "===============================================================" >>"/userconfig/$workshop_name.txt"
}
#--------------------------------------------------------------------------------------------------#
cdp_idp_user_teardown() {
   USER_NAMESPACE=$workshop_name
   echo -e "\n               ====================Deleting IDP Users & Group==============================================="
   KEYCLOAK_SERVER_IP=$(cat /userconfig/keycloak_ip)
   echo $KEYCLOAK_SERVER_IP
   cd /userconfig/.$USER_NAMESPACE/keycloak_ansible_config
   ansible-playbook keycloak_hol_user_teardown.yml --extra-vars \
      "keycloak__admin_username=admin \
    keycloak__admin_password=$keycloak__admin_password \
    keycloak__domain=http://$KEYCLOAK_SERVER_IP \
    hol_keycloak_realm=master \
    hol_session_name=$workshop_name-aw-cdp-user-group"
   sleep 10
   echo "               ====================Removing IDP From CDP Tenant============================================="
   cdp iam delete-saml-provider --saml-provider-name $workshop_name
}
#--------------------------------------------------------------------------------------------------#
# Function to count elements in a JSON array variable
count_elements() {
   local var="$1"
   # Remove leading and trailing '[' and ']' characters
   local cleaned_var="${var//[[:space:]]/}" # Remove all whitespace
   cleaned_var="${cleaned_var#[}"
   cleaned_var="${cleaned_var%]}"

   # Count number of comma-separated elements
   local count=$(echo "$cleaned_var" | awk -F',' '{print NF}')
   echo "$count"
}
#--------------------------------------------------------------------------------------------------#
deploy_cdw() {
   echo -e "\n               ==========================Deploying CDW======================================"
   echo -e "\n Configuring subnet values.. \nInitial values:"
   echo "ENV_PUBLIC_SUBNETS: $ENV_PUBLIC_SUBNETS"
   echo "ENV_PRIVATE_SUBNETS: $ENV_PRIVATE_SUBNETS"

   # Count elements in ENV_PUBLIC_SUBNETS and ENV_PRIVATE_SUBNETS
   count_public=$(count_elements "$ENV_PUBLIC_SUBNETS")
   count_private=$(count_elements "$ENV_PRIVATE_SUBNETS")

   echo -e "\nCounts:"
   echo "ENV_PUBLIC_SUBNETS count: $count_public"
   echo "ENV_PRIVATE_SUBNETS count: $count_private"

   # Using conditional expressions to assign values
   ENV_PUBLIC_SUBNETS=$([ "$count_public" -ge 3 ] && echo "$ENV_PUBLIC_SUBNETS" || echo "$ENV_PRIVATE_SUBNETS")
   ENV_PRIVATE_SUBNETS=$([ "$count_private" -ge 3 ] && echo "$ENV_PRIVATE_SUBNETS" || echo "$ENV_PUBLIC_SUBNETS")

   echo -e "\nFinal values after assignment:"
   echo "ENV_PUBLIC_SUBNETS: $ENV_PUBLIC_SUBNETS"
   echo "ENV_PRIVATE_SUBNETS: $ENV_PRIVATE_SUBNETS"

   number_vw_to_create=$((($number_of_workshop_users / 10) + ($number_of_workshop_users % 10 > 0)))
   ansible-playbook $DS_CONFIG_DIR/enable-cdw.yml --extra-vars \
      "cdp_env_name=$workshop_name-cdp-env \
   env_lb_public_subnet=$ENV_PUBLIC_SUBNETS \
   env_wrkr_private_subnet=$ENV_PRIVATE_SUBNETS \
   workshop_name=$workshop_name \
   Size=$size_of_virtual_warehouse \
   number_vw_to_create=$number_vw_to_create"
}
#--------------------------------------------------------------------------------------------------#
disable_cdw() {
   echo "               ==========================Disabling CDW======================================"
   ansible-playbook $DS_CONFIG_DIR/disable-cdw.yml --extra-vars \
      "cdp_env_name=$workshop_name-cdp-env"
}
#--------------------------------------------------------------------------------------------------#
#--------------------------------------------------------------------------------------------------#
deploy_cde() {
   echo "               ==========================Deploying CDE======================================"
   number_vc_to_create=$((($number_of_workshop_users / 10) + ($number_of_workshop_users % 10 > 0)))
   ansible-playbook $DS_CONFIG_DIR/enable-cde.yml --extra-vars \
      "cdp_env_name=$workshop_name-cdp-env \
   workshop_name=$workshop_name \
   instance_type=$cde_instance_type \
   minimum_instances=$cde_min_instances \
   maximum_instances=$cde_max_instances \
   spark_version=$cde_spark_version \	
   number_vc_to_create=$number_vc_to_create"

}
#--------------------------------------------------------------------------------------------------#
disable_cde() {
   echo "               ==========================Disabling CDE======================================"
   ansible-playbook $DS_CONFIG_DIR/disable-cde.yml --extra-vars \
      "workshop_name=$workshop_name"
}
#--------------------------------------------------------------------------------------------------#
#--------------------------------------------------------------------------------------------------#
deploy_cml() {
   echo "               ==========================Deploying CML======================================"
   #number_vws_to_create=$(( ($number_of_workshop_users / 10) + ($number_of_workshop_users % 10 > 0) ))
   ansible-playbook $DS_CONFIG_DIR/enable-cml.yml --extra-vars \
      "cdp_env_name=$workshop_name-cdp-env \
   workshop_name=$workshop_name"
   #number_vws_to_create=$number_vws_to_create"
}
#--------------------------------------------------------------------------------------------------#
disable_cml() {
   echo "               ==========================Disabling CML======================================"
   ansible-playbook $DS_CONFIG_DIR/disable-cml.yml --extra-vars \
      "cdp_env_name=$workshop_name-cdp-env \
   workshop_name=$workshop_name"
}
#--------------------------------------------------------------------------------------------------#
#--------------------------------------------------------------------------------------------------#

#---------------------------Start of functions for required roles to access data services-----------------------#
set_account_roles() {
   CDP_GROUP_NAME=${1}
   shift
   ACCOUNT_ROLES=("$@")

   # Get Account Role CRN
   get_crn_account_role() {
      CDP_ACCOUNT_ROLE_NAME=$1
      CDP_ACCOUNT_ROLE_CRN=$(cdp iam list-roles | jq --arg CDP_ACCOUNT_ROLE_NAME "$CDP_ACCOUNT_ROLE_NAME" '.roles[] | select(.crn | endswith($CDP_ACCOUNT_ROLE_NAME)) | .crn')
      echo $CDP_ACCOUNT_ROLE_CRN | tr -d '"'
   }

   # Assign Account Roles with error handling
   for role_name in "${ACCOUNT_ROLES[@]}"; do
      # Assign the account role and capture output
      output=$(cdp iam assign-group-role --group-name ${CDP_GROUP_NAME} --role $(get_crn_account_role ${role_name}) 2>&1)

      # Check the exit status of the previous command
      exit_status=$?

      if [ $exit_status -eq 0 ]; then
         echo "Role '$role_name' assigned successfully to CDP Group '$CDP_GROUP_NAME'."
      elif echo "$output" | grep -q "ALREADY_EXISTS"; then
         echo "Role '$role_name' is already assigned to CDP Group '$CDP_GROUP_NAME'. Skipping..."
      else
         echo "Error assigning role '$role_name':"
         echo "$output"
      fi
   done

   # Verify assigned roles
   cdp iam list-group-assigned-roles --group-name ${CDP_GROUP_NAME}
}

set_resource_roles() {
   CDP_GROUP_NAME=${1}
   CDP_ENV_NAME=${2}
   shift 2
   RESOURCE_ROLES=("$@")

   # Get Group CRN
   export CDP_GROUP_CRN=$(cdp iam list-groups | jq --arg CDP_GROUP_NAME "$CDP_GROUP_NAME" '.groups[] | select(.groupName == $CDP_GROUP_NAME).crn')
   # Get Environment CRN
   export CDP_ENV_CRN=$(cdp environments describe-environment --environment-name ${CDP_ENV_NAME} | jq -r .environment.crn)

   # Function: Get Resource Roles CRN
   get_crn_resource_role() {
      CDP_RESOURCE_ROLE_NAME=$1
      CDP_RESOURCE_ROLE_CRN=$(cdp iam list-resource-roles | jq --arg CDP_RESOURCE_ROLE_NAME "$CDP_RESOURCE_ROLE_NAME" '.resourceRoles[] | select(.crn | endswith($CDP_RESOURCE_ROLE_NAME)) | .crn')
      echo $CDP_RESOURCE_ROLE_CRN | tr -d '"'
   }

   # Set Resource Roles with error handling
   for role_name in "${RESOURCE_ROLES[@]}"; do
      # Assign the resource role and capture output
      output=$(cdp iam assign-group-resource-role --group-name $CDP_GROUP_NAME --resource-role-crn $(get_crn_resource_role ${role_name}) --resource-crn $CDP_ENV_CRN 2>&1)

      # Check the exit status of the previous command
      exit_status=$?

      if [ $exit_status -eq 0 ]; then
         echo "Role '$role_name' assigned successfully to CDP Group '$CDP_GROUP_NAME'."
      elif echo "$output" | grep -q "ALREADY_EXISTS"; then
         echo "Role '$role_name' is already assigned to CDP Group '$CDP_GROUP_NAME'. Skipping..."
      else
         echo "Error assigning role '$role_name':"
         echo "$output"
      fi
   done

   # Verify assigned resource-roles
   cdp iam list-group-assigned-resource-roles --group-name $CDP_GROUP_NAME
}
#-----------------------------------End of functions for required roles to access data services-----------------------------#

enable_data_services() {
   # Remove the brackets.
   enable_data_services="${enable_data_services//[/}"
   enable_data_services="${enable_data_services//]/}"
   # Convert to lower case.
   enable_data_services=$(echo "$enable_data_services" | tr '[:upper:]' '[:lower:]')
   # Split into array.
   IFS=',' read -ra data_services <<<"$enable_data_services"

   # Deploy selected data services
   for service in "${data_services[@]}"; do
      resource_roles=("EnvironmentUser")
      set_resource_roles $workshop_name-aw-cdp-user-group $workshop_name-cdp-env "${resource_roles[@]}"

      if [[ "$service" == "cdw" ]]; then
         deploy_cdw
         resource_roles=("DWAdmin" "DWUser")
         set_resource_roles $workshop_name-aw-cdp-user-group $workshop_name-cdp-env "${resource_roles[@]}"

      elif [[ "$service" == "cde" ]]; then
         deploy_cde
         resource_roles=("DEUser")
         set_resource_roles $workshop_name-aw-cdp-user-group $workshop_name-cdp-env "${resource_roles[@]}"

      elif [[ "$service" == "cml" ]]; then
         deploy_cml
         resource_roles=("MLUser")
         set_resource_roles $workshop_name-aw-cdp-user-group $workshop_name-cdp-env "${resource_roles[@]}"

      elif [[ "$service" == "cdf" ]]; then
         echo "CDF deployment is not supported at the moment"
         #resource_roles=("DFAdmin" "DFFlowAdmin")
         #account_role=("DFCatalogAdmin")
         #set_account_roles $workshop_name-aw-cdp-user-group "${account_role[@]}"
         #set_resource_roles $workshop_name-aw-cdp-user-group $workshop_name-cdp-env "${resource_roles[@]}"
      else
         echo "No Data Services Selected"
      fi
   done
}
#--------------------------------------------------------------------------------------------------#
disable_data_services() {
   # Remove the brackets.
   enabled_data_services="${enable_data_services//[/}"
   enabled_data_services="${enabled_data_services//]/}"
   # converting to lower case.
   enabled_data_services=$(echo "$enabled_data_services" | tr '[:upper:]' '[:lower:]')
   # Spliting into array.
   IFS=',' read -ra data_services <<<"$enabled_data_services"

   # Deploying selected data services
   for service in "${data_services[@]}"; do
      if [[ "$service" == "cdw" ]]; then
         disable_cdw
      elif [[ "$service" == "cde" ]]; then
         disable_cde
      elif [[ "$service" == "cml" ]]; then
         disable_cml
      elif [[ "$service" == "cdf" ]]; then
         echo "CDF"
      else
         echo "No Data Services were deployed"
      fi
   done
}
#--------------------------------------------------------------------------------------------------#
