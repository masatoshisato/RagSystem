#!/bin/bash
# This script creates a security group for the RagSystem-Operators.
#
# This script required the tools and environment variables below.
# - Tools: Azure CLI
# - Variables: SYSTEM_OPERATORS_SG_NAME: The name of the security group for the RagSystem-Operators.

# Check if the .azure/dev/.env file exists.
if [ -f .azure/dev/.env ]; then
  source .azure/dev/.env
else
  echo "The .azure/dev/.env file does not exist."
  exit 1
fi

echo "System operators security group name is '$SYSTEM_OPERATORS_SG_NAME'"

############################################################
## Create a security group for the RagSystem-Operators.
echo
echo "Creating Security Group '$SYSTEM_OPERATORS_SG_NAME'..."

# Check if the security group already exists.
echo "Checking if the Security Group '$SYSTEM_OPERATORS_SG_NAME' already exists..."
sg_id=$(az ad group show --group "$SYSTEM_OPERATORS_SG_NAME" --query id -o tsv)

# Create a security group if it does not exist.
if [[ -z "$sg_id" ]]; then
  echo "Creating Security Group '$SYSTEM_OPERATORS_SG_NAME'..."
  sg_id=$(az ad group create --display-name "$SYSTEM_OPERATORS_SG_NAME" --mail-nickname "$SYSTEM_OPERATORS_SG_NAME" --query id -o tsv)
  if [[ -z "$sg_id" ]]; then
    echo "Failed to create Security Group '$SYSTEM_OPERATORS_SG_NAME'."
    exit 1
  fi
else
  echo "Security Group '$SYSTEM_OPERATORS_SG_NAME' ($sg_id) already exists."
fi