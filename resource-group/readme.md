## About this.
This code is a Bicep template designed to create an Azure Resource Group with specific tags. Below is a detailed description of the code and its components:

### Description
The Bicep template is used to create an Azure Resource Group with predefined tags. These tags include information about the managing department, the resource owner, the creation date, and the deployment name. The template defines several parameters to customize the resource group and its tags.

### Target Scope
The target scope for this deployment is set to the subscription level, indicating that the resource group will be created within a specified Azure subscription.

```bicep
targetScope = 'subscription'
```

### Parameters
The template defines several parameters to specify the resource group's location, name, and tags.

1. **_rgLocation**: The Azure region where the resource group will be created. Default is set to 'japaneast'.
   ```bicep
   @description('Common Region for the resources that are created by this template.')
   param _rgLocation string = 'japaneast'
   ```

2. **_rgName**: The name of the resource group to be created. This is a mandatory parameter.
   ```bicep
   @description('Resource group name that you will create.')
   param _rgName string
   ```

3. **_tagDeptName**: The department managing the resources. Default is 'iocc'.
   ```bicep
   @description('The managing department name of the resources. This value is put on a tag.')
   param _tagDeptName string = 'iocc'
   ```

4. **_tagOwnerName**: The owner of the resources. Default is 'iocc_sato'.
   ```bicep
   @description('The managing owner name of the resources. This value is put on a tag.')
   param _tagOwnerName string = 'iocc_sato'
   ```

5. **_tagUtcShort**: The creation date of the resources, formatted as "dd/MM/yyyy". This is dynamically set to the current date.
   ```bicep
   @description('Created date of the resources. Formatted as "dd/MM/yyyy". This value is put on a tag.')
   param _tagUtcShort string = utcNow('d')
   ```

6. **_tagDeploymentName**: The deployment name specified during the deployment of the resources. This is dynamically set to the current deployment's name.
   ```bicep
   @description('The deployment name specified when the resources are deployed. This value is put on a tag.')
   param _tagDeploymentName string = deployment().name
   ```

### Resources
The template defines a single resource group with the specified parameters and tags.

```bicep
resource newRG 'Microsoft.Resources/resourceGroups@2022-09-01' = {
  name: _rgName
  location: _rgLocation
  tags: {
    dept: _tagDeptName
    owner: _tagOwnerName
    lastDeployed: _tagUtcShort
    deploy: _tagDeploymentName
  }
}
```

- **name**: The name of the resource group, as provided by the `_rgName` parameter.
- **location**: The region where the resource group will be created, as specified by the `_rgLocation` parameter.
- **tags**: A set of tags applied to the resource group, including department, owner, creation date, and deployment name.

### Summary
This Bicep template facilitates the creation of an Azure Resource Group with specified tags that include management and deployment details. The parameters allow for customization of the resource group's name, location, and tag values, while the use of dynamic parameters ensures the inclusion of current deployment information.

## How to deploy with Azure CLI.
To deploy the Azure Resource Group using this Bicep template, you can use the Azure CLI. Below are the steps to perform the deployment along with the command to execute.

### Steps to Deploy with Azure CLI

1. **Ensure you have the Azure CLI installed**: If not, you can install it from [here](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli).

2. **Login to your Azure account**: Open your terminal and run:
   ```bash
   az login
   ```

3. **Navigate to the directory containing your Bicep template**: Ensure you have the Bicep file (e.g., `rg.bicep`) in your current directory or provide the correct path.

4. **Deploy the Bicep template**: Use the following Azure CLI command to deploy the resource group. Replace `_rgName` with the desired resource group name, for example, `IoccSato01`.

### Azure CLI Deployment Command

```bash
az deployment sub create --template-file rg.bicep --parameters _rgName=IoccSato01
```

### Example Command Breakdown
- `az deployment sub create`: This command initiates a deployment at the subscription scope.
- `--template-file rg.bicep`: Specifies the Bicep template file to be used for the deployment.
- `--parameters _rgName=IoccSato01`: Provides the required parameter for the resource group name.

### Full Deployment Command Example

```bash
az deployment sub create --template-file rg.bicep --parameters _rgName=IoccSato01
```

### Additional Parameters
If you need to specify additional parameters (e.g., `_rgLocation`, `_tagDeptName`), you can include them in the command as follows:

```bash
az deployment sub create --template-file rg.bicep --parameters _rgName=IoccSato01 _rgLocation=westeurope _tagDeptName=finance
```

### Summary
By following these steps and using the provided Azure CLI command, you can deploy your Azure Resource Group using the Bicep template with specified parameters. This allows for a streamlined and automated deployment process.