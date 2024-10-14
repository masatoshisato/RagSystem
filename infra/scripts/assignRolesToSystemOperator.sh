#!/bin/bash

# This script assigns some Azure Roles to Syste Operator Security Group for
# acccess to the Bastion to login to the VMs via the Bastion using the password 
# within KeyVault secret.
# The roles assigned include "Reader" roles for VM, NIC, Bastion, VNet, and
# Key Vault, as well as the "Key Vault Secrets User" role for the Key Vault.
#
# Usage:
# ./assignRolesToSystemOperator.sh <resource-group> <security-group-name>
#
# Parameters:
# <resource-group>        : The name of the resource group containing the resources.
# <security-group-name>   : The name of the security group to which the roles will be assigned.
#
# Example:
# ./assignRolesToSystemOperator.sh myResourceGroup mySecurityGroup
#
# Recommendations:
# - Ensure that you have the necessary permissions to assign roles.
# - Verify the existence of the security group and resources before running the script.
# - Run this script from a secure environment to avoid exposing sensitive information.

# Get the directory of the script.
SCRIPT_DIR=$(cd $(dirname $0); pwd)

# Create a variable that is indicating the assignAzureRoles.sh script.
ASSIGN_ROLE="$SCRIPT_DIR/assignAzureRoles.sh"

# Check if the .azure/dev/.env file exists.
if [ -f .azure/dev/.env ]; then
  source .azure/dev/.env
else
  echo "The .azure/dev/.env file does not exist."
  exit 1
fi
echo "System operators security group name is '$SYSTEM_OPERATORS_SG_NAME'"
echo "VM is '$adminVm_name($adminVm_id)'"
echo "NIC is '$adminVm_nic_name($adminVm_nic_id)'"
echo "Bastion is '$bastion_name($bastion_id)'"
echo "VNet is '$vNet_name($vNet_id)'"
echo "KV is '$kv_name($kv_id)'"

# Assign VM's Reader role to the System Operator Security Group.
VM_READER_ROLE_NAME="Reader"
"$ASSIGN_ROLE" $adminVm_id "$VM_READER_ROLE_NAME" $SYSTEM_OPERATORS_SG_NAME

# Assign NIC's Reader role to the System Operator Security Group.
NIC_READER_ROLE_NAME="Reader"
"$ASSIGN_ROLE" $adminVm_nic_id "$NIC_READER_ROLE_NAME" $SYSTEM_OPERATORS_SG_NAME

# Assign Bastion's Reader role to the System Operator Security Group.
BASTION_READER_ROLE_NAME="Reader"
"$ASSIGN_ROLE" $bastion_id "$BASTION_READER_ROLE_NAME" $SYSTEM_OPERATORS_SG_NAME

# Assign VNet's Reader role to the System Operator Security Group.
VNET_READER_ROLE_NAME="Reader"
"$ASSIGN_ROLE" $vNet_id "$VNET_READER_ROLE_NAME" $SYSTEM_OPERATORS_SG_NAME

# Assign Key Vault's Reader role to the System Operator Security Group.
KV_READER_ROLE_NAME="Reader"
"$ASSIGN_ROLE" $kv_id "$KV_READER_ROLE_NAME" $SYSTEM_OPERATORS_SG_NAME

# Assign Key Vault's Secrets User role to the System Operator Security Group.
KV_SECRETS_USER_ROLE_NAME="Key Vault Secrets User"
"$ASSIGN_ROLE" $kv_id "$KV_SECRETS_USER_ROLE_NAME" $SYSTEM_OPERATORS_SG_NAME

