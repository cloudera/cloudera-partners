#!/bin/bash
# ***************************************************************************************************#
source /usr/local/bin/hol-functions.sh
# Setting required path and variables.
USER_CONFIG_FILE="/userconfig/configfile"
TERRAFORM_DIR=$HOME_DIR/cdp-wrkshps-quickstarts/cdp-kc-config/keycloak_terraform_config
DS_CONFIG_DIR=$HOME_DIR/cdp-wrkshps-quickstarts/cdp-data-services
USER_ACTION=$1
# Handling the User Action ('provision' or 'destroy').
case $USER_ACTION in
    provision)
        validating_variables
        key_pair_file
        setup_aws_and_cdp_profile
        aws_prereq
        cdp_prereq
        if [ "$provision_keycloak" == "yes" ]; then
            setup_keycloak_ec2 $keycloak_sg_name
            if [ $? -ne 0 ]; then
                echo "Keycloak Server Provisioning Failed. Rolling Back The Changes."
                destroy_keycloak
                echo "Infrastructure Provisioning For $workshop_name Is Not Successful.
                Please Try Again. Exiting....."
                exit 1
            else
                echo -e "\n               =============================Keycloak Server Provisioned=============================="
                echo
            fi
        else
            echo -e "Keycloak Provisioning skipped, as instructed in configfile...\n"
        fi
        sleep 10
        provision_cdp
        if [ $? -ne 0 ]; then
            echo "CDP Environment Provisioning Failed. Rolling Back The Changes."
            destroy_cdp
            if [ "$provision_keycloak" == "yes" ]; then
                destroy_keycloak
            fi
            echo "Infrastructure Provisioning For $workshop_name Is Not Successful.
            Please Try Again. Exiting....."
            exit 1
        else
            echo -e "\n               =============================CDP Environment Provisioned=============================="
            echo
        fi
        update_cdp_user_group
        if [ "$provision_keycloak" == "yes" ]; then
            cdp_idp_setup_user
        fi
        enable_data_services
        echo -e "\n               ==============================Infrastructure Provisioned========================================="
        
    ;;
    destroy)
        validating_variables
        setup_aws_and_cdp_profile
        if [ "$provision_keycloak" == "yes" ]; then
            cdp_idp_user_teardown
        fi
        disable_data_services
        destroy_hol_infra
    ;;
    *)
        echo "Invalid Input. Valid values are 'provision' or 'destroy'"
    ;;
    
esac
# ***********************************************************************************************#
