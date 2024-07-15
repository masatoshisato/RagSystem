# About this.
This code is a Bicep template designed to create an Azure Virtual Network (VNet) and its associated subnets with specific tags and properties. Below is a detailed description of the code and its components:

### Description
The Bicep template is used to create an Azure Virtual Network with tags and additional properties such as traffic encryption, DDoS protection, and subnets with specific configurations. The template defines several parameters to customize the VNet and its subnets.

### Target Scope
The target scope for this deployment is set to the resource group level, indicating that the VNet and subnets will be created within a specified Azure resource group.

```bicep
targetScope = 'resourceGroup'
```

### Parameters
The template defines several parameters to specify the VNet and subnet configurations, as well as common tags.

1. **Location**: The Azure region where the VNet will be created, derived from the resource group's location.
   ```bicep
   @description('Common Region for the resources that is referenced from the resource group.')
   param Location string = resourceGroup().location
   ```

2. **DeptName**: The managing department name for the resources, applied as a tag. Default is 'default'.
   ```bicep
   @description('The managing department name of the resources. This value is put on a tag.')
   param DeptName string = 'default'
   ```

3. **DeploymentDate**: The creation date of the resources, formatted as "dd/MM/yyyy". This is dynamically set to the current date.
   ```bicep
   @description('Created date of the resources. Formatted as "dd/MM/yyyy". This value is put on a tag.')
   param DeploymentDate string = utcNow('d')
   ```

4. **DeploymentName**: The deployment name specified during the deployment of the resources. This is dynamically set to the current deployment's name.
   ```bicep
   @description('The deployment name specified when the resources are deployed. This value is put on a tag.')
   param DeploymentName string = deployment().name
   ```

### VNet Parameters
The template also defines parameters specific to the VNet.

1. **RagVNetName**: The name of the VNet to be created.
   ```bicep
   @description('The name of the RagVNet.')
   param RagVNetName string
   ```

2. **RagVNetAddressPrefix**: The address prefix for the VNet.
   ```bicep
   @description('The address prefix for the RagVNet.')
   param RagVNetAddressPrefix string
   ```

3. **RagVNetEncryptionEnabled**: Boolean value to enable traffic encryption between VMs.
   ```bicep
   @description('Traffic encryption between VMs enabled.')
   param RagVNetEncryptionEnabled bool
   ```

4. **RagVNetDdosProtectionEnabled**: Boolean value to enable DDoS protection for the VNet.
   ```bicep
   @description('DDoS protection for network enabled.')
   param RagVNetDdosProtectionEnabled bool
   ```

### Resources
The template defines a VNet and two subnets: an AdminSubnet and an AzureBastionSubnet.

#### VNet
```bicep
resource RagVNet 'Microsoft.Network/virtualNetworks@2023-11-01' = {
  name: RagVNetName
  location: Location
  tags: {
    dept: DeptName
    lastDeployed: DeploymentDate
    deploy: DeploymentName
  }
  properties: {
    enableDdosProtection: RagVNetDdosProtectionEnabled
    addressSpace: {
      addressPrefixes: [
        RagVNetAddressPrefix
      ]
    }
    encryption: {
      enabled: RagVNetEncryptionEnabled
      enforcement: 'AllowUnencrypted'
    }
  }
}
```

- **name**: The name of the VNet, as provided by the `RagVNetName` parameter.
- **location**: The region where the VNet will be created, as specified by the `Location` parameter.
- **tags**: A set of tags applied to the VNet, including department, creation date, and deployment name.
- **properties**: Configuration for the VNet, including DDoS protection, address space, and traffic encryption.

#### AdminSubnet
```bicep
resource AdminSubnet 'Microsoft.Network/virtualNetworks/subnets@2023-11-01' = {
  parent: RagVNet
  name: AdminSubnetName
  properties: {
    addressPrefix: AdminSubnetAddressPrefix
    privateEndpointNetworkPolicies: AdminSubnetPrivateEndpointNetworkPolicies
    defaultOutboundAccess: AdminSubnetPrivateEnabled
  }
}
```

