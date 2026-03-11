# Azure Subscription Bootstrap: Baseline Infrastructure with Terraform

This directory contains a set of one-time Terraform scripts designed to bootstrap a new Azure subscription with foundational infrastructure. These resources are required before any environment can be provisioned and managed via Terraform.

### Key Components Provisioned

- **Resource Groups**: Contain the basic resources required for provisioning environments with Terraform and Azure DevOps.
- **Virtual Machine Scale Set (VMSS)**: Used as a self-hosted agent pool with Azure DevOps.
- **Azure Storage Account(s)**: Serves as the backend for Terraform State management.
- **Networking Components**:
  - **Virtual Network**
  - **Subnet**: Provides private IPs for the VMSS and the storage account(s) private endpoint(s).
  - **Route Table**: Directs traffic from the Virtual Network to the CPS Hub Network Virtual Appliance.
  - **Private DNS Config**: 
    - Associates the VNet with CPS Hub DNS resolvers.
    - Enables Private Link to the storage account(s) with private endpoints.

## Prerequisites

Before running these scripts, ensure the following are in place:

- Provided by the CPS Cloud Infra team:
  - An active **Azure Subscription** on which you have a **Contributor role**.
  - A **Virtual Network** in the subscription OR an **allocated IP range** for provisioning a Virtual Network.
- Provided by the Applications Operations team:
  - An **Azure App Registration** with a **Secret Credential**.
  - A **Contributor role assignment for the App Registration's Service Principal** (Enterprise App) at the subscription's scope. The service principal will be used for deploying resources to the subscription.
- [Terraform CLI v1.11.4](https://developer.hashicorp.com/terraform/tutorials/azure-get-started/install-cli) installed locally.
- [Azure CLI](https://learn.microsoft.com/en-us/cli/azure/?view=azure-cli-latest) installed and authenticated.
- An SSH key pair, to be used for VMSS access. 
    ```bash
    # Generate a new key pair:
    ssh-keygen -t rsa -b 4096 -f path/to/key/file -N 50mePa55phra5e! # adding a passphrase is optional
    ```

## Usage

1. Work in the bootstrap directory
    ```bash
    cd path/to/bootstrap
   ```

2. Add your [prerequisit](#prerequisites) Service Principal details to the environment:
    ```bash
    export ARM_TENANT_ID=<your tenant ID>
    export ARM_SUBSCRIPTION_ID=<your subscription ID>
    export ARM_CLIENT_ID=<The Client ID of your App Reg>
    export ARM_CLIENT_SECRET=<The secret value of the App Reg credential>
    ```

3. Initialize Terraform
    ```bash
    terraform init
    ```

4. Add variable values:
    - Make a copy of [local.tfvars.example](bootstrap/local.tfvars.example) and name it `local.tfvars` - this file name is set to be [ignored by git](.gitignore).
        ```bash
        cp ./local.tfvars.example ./local.tfvars
        ```

    - Edit `local.tfvars` with required values.

    - **Please note:** some variables must be set to `null`, depending on whether you need to provision a VNet using these scripts, or your subscription has already been provisioned with one. These have been commented on for clarity in [variables.tf](bootstrap/variables.tf) and [local.tfvars.example](bootstrap/local.tfvars.example).

5. Apply the configuration:
    ```bash
    terraform apply --var-file local.tfvars
    ```

6. Confirm the plan and wait for provisioning to complete.


## Architecture Overview
The Terraform scripts provision the following:

- A VMSS configured with uniform scaling, to enable usage as Azure DevOps agent pool.

- A storage account per environment with a container for storing Terraform state, with an associated private endpoint.

  For a preprod subscription, you may require two (or more) tfstate storage accounts, e.g. for 'dev' and 'staging'.

- Networking resources: a virtual network, subnet, route table, private DNS zone.


## Notes

- These scripts are intended to be run once per subscription. 
- We recommend you delete any locally generated files once the infrastructure is up and running, e.g. `local.tfvars` and the local `.tfstate` file 
- Ensure proper access control policies are applied post-deployment.
- Once resurces are created, you will need to submit some firewall rule tickets to the CPS Cloud Infra team, to enable access to your resources. See [this confluence page](http://TODO/enter-url-for-the-confluence-page) for guidance.