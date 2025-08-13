#!/bin/bash
# *************************************************************************************************************#
# Setting required path and variables.

#TF_QUICKSTART_VERSION=v0.8.0
USER_CONFIG_FILE="/userconfig/configfile"
KEYGEN_TF_CONFIG_DIR=$HOME_DIR/cdp-wrkshps-quickstarts/keypair_gen
KC_TF_CONFIG_DIR=$HOME_DIR/cdp-wrkshps-quickstarts/cdp-kc-config/keycloak_terraform_config
KC_ANS_CONFIG_DIR=$HOME_DIR/cdp-wrkshps-quickstarts/cdp-kc-config/keycloak_ansible_config
DS_CONFIG_DIR=$HOME_DIR/cdp-wrkshps-quickstarts/cdp-data-services
ENHANCEMENTS_TF_CONFIG_DIR=$HOME_DIR/cdp-wrkshps-quickstarts/aws_enhancements/
CAII_SCRIPTS_DIR=$HOME_DIR/cdp-wrkshps-quickstarts/CAII
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
         # "AWS_ACCESS_KEY_ID"
         # "AWS_SECRET_ACCESS_KEY"
         "AWS_REGION"
         #"AWS_KEY_PAIR"
         "WORKSHOP_NAME"
         "NUMBER_OF_WORKSHOP_USERS"
         "WORKSHOP_USER_PREFIX"
         "WORKSHOP_USER_DEFAULT_PASSWORD"
         # "CDP_ACCESS_KEY_ID"
         # "CDP_PRIVATE_KEY"
         "CDP_DEPLOYMENT_TYPE"
         "LOCAL_MACHINE_IP"
         "ENABLE_DATA_SERVICES"
         "DOMAIN"
         "HOSTEDZONEID"
      )
      echo "Provision_keycloak: $provision_keycloak"
      # Conditionally add Keycloak keys based on PROVISION_KEYCLOAK
      if [[ "$provision_keycloak" == "yes" ]]; then
         REQUIRED_KEYS+=(
            # "KEYCLOAK_SERVER_NAME"
            "KEYCLOAK_ADMIN_PASSWORD"
            #"KEYCLOAK_SECURITY_GROUP_NAME"
         )
      fi

            # Conditionally validate LOCAL_MACHINE_IP for CAII
      if [[ "$provision_caii" == "yes" ]]; then
         if [[ "$local_ip" == "0.0.0.0/0" ]]; then
            echo "=================================================================================="
            echo "FATAL: LOCAL_MACHINE_IP cannot be '0.0.0.0/0' when PROVISION_CAII is set to 'yes'."
            echo "Please update the 'configfile' and provide a more restrictive IP or CIDR range."
            echo "=================================================================================="
            exit 1
         fi
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

      #workshop_name variable to validate
      validate_workshop_name() {
         if [[ ! "$workshop_name" =~ ^[a-z0-9-]+$ || ${#workshop_name} -gt 12 ]]; then
            echo "Error: workshop_name must be 12 characters or less and consist only of lowercase letters, numbers, and hyphens (-)."
            exit 1
         fi
      }
      validate_datalake_version() {
         if [[ -z "$datalake_version" || "$datalake_version" == "latest" || "$datalake_version" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
            return 0 # Valid value
         else
            echo "Error: Valid values for datalake_version are 'latest' or a semantic version (e.g., 7.2.17)."
            return 1 # Invalid value
         fi
      }
      validate_workshop_name
      validate_datalake_version
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
         # KEYCLOAK_SERVER_NAME)
         #    ec2_instance_name=$(echo $value | tr '[:upper:]' '[:lower:]')
         #    ;;
         KEYCLOAK_ADMIN_PASSWORD)
            keycloak__admin_password=$value
            ;;
         #KEYCLOAK_SECURITY_GROUP_NAME)
         #   keycloak_sg_name=$(echo $value | tr '[:upper:]' '[:lower:]')
         #   ;;
         # AWS_ACCESS_KEY_ID)
         #    aws_access_key_id=$value
         #    ;;
         # AWS_SECRET_ACCESS_KEY)
         #    aws_secret_access_key=$value
         #    ;;
         AWS_REGION)
            aws_region=$(echo $value | tr '[:upper:]' '[:lower:]')
            ;;
         AWS_KEY_PAIR)
            aws_key_pair=$(echo $value | tr '[:upper:]' '[:lower:]')
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
         # New domain and hostedzoneid fields
         DOMAIN)
            if [[ -z "$value" || ! "$value" =~ ^[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$ ]]; then
               echo "=================================================================================="
               echo "FATAL: Invalid value for DOMAIN. Please provide a valid domain name."
               echo "=================================================================================="
               exit 1
            else
               domain=$(echo $value | tr '[:upper:]' '[:lower:]')
            fi
            ;;
         HOSTEDZONEID)
            if [[ -z "$value" || ! "$value" =~ ^[A-Z0-9]{0,32}$ ]]; then
               echo "=================================================================================="
               echo "FATAL: Invalid value for HOSTEDZONEID. Hosted Zone ID should be in the format: ZXXXXXXXXX"
               echo "=================================================================================="
               exit 1
            else
               hostedzoneid=$(echo $value | tr '[:lower:]' '[:upper:]')
            fi
            ;;
         # CDP_ACCESS_KEY_ID)
         #    cdp_access_key_id=$value
         #    ;;
         # CDP_PRIVATE_KEY)
         #    cdp_private_key=$value
         #    ;;
         LOCAL_MACHINE_IP)
            local_ip=$value
            ;;
         ENABLE_DATA_SERVICES)
            enable_data_services=$value
            ;;
         CDW_VRTL_WAREHOUSE_SIZE)
            cdw_vrtl_warehouse_size=$(echo $value | tr '[:upper:]' '[:lower:]')
            ;;
         CDW_DATAVIZ_SIZE)
            cdw_dataviz_size=$(echo $value | tr '[:upper:]' '[:lower:]')
            ;;
         CDE_INSTANCE_TYPE)
            cde_instance_type=$(echo $value | tr '[:upper:]' '[:lower:]')
            ;;
         CDE_INITIAL_INSTANCES)
            cde_initial_instances=$value
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
         CDE_VC_TIER)
            cde_vc_tier=$value
            ;;
         CML_WS_INSTANCE_TYPE)
            cml_ws_instance_type=$(echo $value | tr '[:upper:]' '[:lower:]')
            ;;
         CML_MIN_INSTANCES)
            cml_min_instances=$value
            ;;
         CML_MAX_INSTANCES)
            cml_max_instances=$value
            ;;
         CML_ENABLE_GPU)
            cml_enable_gpu=$(echo $value | tr '[:upper:]' '[:lower:]')
            ;;
         CML_GPU_INSTANCE_TYPE)
            cml_gpu_instance_type=$(echo $value | tr '[:upper:]' '[:lower:]')
            ;;
         CML_MIN_GPU_INSTANCES)
            cml_min_gpu_instances=$value
            ;;
         CML_MAX_GPU_INSTANCES)
            cml_max_gpu_instances=$value
            ;;
         CDP_SAML_PROVIDER_LIMIT)
            cdp_saml_provider_limit=$value
            ;;
         CDP_USER_LIMIT)
            cdp_user_limit=$value
            ;;
         CDP_GROUP_LIMIT)
            cdp_group_limit=$value
            ;;
         DATALAKE_VERSION)
            datalake_version=$value
            ;;
         PROVISION_CAII)
            provision_caii=$(echo $value | tr '[:upper:]' '[:lower:]')
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
   USER_NAMESPACE=$workshop_name
   # Checking if SSH Keypair File exists.
   if [[ ! -f "/userconfig/$aws_key_pair.pem" ]]; then
      echo "=================================================================================="
      echo "FATAL: SSH Key Pair File Not Found. Please place the '$aws_key_pair.pem'
