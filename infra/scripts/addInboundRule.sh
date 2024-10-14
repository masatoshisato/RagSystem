#!/bin/bash

# This script adds an inbound rule to a specified Network Security Group (NSG) 
# to allow traffic from the client's public IP address.
# The rule is added with a priority that is 10 lower than the current lowest 
# priority inbound rule with a priority less than 4096.
# If the calculated priority exceeds 4096, the script exits with an error.
#
# Usage:
# ./addInboundRule.sh <resource-group> <nsg-name>
#
# Parameters:
# <resource-group> : The name of the resource group containing the NSG.
# <nsg-name>       : The name of the Network Security Group to which the rule
#                    will be added.
#
# Example:
# ./addInboundRule.sh myResourceGroup myNsg
#
# Recommendations:
# - Ensure that you have the necessary permissions to modify the NSG.
# - Run this script from a secure environment to avoid exposing your public IP
#   address.
# - Verify the existing rules and priorities in the NSG to avoid conflicts.

# Check parameters.
if [[ "$#" -ne 2 ]]; then
  echo "Usage: $0 <resource-group> <nsg-name>"
  exit 1
fi

# Set parameters to variables that are easier to understand.
RESOURCE_GROUP=$1
NSG_NAME=$2

# Get public IP address of the client.
IP_ADDRESS=$(curl -s ifconfig.me)
echo "  Your Public IP Address: $IP_ADDRESS"

# Check if the NSG rule already exists.
SAME_RULE_NAME=$(az network nsg rule list --resource-group $RESOURCE_GROUP --nsg-name $NSG_NAME --query "[?sourceAddressPrefix=='$IP_ADDRESS'&&direction=='Inbound'] | [0].name" -o tsv)
if [[ -n "$SAME_RULE_NAME" ]]; then
  echo "Ignored: The IP address '$IP_ADDRESS' already exists in Inbound rule '$SAME_RULE_NAME' of NSG '$NSG_NAME' in resource group '$RESOURCE_GROUP'."
  exit 1
fi

# Build rule name.
# Example: AllowInboundFrom_1.2.3.4
RULE_NAME="AllowInboundFrom_$IP_ADDRESS"

# Retrieve the lowest priority value among the Inbound rules with a priority less than 4096.
# If the lowest priority value cannot be obtained, set the default priority.
LOWEST_PRIORITY=$(az network nsg rule list --resource-group $RESOURCE_GROUP --nsg-name $NSG_NAME --query "[?priority < to_number('4096') && direction == 'Inbound'] | reverse(sort_by([], &priority)) | [0].priority" -o tsv)
echo "  Current lowest Inbound rule priority: $LOWEST_PRIORITY"
if [[ -z "$LOWEST_PRIORITY" ]]; then
  LOWEST_PRIORITY=100
fi

# Calculate the new priority.
# If the new priority exceeds the maximum allowed value of 4096 then exit with an error.
NEW_PRIORITY=$((LOWEST_PRIORITY + 10))
echo "  New rule priority: $NEW_PRIORITY"
if [[ "$NEW_PRIORITY" -gt 4096 ]]; then
  echo "Error: The calculated priority ($NEW_PRIORITY) exceeds the maximum allowed value of 4096."
  exit 1
fi

# Add the new NSG rule.
az network nsg rule create --resource-group "$RESOURCE_GROUP" --nsg-name "$NSG_NAME" --name "$RULE_NAME" --priority "$NEW_PRIORITY" --direction Inbound --access Allow --protocol TCP --source-address-prefixes "$IP_ADDRESS" --source-port-ranges "*" --destination-address-prefixes "*" --destination-port-ranges "443"
if [[ $? -eq 0 ]]; then
  echo "Success: Added NSG rule '$RULE_NAME' with priority '$NEW_PRIORITY' to NSG '$NSG_NAME' in resource group '$RESOURCE_GROUP'."
else
  echo "Failed to add NSG rule."
  exit 1
fi