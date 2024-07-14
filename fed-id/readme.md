# Azure AD Application and Service Principal Creation Script

This script uses Azure CLI to create an Azure Active Directory (Azure AD) application and service principal, assign a role to the application, and create federated credentials. These credentials allow the application to interact with other identity providers (IDPs), such as GitHub, to manage Azure resources through GitHub Actions CI/CD workflows.

## Table of Contents

- [Prerequisites](#prerequisites)
- [Usage](#usage)
- [Options](#options)
- [Example](#example)
- [Script Details](#script-details)
- [Troubleshooting](#troubleshooting)

## Prerequisites

Before running this script, ensure you have the following:

- Azure CLI installed and authenticated
- jq installed for JSON processing
- Appropriate permissions to create Azure AD applications and assign roles
- GitHub Actions JSON configuration file (`githubactions.json`)

## Usage

To use this script, run it from your terminal with the necessary parameters.

```bash
./create_azure_ad_app.sh [options]
```

## Options

- `--rg-name <name>` : Specify the resource group name.
- `--app-name <name>` : Specify the application name.
- `--verbose` : Enable verbose mode.
- `--help` : Display the help message.

## Example

```bash
./create_azure_ad_app.sh --rg-name RagSystem --app-name GithubActions --verbose
```

## Script Details

This script performs the following steps:

1. **Get Current Account Information**:
    - Retrieves the current Azure subscription and tenant IDs.

2. **Create a New Application**:
    - Checks if an application with the specified name already exists.
    - If not, creates a new Azure AD application.

3. **Create a New Service Principal**:
    - Checks if a service principal for the application already exists.
    - If not, creates a new service principal for the application.

4. **Add Role to Service Principal**:
    - Assigns the `Contributor` role to the service principal for the specified resource group.

5. **Create New Federated Credential**:
    - Checks if federated credentials for the application already exist.
    - If not, creates new federated credentials using the provided configuration file (`githubactions.json`).

6. **Output**:
    - Outputs the Tenant ID, Subscription ID, and Application Client ID, which are required for configuring the other IDP (e.g., GitHub Actions secrets).

## Troubleshooting

- **Account Not Found**: Ensure you are logged into Azure CLI using `az login`.
- **Application Already Exists**: If an application with the specified name exists, the script will not create a new one. Ensure the application name is unique.
- **Role Already Exists**: If the specified role already exists, the script will not add a new one. Verify the role assignments if needed.
- **Verbose Mode**: Use `--verbose` to get detailed output for debugging purposes.

For further assistance, refer to the [Azure CLI documentation](https://docs.microsoft.com/en-us/cli/azure/) or contact your Azure administrator.