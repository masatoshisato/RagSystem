#!/bin/bash
# This script assigns the Key Vault Secrets User role to the security group.
#
# This script is required tools and environment variables below.
# - Tools:
#    * Azure CLI
#    * jq
# - Environment Variables
#    * SYSTEM_OPERATORS_SG_NAME: The name of the security group for the RagSystem-Operators.
#    * RESOURCE_GROUP_NAME: The name of the resource group where the security group will be created.

# Check if the .azure/dev/.env file exists.
if [ -f .azure/dev/.env ]; then
  source .azure/dev/.env
else
  echo "The .azure/dev/.env file does not exist."
  exit 1
fi

echo "Subscription ID is '$AZURE_SUBSCRIPTION_ID'"
echo "Resource group name is '$RESOURCE_GROUP_NAME'"
echo "System operators security group name is '$SYSTEM_OPERATORS_SG_NAME'"
echo "Key Vault name for Admin VM is '$kvAdminVm_name' (one of the output value of bicep)"

############################################################
## Retrive a security group ID of the RagSystem-Operators.
echo
echo "Retrieving Security Group ID of '$SYSTEM_OPERATORS_SG_NAME'..."
sg_id=$(az ad group show --group "$SYSTEM_OPERATORS_SG_NAME" --query id -o tsv)

# Check the security group ID if it exists.
if [[ -z "$sg_id" ]]; then
  echo "Security Group '$SYSTEM_OPERATORS_SG_NAME' was not found."
  exit 1
fi

############################################################
## Assign the Key Vault Secrets User role to the RagSystem-Operators security group.
role_name="Key Vault Secrets User"
echo
echo "Assigning '$role_name' role to '$SYSTEM_OPERATORS_SG_NAME' security group..."

# Check if the role assignment exists
echo "Checking if the role '$role_name' is already assigned to '$SYSTEM_OPERATORS_SG_NAME'..."
ASSIGNMENT_ID=$(az role assignment list --assignee "$sg_id" --scope "/subscriptions/$AZURE_SUBSCRIPTION_ID/resourceGroups/$RESOURCE_GROUP_NAME/providers/Microsoft.KeyVault/vaults/$kvAdminVm_name" --query "[?roleDefinitionName=='$role_name']" | jq '.[0].id' -r)
if [[ -n "$ASSIGNMENT_ID" ]]; then
  echo "The role '$role_name' is already assigned to '$SYSTEM_OPERATORS_SG_NAME'."
else
  # Create a role assignment
  echo "Assigning the role '$role_name' to the RagSystem-Operators security group..."
  az role assignment create --role "$role_name" --assignee "$sg_id" --scope "/subscriptions/$AZURE_SUBSCRIPTION_ID/resourceGroups/$RESOURCE_GROUP_NAME/providers/Microsoft.KeyVault/vaults/$kvAdminVm_name"
  if [ $? -ne 0 ]; then
    echo "Failed to assign the role '$role_name' to the RagSystem-Operators security group."
    exit 1
  else
    echo "Role assignment completed successfully."
  fi
fi
