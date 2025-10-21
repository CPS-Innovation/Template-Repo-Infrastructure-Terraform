# Azure Subscription Bootstrap: Baseline Infrastructure with Terraform

This directory contains a set of one-time Terraform scripts designed to bootstrap a new Azure subscription with foundational infrastructure. These resources are required before any environment can be provisioned and managed via Terraform.

### Key Components Provisioned

- **Resource Group**: Contains the basic resources required for provisioning environments with Terraform and Azure DevOps.
- **Virtual Machine Scale Set (VMSS)**: Used as a self-hosted agent pool with Azure DevOps.
- **Azure Storage Account(s)**: Serves as the backend for Terraform State management.
- **Networking Components**:
  - **Route Table**: Directs traffic from the Virtual Network to the CPS Hub Network Virtual Appliance.
  - **Subnet**: Provides private IPs for the VMSS and the storage account(s) private endpoint(s).
  - **Private DNS Config**: 
    - Associates the VNet with CPS Hub DNS resolvers.
    - Enables Private Link to the storage account(s) with private endpoints.

## Prerequisites

Before running these scripts, ensure the following are in place:

- Provided by the CPS Cloud Infra team:
  - An active Azure subscription on which you have a Contributor role.
  - A Virtual Network within the subscription.
- [Terraform CLI](https://developer.hashicorp.com/terraform/tutorials/azure-get-started/install-cli) installed locally.
- [Azure CLI](https://learn.microsoft.com/en-us/cli/azure/?view=azure-cli-latest) installed and authenticated.
- SSH key pair, to be used for VMSS access. 
    ```shell
    # Generate a new key pair:
    ssh-keygen -t rsa -b 4096 -f path/to/key/file -N 50mePa55phra5e! # adding a passphrase is optional
    ```

## Usage

1. Work in the bootstrap directory
    ```shell
    cd path/to/bootstrap
   ```

2. Initialize Terraform
    ```Shell
    terraform init
    ```

3. Add variable values:
    - Make a copy of [example.tfvars](bootstrap/example.tfvars) and name it `local.tfvars` - this file name is set to be [ignored by git](.gitignore).
        ```shell
        cp ./example.tfvars ./local.tfvars
        ```
    - Edit `local.tfvars` with required values.
    - Alternatively, use environment variables to provide required values.


5. Apply the configuration
    ```Shell
    terraform apply
    ```

6. Confirm the plan and wait for provisioning to complete.


## Architecture Overview
The Terraform scripts provision the following:

- A VMSS configured with uniform scaling, to enable usage as Azure DevOps agent pool.

- A storage account per environment with a container for storing Terraform state, with an associated private endpoint.

  For a preprod subscription, you may require two (or more) tfstate storage accounts, e.g. for 'dev' and 'staging'.

- Supporting resources such as a subnet, route table, private DNS zone and resource group.

## Notes

- These scripts are intended to be run once per subscription. 
- We recommend you delete any locally generated files once the infrastructure is up and running, e.g. `local.tfvars` and the local `.tfstate` file 
- Ensure proper access control policies are applied post-deployment.
- Once resurces are created, you will need to submit some tickets to the CPS Cloud Infra team, to add DNS entries and Firewall rules. See [this confluence page](http://TODO/enter-url-for-the-confluence-page) for guidance.