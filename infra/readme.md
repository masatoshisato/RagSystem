# Azure Resource Deployment using Bicep

This repository contains Bicep files for deploying a system in Azure, including a resource group, a virtual network (VNet), and subnets. 

## Files

- **main.bicep**: Defines the main infrastructure components including resource group and virtual network.
- **main.bicepparam**: Contains the parameters used by the `main.bicep` file.

## Prerequisites

- Azure CLI installed and logged in.
- Bicep CLI installed.
- Environment variables set for `SYSTEM_NAME`, `AZURE_ENV_NAME`, and `AZURE_LOCATION`.

## Deployment Steps

### Step 1: Set Environment Variables

Ensure the following environment variables are set in your terminal session:

```sh
export SYSTEM_NAME=<your-system-name>
export AZURE_ENV_NAME=<your-environment-name>
export AZURE_LOCATION=<your-location>
```

### Step 2: Deploy the Resources

Use the Azure Developer CLI (`azd`) to deploy the resources defined in the Bicep files.

```sh
azd up --template-file main.bicep --parameters main.bicepparam
```

### Step 3: Clean Up Resources

To remove the deployed resources, use the following command:

```sh
azd down
```

### Bicep File Details

#### main.bicep

This file includes the definitions for:

- **Common Parameters**:
  - `systemName`: System name used for naming resources.
  - `environmentName`: Environment name used for naming resources.
  - `location`: Azure region where the resources will be deployed.
  - `deploymentDate`: Date of deployment, used in tags.

- **Common Variables**:
  - `tags`: Tags applied to all resources.
  - `rgName`: Name of the resource group.

- **Resource Group**:
  - Creates a resource group with specified tags.

- **Virtual Network (VNet)**:
  - Parameters for VNet and subnets:
    - `ragVNet_name`: Name of the virtual network.
    - `ragVNet_addressPrefix`: Address prefix for the VNet.
    - `ragVNet_encryptionEnabled`: Flag for traffic encryption.
    - `ragVNet_ddosProtectionEnabled`: Flag for DDoS protection.
    - `adminSubnet_name`: Name of the admin subnet.
    - `adminSubnet_addressPrefix`: Address prefix for the admin subnet.
    - `adminSubnet_privateEnabled`: Flag for private endpoint.
    - `adminSubnet_privateEndpointNetworkPolicies`: Network policies for private endpoints.
    - `bastionSubnet_name`: Name of the Bastion subnet.
    - `bastionSubnet_addressPrefix`: Address prefix for the Bastion subnet.
    - `bastionSubnet_privateEnabled`: Flag for private endpoint.
    - `bastionSubnet_privateEndpointNetworkPolicies`: Network policies for private endpoints.

#### main.bicepparam

This file sets the parameter values for the Bicep template:

- **System and Environment Parameters**:
  - `systemName`: Retrieved from environment variable `SYSTEM_NAME`.
  - `environmentName`: Retrieved from environment variable `AZURE_ENV_NAME`.
  - `location`: Retrieved from environment variable `AZURE_LOCATION`.

- **VNet Parameters**:
  - `ragVNet_name`: VNet name combining system and environment names.
  - `ragVNet_addressPrefix`: Address prefix for the VNet.
  - `ragVNet_encryptionEnabled`: Encryption enabled.
  - `ragVNet_ddosProtectionEnabled`: DDoS protection disabled.

- **Admin Subnet Parameters**:
  - `adminSubnet_name`: Name of the admin subnet.
  - `adminSubnet_addressPrefix`: Address prefix for the admin subnet.
  - `adminSubnet_privateEnabled`: Private endpoint enabled.
  - `adminSubnet_privateEndpointNetworkPolicies`: Network policies for private endpoints.

- **Bastion Subnet Parameters**:
  - `bastionSubnet_name`: Name of the Bastion subnet.
  - `bastionSubnet_addressPrefix`: Address prefix for the Bastion subnet.
  - `bastionSubnet_privateEnabled`: Private endpoint enabled.
  - `bastionSubnet_privateEndpointNetworkPolicies`: Network policies for private endpoints.

## Conclusion

By following the steps above, you can deploy the specified Azure resources using the provided Bicep templates. Make sure to customize the parameter values as needed for your specific environment and requirements.

---