- **parent**: The parent VNet to which the subnet belongs.
- **name**: The name of the AdminSubnet, as provided by the `AdminSubnetName` parameter.
- **properties**: Configuration for the subnet, including address prefix, private endpoint network policies, and private subnet flag.

#### AzureBastionSubnet
```bicep
resource BastionSubnet 'Microsoft.Network/virtualNetworks/subnets@2023-11-01' = {
  parent: RagVNet
  name: BastionSubnetName
  properties: {
    addressPrefix: BastionSubnetAddressPrefix
    privateEndpointNetworkPolicies: BastionSubnetPrivateEndpointNetworkPolicies
    defaultOutboundAccess: BastionSubnetPrivateEnabled
  }
}
```

- **parent**: The parent VNet to which the subnet belongs.
- **name**: The name of the AzureBastionSubnet, as provided by the `BastionSubnetName` parameter.
- **properties**: Configuration for the subnet, including address prefix, private endpoint network policies, and private subnet flag.

### Summary
This Bicep template facilitates the creation of an Azure Virtual Network with specified tags and configurations, including traffic encryption and DDoS protection. Additionally, it defines two subnets with specific settings for private endpoint network policies and outbound access. The parameters allow for customization of the VNet and subnet properties, ensuring a flexible and automated deployment process.

# How to deploy with Azure CLI.
To deploy the Azure Virtual Network using the Bicep template and the provided parameter file, you can use the Azure CLI. Below are the steps to perform the deployment along with the command to execute.

### Steps to Deploy with Azure CLI

1. **Ensure you have the Azure CLI installed**: If not, you can install it from [here](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli).

2. **Login to your Azure account**: Open your terminal and run:
   ```bash
   az login
   ```

3. **Navigate to the directory containing your Bicep template and parameters file**: Ensure you have the Bicep file (e.g., `vnet.bicep`) and the parameter file (e.g., `vnet.bicepparam`) in your current directory or provide the correct path.

4. **Prepare the parameters file**: Based on the provided information, your parameters file (e.g., `vnet.bicepparam`) should look like this:

### Parameters File (`vnet.bicepparam`)
Create a file named `vnet.bicepparam` with the following content:

```bicep
using './vnet.bicep'

param RagVNetName = 'RagVNet'
param RagVNetAddressPrefix = '10.0.0.0/16'
param RagVNetEncryptionEnabled = true
param RagVNetDdosProtectionEnabled = false

param AdminSubnetName = 'AdminSubnet'
param AdminSubnetAddressPrefix = '10.0.0.0/29'
param AdminSubnetPrivateEnabled = true
param AdminSubnetPrivateEndpointNetworkPolicies = 'NetworkSecurityGroupEnabled'

param BastionSubnetName = 'AzureBastionSubnet'
param BastionSubnetAddressPrefix = '10.0.0.64/26'
param BastionSubnetPrivateEnabled = true
param BastionSubnetPrivateEndpointNetworkPolicies = 'Disabled'
```

5. **Deploy the Bicep template**: Use the following Azure CLI command to deploy the VNet and its subnets using the parameters file.

### Azure CLI Deployment Command

```bash
az deployment group create --resource-group <your-resource-group> --template-file vnet.bicep --parameters @vnet.bicepparam
```

### Example Command Breakdown
- `az deployment group create`: This command initiates a deployment at the resource group scope.
- `--resource-group <your-resource-group>`: Specifies the name of the resource group where the resources will be deployed. Replace `<your-resource-group>` with the actual name of your resource group.
- `--template-file vnet.bicep`: Specifies the Bicep template file to be used for the deployment.
- `--parameters @vnet.bicepparam`: Provides the parameters file containing the values for the parameters defined in the Bicep template.

### Full Deployment Command Example

Assuming your resource group is named `MyResourceGroup`, the command would be:

```bash
az deployment group create --resource-group MyResourceGroup --template-file vnet.bicep --parameters @vnet.bicepparam
```

### Summary
By following these steps and using the provided Azure CLI command, you can deploy your Azure Virtual Network and its subnets using the Bicep template with the specified parameters. This ensures a streamlined and automated deployment process, leveraging the configuration provided in the parameters file.
