#!/bin/bash
set -e

# Setting required path and variables
USER_CONFIG_FILE="/k8soperators/configfile"
USER_ACTION=$1

#Copy terraform and ansible to have a copy on host machine
if [ ! -d "/k8soperators/terraform" ]; then
   cp -r /opt/automation/terraform "/k8soperators/"
fi

if [ ! -d "/k8soperators/ansible" ]; then
   cp -r /opt/automation/ansible "/k8soperators/"
fi

validating_variables() {
   echo
   echo "                    ---------------------------------------------------------------------                "
   echo "                    Validating the Configfile and Verifying the Provided Input Parameters                "
   echo "                    ---------------------------------------------------------------------                "
   echo
   sleep 10

   if [ ! -f "$USER_CONFIG_FILE" ]; then
      echo "=================================================================================="
      echo "FATAL: Config File ('configfile') not found in current directory.
Please make sure you have mounted the local directory using -v flag and created the file 'configfile' without any extension.
If you are running Docker on Windows, create the folder under 'C:/Users/<Your_Windows_User_Name>/' and try again.
Exiting......"
      echo "=================================================================================="
      exit 9999
   fi

   ## Cleaning up 'configfile' to remove Windows ^M characters
   #sed -i 's/\r//g' "$USER_CONFIG_FILE"

   # Cleaning up 'configfile' to remove Windows ^M characters
  if [[ "$OSTYPE" == "darwin"* ]]; then
   sed -i '' 's/\r//g' "$USER_CONFIG_FILE"
  else
   sed -i 's/\r//g' "$USER_CONFIG_FILE"
  fi


   #--------------------------------------------------------------------------------------------------#

   # Function to check config file for missing keys and empty values
   check_config() {
      local USER_CONFIG_FILE="$1"

      # Define the required keys
      REQUIRED_KEYS=(
         "LOCAL_MACHINE_IP"
         "K8S_DISTRIBUTION"
         "ADMIN_PASSWORD"
         "CLOUDERA_USERNAME"
         "CLOUDERA_PASSWORD"
         "INSTALL_OPERATORS"
         "AWS_REGION"
      )
      if [[ "$k8s_distribution" == "eks" ]]; then
         REQUIRED_KEYS+=(
            "INSTALLATION_HOST"
         )
         if [[ "$provision_ec2" == "yes" ]]; then
             echo "=================================================================================="
            echo "FATAL: the value of provision_ec2 cannot be 'yes' when k8s_distribution is set to 'eks'."
            echo "Please update the 'configfile' and set the value of provision_ec2 to 'no'."
            echo "Exiting......"
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

      # Exiting on missing keys
      if [ ${#MISSING_KEYS[@]} -gt 0 ] || [ ${#EMPTY_VALUES[@]} -gt 0 ]; then
         echo "========================================================================================="
         echo "EXITING......"
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
         PROVISION_EC2) 
            provision_ec2=$(echo "$value" | tr '[:upper:]' '[:lower:]')
            ;;
         INSTALLATION_HOST)
            installation_host=$value
            ;;
         AWS_REGION)
            aws_region=$(echo "$value" | tr '[:upper:]' '[:lower:]')
            ;;
         SSH_KEY_PAIR)
            ssh_key_pair=$value
            ;;
         K8S_DISTRIBUTION)
            k8s_distribution=$(echo "$value" | tr '[:upper:]' '[:lower:]')
            ;;
         ADMIN_PASSWORD)
            admin_password=$value
            ;;
         CLOUDERA_USERNAME)
            cloudera_username=$value
            ;;
         CLOUDERA_PASSWORD)
            cloudera_password=$value
            ;;
         LOCAL_MACHINE_IP)
            local_ip=$value
            ;;
         INSTALL_OPERATORS)
            install_operators=$value
            ;;
         INSTANCE_TYPE)
            instance_type=$(echo "$value" | tr '[:upper:]' '[:lower:]')
            ;;
         CLUSTER_NAME)
            cluster_name=$value
            ;;
         esac
         # Print the key-value except for sensitive fields
         case "$key" in
            ADMIN_PASSWORD|CLOUDERA_PASSWORD|CLOUDERA_USERNAME)
                ;;  # Do nothing
            *)
                echo "Loaded Config: $key = $value"
                ;;
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

# Function for checking .pem file.
key_pair_file() {
   # Checking if SSH Keypair File exists.
   if [[ ! -f "/k8soperators/$ssh_key_pair.pem" ]]; then
      echo "=================================================================================="
      echo "FATAL: SSH Key Pair File Not Found. Please place the '$ssh_key_pair.pem'
file in your config directory and try again.
EXITING....."
      echo "=================================================================================="
      exit 9999 # die with error code 9999
   else
      echo "Using existing ssh_key_pair"
   fi
}

