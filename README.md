# Kafka Deployment on Azure Using Ansible roles and Terraform

This repository contains the necessary configuration to deploy Apache Kafka on Azure using Ansible and Terraform. You can follow these instructions to deploy Kafka on Azure either using an Ubuntu machine or Windows Subsystem for Linux (WSL).
The project is managed using two methods: the first involves multiple virtual machines with public IPs, and the second uses private IPs.

## Prerequisites

Ensure the following tools are installed on your machine:

- **Azure CLI**
- **Terraform**
- **jq**
- **Ansible**



## Azure Authentication and Configuration

1. Login to your Azure account via the CLI:

    ```bash
    az login
    ```
This will prompt you to authenticate through a browser.


2. Set subscription and tenant IDs

The subscription and tenant IDs are required to execute Terraform for Azure. There are two methods to configure them:
* Set environment variables, as shown below:
    ```bash
    export ARM_SUBSCRIPTION_ID=xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx
    export ARM_TENANT_ID=xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx
    ```

* Set them directly in the provider.tf file, as shown below:
    ```hcl
    provider "azurerm" {
    features = {}
    subscription_id = "<YOUR_SUBSCRIPTION_ID>"
    tenant_id       = "<YOUR_TENANT_ID>"
    }
    ```

## Terraform Setup

1. Initialize Terraform
Run the following command to initialize Terraform and download the necessary provider plugins:

    ```bash
    cd kafka_setup_terraform
    terraform init
    ```

2. Apply Terraform Configuration
Once the initialization is complete, apply the configuration to provision resources on Azure:

    ```bash
    terraform apply
    ```

This will create the necessary resources for your Kafka deployment on Azure. Review the plan and confirm by typing yes.

## Automated Kafka Deployment

After running terraform apply, the infrastructure will be provisioned automatically, and the Kafka installation and configuration will begin immediately. The entire process is automated via Terraform, which triggers Ansible dynamically.

Here’s how it works:

* Terraform provisions the infrastructure (e.g., virtual machines, networking, etc.).
* Once the provisioning is complete, the inventory_script_hosts.sh script is executed through terraform's triggers. This script detects the public IPs of the created instances and automatically updates the hosts file.
* Ansible is invoked from within Terraform to automatically configure and install Kafka on the newly provisioned VMs.

This eliminates the need to manually trigger any Ansible playbooks and ensures a seamless, automated deployment process.

PS: The number of virtual machines is configured in the vmss.tf file (2 instances by default). This can be modified, and the deployment will still succeed regardless of the number of instances configured, as long as the allowed maximum number of public IP addresses is not exceeded.

# Conclusion
After executing terraform apply, Kafka will be fully deployed and configured on your Azure environment. You can now interact with your Kafka instances.