file in your config directory and try again.
EXITING....."
      echo "=================================================================================="
      exit 9999 # die with error code 9999
   else
      echo "copying pem file to usernamespace"
      cp -pf "/userconfig/$aws_key_pair.pem" "/userconfig/.$USER_NAMESPACE/"
   fi
}

check_key_pair() {
   USER_NAMESPACE=$workshop_name
   # Check if aws_key_pair exists as input
   # echo "USER_NAMESPACE: ${USER_NAMESPACE}"
   if [[ -z "$aws_key_pair" ]]; then
      # If keypair is empty, check if it's already generated and stored internally
      if [[ -f "/userconfig/.$USER_NAMESPACE/keypair_gen/${workshop_name}-keypair.pem" ]]; then
         export aws_key_pair=${workshop_name}-keypair
         echo -e "\nUsing previously generated keypair: $aws_key_pair"
      else
         echo "=================================================================================="
         echo "Info: No AWS Key Pair provided. A new key pair will be generated via automation."
         echo "=================================================================================="
         generate_keypair
      fi
   fi
}
#-------------------------------------------------------------------------------------------------#
# Function to setup AWS & CDP CLI for user.
#setup_aws_and_cdp_profile() {
#   echo "               =================================================================================="
#   echo "                                   Setting Up Your AWS & CDP Profile                               "
#   echo "               =================================================================================="
#   aws configure set aws_access_key_id $aws_access_key_id
#   aws configure set aws_secret_access_key $aws_secret_access_key
#   aws configure set default.region $aws_region
#   cdp configure set cdp_access_key_id $cdp_access_key_id
#   cdp configure set cdp_private_key $cdp_private_key
#}
#---------------------------------------------------------------------------------------------------------------------#
# Function to verify AWS pre-requisites
aws_prereq() {
   vpc_limit=$(aws service-quotas get-service-quota \
      --service-code vpc \
      --output json \
      --region $aws_region \
      --quota-code L-F678F1CE | jq -r '.[]["Value"]' | cut -d'.' -f1)

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
      --quota-code L-0263D0A3 | jq -r '.[]["Value"]' | cut -d'.' -f1)
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
   local sg_group_info=$(aws ec2 describe-security-groups --filters "Name=group-name,Values='$sg_name'" --region $aws_region --output text 2>/dev/null)
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
   echo -e "\n               ==========================Initializing Parameter Values for CDP limits=========================="
   # echo "  cdp_group_limit: $cdp_group_limit"
   # Default Values
   DEFAULT_CDP_SAML_PROVIDER_LIMIT=10
   DEFAULT_CDP_USER_LIMIT=1000
   DEFAULT_CDP_GROUP_LIMIT=50

   #CDP_limit_variables
   export cdp_saml_provider_limit="${cdp_saml_provider_limit:-$DEFAULT_CDP_SAML_PROVIDER_LIMIT}"
   export cdp_user_limit="${cdp_user_limit:-$DEFAULT_CDP_USER_LIMIT}"
   export cdp_group_limit="${cdp_group_limit:-$DEFAULT_CDP_GROUP_LIMIT}"

   # Print Assigned Values for CDP_limits
   echo "cdp_saml_provider_limit: $cdp_saml_provider_limit"
   echo "cdp_user_limit: $cdp_user_limit"
   echo "cdp_group_limit: $cdp_group_limit"

   # Check current CDP IAM Groups count
   cdp_group_count=$(cdp iam list-groups | jq -r '.groups[].groupName' | wc -l)
   echo -e "\nCurrent CDP Groups count: $cdp_group_count"

   remaining_groups=$(($cdp_group_limit - $cdp_group_count))
   if [ "$remaining_groups" -lt 0 ]; then
      echo
      echo "************************************************************************************************************************************************************"
      echo "* The current group count exceeds the default quota. Kindly provide the correct CDP_GROUP_LIMIT to continue. *"
      echo "************************************************************************************************************************************************************"
      exit 1

   elif [ "$remaining_groups" -lt 2 ]; then
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

   remaining_users=$(($cdp_user_limit - $cdp_user_count))
   #echo -e "Number of Remaining Users count: $remaining_users"
   if [ "$remaining_users" -lt 0 ]; then
      echo
      echo "************************************************************************************************************************************************************"
      echo "* The current user count exceeds the default quota. Kindly provide the correct CDP_USER_LIMIT to continue. *"
      echo "************************************************************************************************************************************************************"
      exit 1

   elif [ "$number_of_workshop_users" -gt "$remaining_users" ]; then
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

   remaining_saml=$(($cdp_saml_provider_limit - $cdp_saml_provider_count))

   if [ "$remaining_saml" -lt 0 ]; then
      echo
      echo "************************************************************************************************************************************************************"
      echo "* The current samlProviders count exceeds the default quota. Kindly provide the correct CDP_SAML_PROVIDER_LIMIT to continue. *"
      echo "************************************************************************************************************************************************************"
      exit 1

   elif [ "$remaining_saml" -eq 0 ]; then
      echo
      echo "************************************************************************************************************************************************************"
      echo "* Fatal !! Can't Continue: The CDP SAML Providers count limit has been reached on your CDP account. Either increase quota or remove unused CDP SAML Providers *"
      echo "************************************************************************************************************************************************************"
      exit 1
   else
      echo -e "Check CDP SAML Identity Providers (IdP) Count ..... Passed"
   fi
}
#-------------------------------------------------------------------------------------------------#
# Function to provision EC2 Instance for Keycloak
generate_keypair() {
   echo -e "\n               ==============================Generating keypair if not exists ========================================="
   USER_NAMESPACE=$workshop_name
   mkdir -p /userconfig/.$USER_NAMESPACE

   if [ ! -d "/userconfig/.$USER_NAMESPACE/$KEYGEN_TF_CONFIG_DIR" ]; then
      cp -R "$KEYGEN_TF_CONFIG_DIR" "/userconfig/.$USER_NAMESPACE/"
   fi

   cd /userconfig/.$USER_NAMESPACE/keypair_gen
   terraform init
   terraform apply -auto-approve \
      -var "keypair_name=$workshop_name" \
      -var "aws_key_pair=$aws_key_pair" \
      -var "aws_region=$aws_region"
   RETURN=$?
   if [ $RETURN -eq 0 ]; then
      export aws_key_pair=$(terraform output -raw aws_key_pair_output) #updated the value of aws_key_pair if initially not exists
      echo "true" >keypair_generated.flag                              # Store a flag to indicate the keypair was generated
      cp -f ${workshop_name}-keypair.pem /userconfig/.$USER_NAMESPACE/
      return 0
   else
      return 1
   fi
}