deploy_ec2() {

  # Navigate to Terraform directory
  cd /k8soperators/terraform

  # Initialize and apply Terraform
  terraform init
  terraform apply -auto-approve -lock=false\
      -var "local_ip=$local_ip" \
      -var "key_name=$ssh_key_pair" \
      -var "aws_region=$aws_region" \
      -var "instance_name=$cluster_name" \
      -var "instance_type=$instance_type"
      
  RETURN=$?
   if [ $RETURN -eq 0 ]; then
      # Extract the EC2 public IP from Terraform output
      EC2_PUBLIC_IP=$(terraform output -raw public_ip)
      INSTANCE_NAME=$(terraform output -raw instance_name)
      
      echo "$INSTANCE_NAME" > /k8soperators/.instance_name
      # Export for Ansible use
      export installation_host="$EC2_PUBLIC_IP"
      export instance_name="$INSTANCE_NAME"

      if [[ ! -f "/k8soperators/$ssh_key_pair.pem" ]]; then
      # Only copy if using a newly generated key
      cp -pf ec2/generated-$instance_name.pem "/k8soperators/"
      fi


      # Return to original directory
      cd ..
      return 0
   else
      cd .. 
      return 1
   fi  
}

destroy_ec2() {
  # Navigate to Terraform directory
  cd /k8soperators/terraform

  # Initialize and apply Terraform
  terraform init
  terraform destroy -auto-approve -lock=false \
      -var "local_ip=$local_ip" \
      -var "key_name=$ssh_key_pair" \
      -var "aws_region=$aws_region" \
      -var "instance_name=$cluster_name" \
      -var "instance_type=$instance_type"
  RETURN=$?

   if [ $RETURN -eq 0 ]; then
      instance_name=$(cat "/k8soperators/.instance_name")
      rm -rf /k8soperators/generated-$instance_name.pem /k8soperators/terraform /k8soperators/ansible /k8soperators/.instance_name

      # Return to original directory
      cd ..
      return 0
   else
      cd ..
      return 1
   fi  
}
deploy_dimoperators() {
  # Navigate to ansible directory
  cd /k8soperators/ansible

  echo "INSTALLATION HOST IP: $installation_host"

  # Only read instance_name from file if EC2 is provisioned 
  if [ "$provision_ec2" == "true" ]; then
  [ -z "$instance_name" ] && instance_name=$(cat "/k8soperators/.instance_name")
  fi

  if [ -f "/k8soperators/$ssh_key_pair.pem" ]; then
      ssh_private_key_file="/k8soperators/$ssh_key_pair.pem"
  else
      ssh_private_key_file="/k8soperators/generated-$instance_name.pem"
  fi

  if [ ! -f ansible/roles/deployment/dim_operators/files/cloudera_license.txt ]; then
    cp /k8soperators/cloudera_license.txt roles/deployment/dim_operators/files/cloudera_license.txt
  fi

#Initializing cluster name if not set
  if [ -z "$cluster_name" ]; then
    cluster_name="DimOperatorsdemo"
  fi
  # Run the Ansible playbook using the inventory.yaml
  ansible-playbook -vv -i inventory.yaml playbook.yaml \
    --extra-vars "INSTALLATION_HOST=$installation_host \
                  k8s_distribution=$k8s_distribution \
                  ssh_private_key_file=$ssh_private_key_file \
                  ldapadmin_password=$admin_password \
                  nifiadmin_password=$admin_password \
                  Cloudera_username=$cloudera_username \
                  Cloudera_password=$cloudera_password \
                  install_operators=$install_operators \
                  cluster_name=$cluster_name \
                  node_type=$instance_type \
                  region=$aws_region"
                  
}

destroy_eks() {
  cd /k8soperators/ansible

  echo "INSTALLATION HOST IP: $installation_host"

  # Only read instance_name from file if EC2 is provisioned 
  if [ "$provision_ec2" == "true" ]; then
  [ -z "$instance_name" ] && instance_name=$(cat "/k8soperators/.instance_name")
  fi

  if [ -f "/k8soperators/$ssh_key_pair.pem" ]; then
      ssh_private_key_file="/k8soperators/$ssh_key_pair.pem"
  else
      ssh_private_key_file="/k8soperators/generated-$instance_name.pem"
  fi
  #Initializing cluster name if not set
  if [ -z "$cluster_name" ]; then
    cluster_name="DimOperatorsdemo"
  fi
   ansible-playbook -vv -i inventory.yaml destroy_eks_cluster.yaml \
     --extra-vars "INSTALLATION_HOST=$installation_host \
                   ssh_private_key_file=$ssh_private_key_file \
                   cluster_name=$cluster_name \
                   region=$aws_region"

}
case $USER_ACTION in
provision)
# Run functions
# Call validating_variables function if script is run directly
    validating_variables
    if [[ -n "$ssh_key_pair" ]]; then
        key_pair_file
    else
        echo "No AWS Key Pair provided. A New key_pair will be generated."
    fi
    if [ "$provision_ec2" == "yes" ]; then
    deploy_ec2
    sleep 30
    else
        echo "Deploying k8soperators on existing server"
    fi
    deploy_dimoperators
    ;;
destroy)
    validating_variables
    if [ "$provision_ec2" == "yes" ]; then
    destroy_ec2
    fi
    if [ "$k8s_distribution" == "eks" ]; then
    destroy_eks
    fi
    ;;
*)
    echo "Invalid Input. Valid values are 'provision' or 'destroy'"
    exit 1
    ;;

esac