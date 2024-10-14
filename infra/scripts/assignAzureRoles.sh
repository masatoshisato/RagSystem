#!/bin/bash

# This script assigns a specified role to a security group for a given Azure 
# resource.
# It requires the Azure CLI and jq to be installed and configured.
#
# Usage:
# ./assignAzureRoles.sh <resource_id> <role_name> <security_group_name>
#
# Parameters:
# <resource_id>          : The ID of the resource to which the role will be assigned.
# <role_name>            : The name of the role to assign.
# <security_group_name>  : The name of the security group to which the role will be assigned.
#
# Example:
# ./assignAzureRoles.sh /subscriptions/<subscription-id>/resourceGroups/myResourceGroup/providers/Microsoft.Compute/virtualMachines/myVM Reader mySecurityGroup
#
# Recommendations:
# - Ensure that you have the necessary permissions to assign roles.
# - Verify the existence of the security group and resource before running the script.
# - Run this script from a secure environment to avoid exposing sensitive information.

############################################################
# Retrieve the script parameters.
if [ $# -ne 3 ]; then
  echo "Error: Missing required parameters."
  echo "Usage"
  echo "    $0 <resource_id> <role_name> <security_group_name>"
  echo
  exit 1
fi
resource_id=$1
role_name=$2
security_group_name=$3
echo
echo "Resource ID is '$resource_id'"
echo "Role name is '$role_name'"
echo "Security group name is '$security_group_name'"

############################################################
## Retrive a security group ID of the RagSystem-Operators.
echo
echo "Retrieving Security Group ID of '$security_group_name'..."
sg_id=$(az ad group show --group "$security_group_name" --query id -o tsv)

# Check the security group ID if it exists.
if [[ -z "$sg_id" ]]; then
  echo "Security Group '$security_group_name' was not found."
  exit 1
fi

############################################################
## Assign the Key Vault Secrets User role to the RagSystem-Operators security group.
echo
echo "Assigning '$role_name' role of '$resource_id' to '$security_group_name' security group..."

# Check if the role assignment exists
echo "Checking if the role '$role_name' is already assigned to '$security_group_name'..."
assignment_id=$(az role assignment list --assignee "$sg_id" --scope "$resource_id" --query "[?roleDefinitionName=='$role_name'].id" -o tsv)
if [[ -n "$assignment_id" ]]; then
  echo "The role '$role_name' is already assigned to '$security_group_name'."
else
  # Create a role assignment
  echo "Assigning the role '$role_name' to the '$security_group_name'..."
  az role assignment create --role "$role_name" --assignee "$sg_id" --scope "$resource_id"
  if [ $? -ne 0 ]; then
    echo "Failed to assign the role '$role_name' to the '$security_group_name'."
    exit 1
  else
    echo "Role assignment completed successfully."
  fi
fi
