🚧 **UNDER CONSTRUCTION**

# Template IaC Repo for Azure with Terraform and Terragrunt

## Overview

This repository provides a standardized template for provisioning and managing infrastructure in Azure using Terraform. It includes:

- A recommended folder structure for organizing environments and the modules within them.
- CI/CD pipeline templates for automated Terraform workflows with Azure Pipelines.
- A one-time bootstrap process to prepare a new Azure subscription.

## Getting Started

### 1. Bootstrap the Subscription (One-Time)

Before provisioning any environments, you must run the scripts in the `bootstrap/` folder to set up foundational infrastructure such as:

- A VMSS for Azure DevOps agents
- A storage account for Terraform state
- Networking components (subnet, route table, private DNS)

See [bootstrap/README.md](bootstrap/README.md) for full instructions.

Once the basic infrastructure is provisioned, there are a few more prerequisites to obtain before you can provision a full environment. Please see [this confluence page](http://TODO/enter-url-for-the-confluence-page) for step-by-step guidance.

### 2. Enable Pre-Commit Hooks and Security Scan

#### Pre-Commit
This repository includes a .pre-commit-config.yaml file to enforce consistent formatting, linting, and validation before code is committed.

1. Install pre-commit (if not already installed):
    ```Shell
    pip install pre-commit
    ```

2. Install the hooks:
    ```Shell
    pre-commit install
    ```

#### Security Scan
To ensure you follow CPS security policy, you must uncomment the contents of [.github\workflows\security.yml](.github\workflows\security.yml) before provisioning any environments.

### 3. Create and Configure an Environment

1. Each environment (e.g. `dev`, `prod`) should have its own folder under `environments/`, following the structure and naming conventions provided.

2. At the root of every environment folder there must be a terragrunt [root.hcl](environments/dev/root.hcl) file. 

    Add the values of the storage account created via the [bootstrap scripts](#1-bootstrap-the-subscription-one-time) as the Terraform backend.
    ```hcl
      # environments/dev/root.hcl

      config = {
        key                  = "${path_relative_to_include()}/terraform.tfstate" # leave as is
        resource_group_name  = # e.g. "rg-projectname-devops-preprod"
        storage_account_name = # e.g. "sa-projectname-tfstate-dev"
        container_name       = "tfstate" # leave as is
      }
    ```

3. We recommend referencing the modules created for this GitHub organisation to provision resources. _(TODO: add link to module folder)_

### 4. Set Up CI/CD

A set of Azure DevOps pipelines are provided for the dev environment. These can be replicated per environment, and populated with the relevant variable values for each. For example:
```yaml
# azure-pipelines/tg-plan-dev.yml

variables:
  environment: 'dev'
  ado_service_connection: 'preprod-service-connection-name'
  ado_agent_pool: 'preprod-agent-pool-name'
```
You will need to reference these yaml files in the pipelines you create on Azure DevOps.

#### The CI/CD Workflow
1. When code is pushed to any remote branch (except `main`), this should trigger the ['plan'](azure-pipelines/tg-plan-dev.yml) pipeline, which creates a Terraform plan for the new configuration.
2. When a PR is merged to `main`, it triggers the ['apply'](azure-pipelines/tg-plan-dev.yml) pipeline, which executes the Terraform plan.

## Best Practices

- Use remote state storage (created during bootstrap) for all environments.
- Keep secrets and sensitive variables in a secure store (e.g. Azure Key Vault).
- Use consistent naming conventions and tags across resources.
- Review and customize the CI/CD pipeline to match your team’s workflow.

## Contributing

If you're extending this template or improving the pipelines, please follow internal contribution guidelines and open a pull request.
