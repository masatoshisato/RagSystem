## ShowAzAccount.yml

This YAML file is used for displaying the Azure account information in a GitHub Actions workflow.

### Usage

To use this workflow, follow these steps:

1. Create a new workflow file in your repository's `.github/workflows` directory, named `ShowAzAccount.yml`.
2. Copy the content of the `ShowAzAccount.yml` and paste into your yaml file.

3. Commit and push the changes to your repository.

### Explanation

This workflow is triggered on every push to the `main` branch. It runs on the latest version of Ubuntu and performs the following steps:

1. Sets up the Azure CLI and login to Azure by using the `azure/login@v1` action.
2. Displays the Azure account information by running the `az account show` command.

This workflow can be useful for verifying to authenticate to Azure with federated identity credentials with OIDC used in your GitHub Actions workflows.
Don't forget that sets 3 Azure IDs into Github Actions secrets.