destroy_keypair() {
   echo -e "\n               ==============================Destroying generated keypair========================================="
   USER_NAMESPACE=$workshop_name
   cd /userconfig/.$USER_NAMESPACE/keypair_gen
   terraform init
   terraform destroy -auto-approve \
      -var "keypair_name=$workshop_name" \
      -var "aws_key_pair=$aws_key_pair" \
      -var "aws_region=$aws_region"
   RETURN=$?
   if [ $RETURN -eq 0 ]; then
      rm -rf /userconfig/.$USER_NAMESPACE/keypair_gen
      return 0
   else
      return 1
   fi
}

setup_keycloak_ec2() {
   echo -e "\n               ==============================Provisioning Keycloak=========================================\n"
   USER_NAMESPACE=$workshop_name
   mkdir -p /userconfig/.$USER_NAMESPACE

   if [ ! -d "/userconfig/.$USER_NAMESPACE/$KC_TF_CONFIG_DIR" ]; then
      cp -R "$KC_TF_CONFIG_DIR" "/userconfig/.$USER_NAMESPACE/"
   fi

   if [ ! -d "/userconfig/.$USER_NAMESPACE/$KC_ANS_CONFIG_DIR" ]; then
      cp -R "$KC_ANS_CONFIG_DIR" "/userconfig/.$USER_NAMESPACE/"
   fi

   cd /userconfig/.$USER_NAMESPACE/keycloak_terraform_config

   ########## SSL Certs Genertaion Logic
   # DOMAIN=$domain               # Base domain (e.g., example.com)
   # HOSTED_ZONE_ID=$hostedzoneid # Route53 Hosted Zone ID
   # CERT_EMAIL=admin@$domain     # Email for Let's Encrypt (e.g., admin@example.com)
   # Check if required variables are provided
   if [[ -z "$workshop_name" || -z "$domain" || -z "$hostedzoneid" ]]; then
      echo "Missing Values for required parameters for SSL Certs"
      exit 1
   fi
   # Derived Variables
   SUBDOMAIN="$workshop_name.$domain"
   echo "=== Subdomain: $SUBDOMAIN for HostedZoneId: $hostedzoneid ==="
   CERT_PATH="/etc/letsencrypt/live/$domain"
   echo "=== Generating Wildcard SSL Certificates ==="
   # Install Certbot if not installed
   if ! command -v certbot &>/dev/null; then
      echo "Certbot not found. Installing..."
      export DEBIAN_FRONTEND=noninteractive
      apt-get update >/dev/null 2>&1 && apt-get install -y certbot python3-certbot-dns-route53 >/dev/null 2>&1
   fi

   SSL_MOUNT_PATH=/userconfig/sslcerts/$domain
   mkdir -p $SSL_MOUNT_PATH
   # Check if certificates are already generated for the same domain name
   if [[ ! -f "$SSL_MOUNT_PATH/fullchain.pem" && ! -f "$SSL_MOUNT_PATH/privkey.pem" ]]; then
      echo "SSL certificates doesn't exists. Starting certs generation process for Wildcard Domain: *.$domain..."
      # Generate Wildcard SSL Certificates
      certbot certonly \
         --dns-route53 \
         -d "*.$domain" \
         --non-interactive \
         --agree-tos \
         -m "admin@$domain"
      # Check if certificates were generated successfully
      if [[ ! -f "$CERT_PATH/fullchain.pem" || ! -f "$CERT_PATH/privkey.pem" ]]; then
         echo "Error: SSL certificates not generated. Exiting."
         exit 1
      fi
      echo "SSL certificates successfully generated for *.$domain"
      for file in /etc/letsencrypt/archive/$domain/*1.pem; do cp -v "$file" "$SSL_MOUNT_PATH/$(basename "$file" 1.pem).pem"; done
   else
      echo "SSL certificates already exists. Skipping certs generation process for Wildcard Domain: *.$domain..."
   fi

   # Encode SSL Certificates in Base64 (for Terraform user_data)
   FULLCHAIN=$(cat "$SSL_MOUNT_PATH/fullchain.pem" | base64 -w 0)
   PRIVKEY=$(cat "$SSL_MOUNT_PATH/privkey.pem" | base64 -w 0)

   #######

   #local sg_name="$1"
   local sg_name="$workshop_name-keyc-sg"

   echo -e "\n=== Running Terraform ===\n" 
   # Run Terraform to provision Keycloak instance
   if check_aws_sg_exists "$sg_name"; then
      echo "EC2 Security Group with the same name already exists. Updating Security Group name to $sg_name-$workshop_name-sg"
      sg_name="$sg_name-$workshop_name"
   fi

   terraform init
   terraform apply -auto-approve \
      -var "workshop_name=$workshop_name" \
      -var "local_ip=$local_ip" \
      -var "instance_keypair=$aws_key_pair" \
      -var "aws_region=$aws_region" \
      -var "domain=$domain" \
      -var "wildcard_fullchain=$FULLCHAIN" \
      -var "wildcard_privkey=$PRIVKEY" \
      -var "kc_security_group=$sg_name" \
      -var "keycloak_admin_password=$keycloak__admin_password"

   RETURN=$?
   if [ $RETURN -eq 0 ]; then
      KEYCLOAK_SERVER_IP=$(terraform output -raw elastic_ip)
      echo "Adding Keycloak instance IP to userconfig/keycloak_ip"
      echo "$KEYCLOAK_SERVER_IP" >/userconfig/keycloak_ip
      cat /userconfig/keycloak_ip
      echo "Keycloak instance IP added to userconfig/keycloak_ip"
   else
      return 1
   fi

   # Fetch the public IP of the created Keycloak instance
   if [[ -z "$KEYCLOAK_SERVER_IP" ]]; then
      echo "Error: Unable to retrieve Keycloak instance IP. Exiting."
      exit 1
   fi

   echo "Keycloak instance public IP: $KEYCLOAK_SERVER_IP"
   echo -e "\n=== Updating DNS Record for Route53 ==="
   # Update Route53 DNS record to map subdomain to instance IP
   aws route53 change-resource-record-sets --hosted-zone-id "$hostedzoneid" \
      --change-batch '{
        "Changes": [{
            "Action": "UPSERT",
            "ResourceRecordSet": {
                "Name": "'"$SUBDOMAIN"'",
                "Type": "A",
                "TTL": 300,
                "ResourceRecords": [{"Value": "'"$KEYCLOAK_SERVER_IP"'"}]
            }
        }]
    }'
   if [[ $? -ne 0 ]]; then
      echo "Error: Failed to update DNS record. Exiting."
      exit 1
   fi
   echo "DNS record updated: $SUBDOMAIN -> $KEYCLOAK_SERVER_IP"
   echo -e "\n=== Keycloak Setup Completed Successfully ==="

}
#--------------------------------------------------------------------------------------------------#
# Function to rollback keycloack EC2 Instance in case of failure during provision.
destroy_keycloak() {
   USER_NAMESPACE=$workshop_name
   echo -e "\n               ===================================Destroying Keycloak======================================="
   cd /userconfig/.$USER_NAMESPACE/keycloak_terraform_config
   terraform init
   echo "=== Wait for 30 seconds... ==="
   sleep 30
   echo "=== Deleting DNS Record ==="
   # Delete Route53 DNS record to unmap subdomain to instance IP
   aws route53 change-resource-record-sets --hosted-zone-id "$hostedzoneid" \
      --change-batch '{
        "Changes": [{
            "Action": "DELETE",
            "ResourceRecordSet": {
                "Name": "'"$workshop_name.$domain"'",
                "Type": "A",
                "TTL": 300,
                "ResourceRecords": [{"Value": "'"$(terraform output -raw elastic_ip)"'"}]
            }
        }]
    }'
   echo "DNS record deleted: $SUBDOMAIN -> $KEYCLOAK_SERVER_IP"
   terraform destroy -auto-approve \
      -var "workshop_name=$workshop_name" \
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
   git clone https://github.com/cloudera-labs/cdp-tf-quickstarts.git -b $TF_QUICKSTART_VERSION --single-branch --depth 1 /userconfig/.$USER_NAMESPACE/cdp-tf-quickstarts &>/dev/null
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

   # Check if the bucket_name output already exists
   bucket_name=$(grep "aws_log_storage_location" "$file")

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
   # Append the bucket_name output if it does not exist
   if [ -z "$bucket_name" ]; then
      cat <<EOF >>"$file"
output "log_storage_bucket_name" {
  description = "The S3 bucket name extracted from the aws_log_storage_location string"
  value       = element(split("/", module.cdp_aws_prereqs.aws_log_storage_location), 2)
}
EOF
   fi
   terraform init
   terraform apply --auto-approve \
      -var "env_prefix=${workshop_name}" \
      -var "aws_region=${aws_region}" \
      -var "aws_key_pair=${aws_key_pair}" \
      -var "deployment_template=${deployment_template}" \
      -var "ingress_extra_cidrs_and_ports={cidrs = ["${cdp_cidr}"],ports = [443, 22]}" \
      -var "datalake_version=${datalake_version}"
   cdp_provision_status=$?
   if [ $cdp_provision_status -eq 0 ]; then
      export ENV_PUBLIC_SUBNETS=$(terraform output -json aws_public_subnet_ids)
      export ENV_PRIVATE_SUBNETS=$(terraform output -json aws_private_subnet_ids)

      echo -e "\nSubnet values from Terraform:"
      echo "ENV_PUBLIC_SUBNETS: $ENV_PUBLIC_SUBNETS"
      echo "ENV_PRIVATE_SUBNETS: $ENV_PRIVATE_SUBNETS"

      ENV_PUBLIC_SUBNETS=$(terraform output -json aws_public_subnet_ids | jq -c '.[0:3]')
      echo -e "\nFirst 3 public subnets for CDW (If Applicable): $ENV_PUBLIC_SUBNETS"
      ENV_PRIVATE_SUBNETS=$(terraform output -json aws_private_subnet_ids | jq -c '.[0:3]')
      echo "First 3 private subnets for CDW (If Applicable): $ENV_PRIVATE_SUBNETS"

      export BUCKET_NAME=$(terraform output -raw log_storage_bucket_name)

      # Count elements in ENV_PUBLIC_SUBNETS and ENV_PRIVATE_SUBNETS
      count_public=$(count_elements "$ENV_PUBLIC_SUBNETS")
      count_private=$(count_elements "$ENV_PRIVATE_SUBNETS")

      # echo -e "\nCounts:"
      # echo "ENV_PUBLIC_SUBNETS count: $count_public"
      # echo "ENV_PRIVATE_SUBNETS count: $count_private"

      # Using conditional expressions to assign values
      ENV_PUBLIC_SUBNETS=$([ "$count_public" -ge 1 ] && echo "$ENV_PUBLIC_SUBNETS" || echo "$ENV_PRIVATE_SUBNETS")
      ENV_PRIVATE_SUBNETS=$([ "$count_private" -ge 1 ] && echo "$ENV_PRIVATE_SUBNETS" || echo "$ENV_PUBLIC_SUBNETS")

      echo -e "\nFinal values after assignment:"
      echo "ENV_PUBLIC_SUBNETS for CDW (If Applicable): $ENV_PUBLIC_SUBNETS"
      echo "ENV_PRIVATE_SUBNETS for CDW (If Applicable): $ENV_PRIVATE_SUBNETS"

      aws_enhancements #calling aws_enahancements function
      aws_enhancements_status=$?
      if [ $aws_enhancements_status -ne 0 ]; then
         echo "Warning: AWS enhancements failed to apply. Please check the logs for details."
      fi

      return 0
   else
      return 1
   fi

}

#Add enhancements
aws_enhancements() {
   echo -e "\n               ==============================Adding aws enhancements ========================================="
   USER_NAMESPACE=$workshop_name
   mkdir -p /userconfig/.$USER_NAMESPACE

   if [ ! -d "/userconfig/.$USER_NAMESPACE/$ENHANCEMENTS_TF_CONFIG_DIR" ]; then
      cp -R "$ENHANCEMENTS_TF_CONFIG_DIR" "/userconfig/.$USER_NAMESPACE/"
   fi

   cd /userconfig/.$USER_NAMESPACE/aws_enhancements/s3_enhancements
     terraform init
     terraform apply -auto-approve \
         -var="log_bucket_name=$BUCKET_NAME" \
         -var="aws_region=$aws_region"
}

#--------------------------------------------------------------------------------------------------#
initialize_compute_cluster() {
   echo -e "\n               ==============================Initializing Compute Cluster=========================================="
   USER_NAMESPACE=$workshop_name
   mkdir -p /userconfig/.$USER_NAMESPACE

   if [ ! -d "/userconfig/.$USER_NAMESPACE/$CAII_SCRIPTS_DIR" ]; then
      cp -R "$CAII_SCRIPTS_DIR" "/userconfig/.$USER_NAMESPACE/"
   fi
   cd /userconfig/.$USER_NAMESPACE/CAII

   chmod +x ./convert_v2_env.sh
   ./convert_v2_env.sh $ENV_PUBLIC_SUBNETS $workshop_name $local_ip

   #deploy Compute cluster
   chmod +x ./initialize_default_cluster.sh

   ./initialize_default_cluster.sh $workshop_name
}

provision_compute_cluster() {
echo -e "\n               ==============================Provisioning Compute Cluster=========================================="
   USER_NAMESPACE=$workshop_name
   mkdir -p /userconfig/.$USER_NAMESPACE

   if [ ! -d "/userconfig/.$USER_NAMESPACE/$CAII_SCRIPTS_DIR" ]; then
      cp -R "$CAII_SCRIPTS_DIR" "/userconfig/.$USER_NAMESPACE/"
   fi
   cd /userconfig/.$USER_NAMESPACE/CAII

   #deploy Compute cluster
   chmod +x ./compute_cluster_deploy.sh

   ./compute_cluster_deploy.sh $workshop_name
}

enable_model_registry() { 
  echo -e "\n               =============================Deploying Model Registry ========================================="
  USER_NAMESPACE=$workshop_name   
  cd /userconfig/.$USER_NAMESPACE/CAII

  environment_crn=$(cdp environments describe-environment --environment-name ${workshop_name}-cdp-env | jq -r .environment.crn)

  # Check if ML Model Registry exists and is already installed
  registry_status=$(cdp ml list-model-registries | jq -r --arg env_name "${workshop_name}-cdp-env" '
    .modelRegistries[]
    | select(.environmentName == $env_name)
    | .status
  ')

  if [[ "$registry_status" == "installation:finished" ]]; then
    echo "✅ ML Model Registry for environment '${workshop_name}-cdp-env' is already installed. Skipping creation."
    return
  else
    echo "🚀 Proceeding with model registry deployment"
    cdp ml create-model-registry \
      --environment-crn "$environment_crn" \
      --environment-name "${workshop_name}-cdp-env" \
      --use-public-load-balancer
  fi

  echo "⏳ Waiting for ML Model Registry installation to finish..."
  for i in {1..75}; do
    registry_status=$(cdp ml list-model-registries | jq -r --arg env_name "${workshop_name}-cdp-env" '
      .modelRegistries[]
      | select(.environmentName == $env_name)
      | .status
    ')

    echo "   ➤ Attempt $i: Status = $registry_status"

    # Normalize to lowercase for matching
    status_lower=$(echo "$registry_status" | tr '[:upper:]' '[:lower:]')

    if [[ "$status_lower" == "installation:finished" ]]; then
      echo "✅ ML Model Registry installation finished successfully."
      return
    elif [[ "$status_lower" == *"failed"* ]]; then
      echo "❌ ML Model Registry installation FAILED with status: $registry_status"
      exit 1
    fi

    sleep 60
  done

  echo "❌ Timeout Error: ML Model Registry did not reach 'installation:finished' state."
  exit 1
}

provision_caii_service_app() {
   USER_NAMESPACE=$workshop_name
   cd /userconfig/.$USER_NAMESPACE/CAII
   
   echo -e "\n               ==============================Provisioning AI Inference Service App ========================================="
   
   #Update template for serving app
   chmod +x ./create_serving_app_input.sh
   ./create_serving_app_input.sh $workshop_name
   
   local env_name="${workshop_name}-cdp-env"
   caii_service_status=$(cdp ml list-ml-serving-apps | jq -r --arg env_name "$env_name" '
     .apps[]
     | select(.environmentName == $env_name)
     | .status
   ')

   if [[ "$caii_service_status" == "installation:finished" ]]; then
     echo "✅ CAII service for environment '${workshop_name}-cdp-env' is already installed. Skipping creation."
   else
     echo "🚀 Proceeding with CAII service deployment"
      # Create model endpoint
      cdp ml create-ml-serving-app --cli-input-json file://updated-serving-app-input.json
      sleep 60
   fi

   for i in {1..60}; do
     caii_service_status=$(cdp ml list-ml-serving-apps | jq -r --arg env_name "$env_name" '
      .apps[]
      | select(.environmentName == $env_name)
      | .status
     ')

     echo "   ➤ Attempt $i: Status = $caii_service_status"

   # Keep looping until status is 'installation:finished'
     if [[ "$caii_service_status" == "installation:finished" ]]; then
         echo "✅ Installation finished."
         break
     elif [[ "$caii_service_status" == "installation:failed" ]]; then
         echo "❌ Installation failed."
         exit 1
     fi

     sleep 45
   done  
}

provision_cai_inference() {
   echo -e "\n   ========= Provisioning AI Inference with other dependencies e.g Compute cluster, workbench & Model registry ========="

  local enable_data_services="cml"
  local env_name="${workshop_name}-cdp-env"

  # Step 1: Initialize compute cluster
  initialize_compute_cluster

  # Step 2: Provision compute cluster, model registry and ai workbench in parallel
  provision_compute_cluster &
  pid_compute=$!
  sleep 60
  
  enable_model_registry &
  pid_model=$!

  enable_data_services &
  pid_cml=$!

  # Step 4: Wait for all background tasks
  wait $pid_compute
  status_compute=$?

  wait $pid_model
  status_model=$?

  wait $pid_cml
  status_cml=$?

  if [[ $status_compute -ne 0 || $status_model -ne 0 || $status_cml -ne 0 ]]; then
    echo "❌ Error: One or more provisioning steps failed."
    return 1
  fi

  # Step 5: Proceed to CAII service deployment
  provision_caii_service_app
}


destroy_cai_inference() {
   echo -e "\n               ==============================Destroying AI Inference ========================================="
   
   USER_NAMESPACE=$workshop_name
   cd /userconfig/.$USER_NAMESPACE/CAII

   # Delete ML Serving App first, extract CRN
   serving_app_crn=$(cdp ml list-ml-serving-apps | jq -r --arg env_name "${workshop_name}-cdp-env" '
     .apps[] | select(.environmentName == $env_name) | .appCrn
   ')

   if [[ -n "$serving_app_crn" ]]; then
     echo "🗑️ Deleting ML Serving App: $serving_app_crn"
     cdp ml delete-ml-serving-app --app-crn "$serving_app_crn"
   else
     echo "✅ No ML Serving App found"
   fi
   
   # Set the data service value for cleanup
   local enable_data_services="cml"
   disable_data_services &  # Call the function that disables CML
   pid_disable=$!
   sleep 30
   
   chmod +x ./destroy_caii_resources.sh
   ./destroy_caii_resources.sh $workshop_name
   
   # Wait for disable_data_services to complete before exiting
   wait $pid_disable
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
   USER_NAMESPACE=$workshop_name
   destroy_cdp
   cdp_destroy_status=$?
   if [[ "$provision_keycloak" == "yes" && "$cdp_destroy_status" -eq 0 ]]; then
      destroy_keycloak
      keycloak_destroy_status=$?
   fi

   if [[ "$cdp_destroy_status" -eq 0 && "$keycloak_destroy_status" -eq 0 ]] || [[ "$cdp_destroy_status" -eq 0 && "$provision_keycloak" == "no" ]]; then
      if [[ -f /userconfig/.$USER_NAMESPACE/keypair_gen/keypair_generated.flag && "$(cat /userconfig/.$USER_NAMESPACE/keypair_gen/keypair_generated.flag)" == "true" ]]; then
         destroy_keypair
      fi
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
   # echo "keycloak__admin_password:$keycloak__admin_password"
   KEYCLOAK_SERVER_IP=$(cat /userconfig/keycloak_ip)
   USER_NAMESPACE=$workshop_name
   cd /userconfig/.$USER_NAMESPACE/keycloak_ansible_config
   echo -e "\n               =========================Configuring IDP in CDP==============================================\n"
   sleep 5
   cdp_region=$(cdp environments describe-environment --environment-name $workshop_name-cdp-env | jq -r .environment.crn | cut -d: -f4)
   echo "cdp_region:$cdp_region"
   ansible-playbook create_keycloak_client.yml --extra-vars \
      "keycloak__admin_username=admin \
      keycloak__admin_password=$keycloak__admin_password \
      keycloak__domain=https://$KEYCLOAK_SERVER_IP \
      keycloak__cdp_idp_name=$workshop_name \
      keycloak__realm=master \
      keycloak__auth_realm=master \
      cdp_region=$cdp_region"
   echo -e "\n               =========================Creating Users & Groups==============================================\n"
   sleep 5
   ansible-playbook keycloak_hol_user_setup.yml --extra-vars \
      "keycloak__admin_username=admin \
      keycloak__admin_password=$keycloak__admin_password \
      keycloak__domain=https://$KEYCLOAK_SERVER_IP \
      hol_keycloak_realm=master \
      hol_session_name=$workshop_name-aw-cdp-user-group \
      number_user_to_create=$number_of_workshop_users \
      username_prefix=$workshop_user_prefix \
      default_user_password=$workshop_user_default_password \
      reset_password_on_first_login=True"
   sleep 10
   echo -e "\n               ==========================Synchronising Keycloak Users In CDP=================================="
   for i in $(seq -f "%02g" 1 1 $number_of_workshop_users); do
      output=$(cdp iam create-user \
         --identity-provider-user-id $workshop_user_prefix$i \
         --email $workshop_user_prefix$i@clouderaexample.com \
         --saml-provider-name $workshop_name \
         --groups "$workshop_name-aw-cdp-user-group" \
         --first-name User-$workshop_user_prefix$i \
         --last-name User-$workshop_user_prefix$i 2>&1)
      if echo "$output" | grep -q "ALREADY_EXISTS"; then
         echo "User '$workshop_user_prefix$i' already exists. Skipping..."
      fi
   done

   cdp environments sync-all-users --environment-names $workshop_name-cdp-env
   sleep 5
   echo -e "\n               ==========================Please Wait: Generating Report======================================="
   cd /userconfig/.$USER_NAMESPACE/keycloak_ansible_config
   ansible-playbook keycloak_hol_user_fetch.yml --extra-vars \
      "keycloak__admin_username=admin \
      keycloak__admin_password=$keycloak__admin_password \
      keycloak__domain=https://$KEYCLOAK_SERVER_IP \
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
   echo "Keycloak Admin HTTPS URL: https://$workshop_name.$domain" >>"/userconfig/$workshop_name.txt"
   echo "Keycloak Admin User: admin" >>"/userconfig/$workshop_name.txt"
   echo "Keycloak Admin Password: $keycloak__admin_password" >>"/userconfig/$workshop_name.txt"
   echo "Keycloak SSO HTTPS URL: https://$workshop_name.$domain/realms/master/protocol/saml/clients/cdp-sso" >>"/userconfig/$workshop_name.txt"
   echo "Numbers Of Users Created: $number_of_workshop_users" >>"/userconfig/$workshop_name.txt"
   echo "Sample Usernames: User1: $sample_keycloak_user1, User2: $sample_keycloak_user2" >>"/userconfig/$workshop_name.txt"
   echo "Default Password for HOL Users: $workshop_user_default_password " >>"/userconfig/$workshop_name.txt"
   echo "UserAssignment App Admin URL: http://$KEYCLOAK_SERVER_IP:5000/admin" >>"/userconfig/$workshop_name.txt"
   echo "UserAssignment App Participant URL: http://$KEYCLOAK_SERVER_IP:5000/participant" >>"/userconfig/$workshop_name.txt"
   echo "===============================================================" >>"/userconfig/$workshop_name.txt"
}
#--------------------------------------------------------------------------------------------------#
cdp_idp_user_teardown() {
   USER_NAMESPACE=$workshop_name
   echo -e "\n               ====================Deleting IDP Users & Group==============================================="
   
   if [[ -f /userconfig/keycloak_ip ]]; then
      KEYCLOAK_SERVER_IP=$(cat /userconfig/keycloak_ip)
      echo $KEYCLOAK_SERVER_IP
      cd /userconfig/.$USER_NAMESPACE/keycloak_ansible_config
      ansible-playbook keycloak_hol_user_teardown.yml --extra-vars \
         "keycloak__admin_username=admin \
         keycloak__admin_password=$keycloak__admin_password \
         keycloak__domain=https://$KEYCLOAK_SERVER_IP \
         hol_keycloak_realm=master \
         hol_session_name=$workshop_name-aw-cdp-user-group"
      sleep 10
   else
      echo "Keycloak IP file not found. Assuming Keycloak is already destroyed. Skipping ansible playbook execution."
   fi

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
   echo -e "\n               ==========================Deploying CDW======================================\n"
   number_vw_to_create=$((($number_of_workshop_users / 10) + ($number_of_workshop_users % 10 > 0)))

   ansible-playbook $DS_CONFIG_DIR/enable-cdw.yml --extra-vars \
      "cdp_env_name=$workshop_name-cdp-env \
      env_lb_public_subnet=$ENV_PUBLIC_SUBNETS \
      env_wrkr_private_subnet=$ENV_PRIVATE_SUBNETS \
      workshop_name=$workshop_name \
      vw_size=$cdw_vrtl_warehouse_size \
      cdvc_size=$cdw_dataviz_size \
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
   echo -e "\n               ==========================Deploying CDE======================================\n"
   number_vc_to_create=$((($number_of_workshop_users / 10) + ($number_of_workshop_users % 10 > 0)))
   DEFAULT_CDE_INSTANCE_TYPE="m5.2xlarge"
   if [ -z "${CDE_INSTANCE_TYPE+x}" ] || [ -z "$CDE_INSTANCE_TYPE" ]; then
      cde_instance_type=$DEFAULT_CDE_INSTANCE_TYPE
   else
      cde_instance_type=$CDE_INSTANCE_TYPE
   fi

   ansible-playbook $DS_CONFIG_DIR/enable-cde.yml --extra-vars \
      "cdp_env_name=$workshop_name-cdp-env \
      workshop_name=$workshop_name \
      instance_type=$cde_instance_type \
      initial_instances=$cde_initial_instances \
      minimum_instances=$cde_min_instances \
      maximum_instances=$cde_max_instances \
      spark_version=$cde_spark_version \
      vc_tier=$cde_vc_tier \
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
   echo -e "\n               ==========================Deploying CML======================================\n"
   #number_vws_to_create=$(( ($number_of_workshop_users / 10) + ($number_of_workshop_users % 10 > 0) ))
   ansible-playbook $DS_CONFIG_DIR/enable-cml.yml --extra-vars \
      "cdp_env_name=$workshop_name-cdp-env \
      workshop_name=$workshop_name \
      ws_instance_type=$cml_ws_instance_type \
      minimum_instances=$cml_min_instances \
      maximum_instances=$cml_max_instances \
      root_volume_size=256 \
      enable_gpu=$cml_enable_gpu \
      gpu_instance_type=$cml_gpu_instance_type \
      minimum_gpu_instances=$cml_min_gpu_instances \
      maximum_gpu_instances=$cml_max_gpu_instances"
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
         echo -e "\n               ==========================Initializing Parameter Values for CDW======================================\n"
         # Default Values
         DEFAULT_CDW_VRTL_WAREHOUSE_SIZE="xsmall"
         DEFAULT_CDW_DATAVIZ_SIZE="viz-default"

         # CDW (Cloudera Data Warehouse) Variables
         cdw_vrtl_warehouse_size="${cdw_vrtl_warehouse_size:-$DEFAULT_CDW_VRTL_WAREHOUSE_SIZE}"
         cdw_dataviz_size="${cdw_dataviz_size:-$DEFAULT_CDW_DATAVIZ_SIZE}"

         # Print Assigned Values for CDW
         echo "CDW (Cloudera Data Warehouse) Variables:"
         echo "  Virtual Warehouse Size: $cdw_vrtl_warehouse_size"
         echo "  DataViz Size: $cdw_dataviz_size"

         deploy_cdw
         resource_roles=("DWAdmin" "DWUser")
         set_resource_roles $workshop_name-aw-cdp-user-group $workshop_name-cdp-env "${resource_roles[@]}"

      elif [[ "$service" == "cde" ]]; then
         echo -e "\n               ==========================Initializing Parameter Values for CDE======================================\n"
         # Default Values
         DEFAULT_CDE_INSTANCE_TYPE="m5.2xlarge"
         DEFAULT_CDE_INITIAL_INSTANCES=10
         DEFAULT_CDE_MIN_INSTANCES=10
         DEFAULT_CDE_MAX_INSTANCES=40
         DEFAULT_CDE_SPARK_VERSION="SPARK3"
         DEFAULT_CDE_VC_TIER="CORE"

         # CDE (Cloudera Data Engineering) Variables
         cde_instance_type="${cde_instance_type:-$DEFAULT_CDE_INSTANCE_TYPE}"
         cde_initial_instances="${cde_initial_instances:-$DEFAULT_CDE_INITIAL_INSTANCES}"
         cde_min_instances="${cde_min_instances:-$DEFAULT_CDE_MIN_INSTANCES}"
         cde_max_instances="${cde_max_instances:-$DEFAULT_CDE_MAX_INSTANCES}"
         cde_spark_version="${cde_spark_version:-$DEFAULT_CDE_SPARK_VERSION}"
         cde_vc_tier="${cde_vc_tier:-$DEFAULT_CDE_VC_TIER}"

         # Print Assigned Values for CDE
         echo "CDE (Cloudera Data Engineering) Variables:"
         echo "  Instance Type: $cde_instance_type"
         echo "  Initial Instances: $cde_initial_instances"
         echo "  Min Instances: $cde_min_instances"
         echo "  Max Instances: $cde_max_instances"
         echo "  Spark Version: $cde_spark_version"
         echo "  Virtual Cluster Tier: $cde_vc_tier"

         deploy_cde
         resource_roles=("DEUser")
         set_resource_roles $workshop_name-aw-cdp-user-group $workshop_name-cdp-env "${resource_roles[@]}"

      elif [[ "$service" == "cml" ]]; then
         echo -e "\n               ==========================Initializing Parameter Values for CML======================================\n"
         # Default Values
         DEFAULT_CML_WS_INSTANCE_TYPE="m5.2xlarge"
         DEFAULT_CML_MIN_INSTANCES=1
         DEFAULT_CML_MAX_INSTANCES=10
         DEFAULT_CML_ENABLE_GPU="false"
         DEFAULT_CML_GPU_INSTANCE_TYPE="g4dn.xlarge"
         DEFAULT_CML_MIN_GPU_INSTANCES=0
         DEFAULT_CML_MAX_GPU_INSTANCES=10

         # CML (Cloudera Machine Learning) Variables
         cml_ws_instance_type="${cml_ws_instance_type:-$DEFAULT_CML_WS_INSTANCE_TYPE}"
         cml_min_instances="${cml_min_instances:-$DEFAULT_CML_MIN_INSTANCES}"
         cml_max_instances="${cml_max_instances:-$DEFAULT_CML_MAX_INSTANCES}"
         cml_enable_gpu="${cml_enable_gpu:-$DEFAULT_CML_ENABLE_GPU}"
         cml_gpu_instance_type="${cml_gpu_instance_type:-$DEFAULT_CML_GPU_INSTANCE_TYPE}"
         cml_min_gpu_instances="${cml_min_gpu_instances:-$DEFAULT_CML_MIN_GPU_INSTANCES}"
         cml_max_gpu_instances="${cml_max_gpu_instances:-$DEFAULT_CML_MAX_GPU_INSTANCES}"

         # Print Assigned Values for CML
         echo "CML (Cloudera Machine Learning) Variables:"
         echo "  WS Instance Type: $cml_ws_instance_type"
         echo "  Min Instances: $cml_min_instances"
         echo "  Max Instances: $cml_max_instances"
         echo "  Enable GPU: $cml_enable_gpu"
         echo "  GPU Instance Type: $cml_gpu_instance_type"
         echo "  Min GPU Instances: $cml_min_gpu_instances"
         echo "  Max GPU Instances: $cml_max_gpu_instances"

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
