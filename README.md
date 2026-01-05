# AWS FastAPI App Deployment with Terraform and Ansible

[![Deploy Infrastructure](https://img.shields.io/github/actions/workflow/status/Lavash2310/terrafform_and_ansible_deploy_site/main.yml?branch=main&label=Deploy&style=flat-square)](https://github.com/Lavash2310/terrafform_and_ansible_deploy_site/actions)
[![Terraform](https://img.shields.io/badge/Terraform-1.6.0-623CE4?style=flat-square&logo=terraform&logoColor=white)](https://www.terraform.io/)
[![Ansible](https://img.shields.io/badge/Ansible-2.9+-EE0000?style=flat-square&logo=ansible&logoColor=white)](https://www.ansible.com/)
[![AWS](https://img.shields.io/badge/AWS-Cloud-FF9900?style=flat-square&logo=amazon-aws&logoColor=white)](https://aws.amazon.com/)
[![Python](https://img.shields.io/badge/Python-3.8+-3776AB?style=flat-square&logo=python&logoColor=white)](https://www.python.org/)
[![License](https://img.shields.io/github/license/Lavash2310/terrafform_and_ansible_deploy_site?style=flat-square)](./LICENSE)

This repository contains the infrastructure-as-code and configuration management scripts to automatically provision an AWS environment and deploy a FastAPI web application. The process is orchestrated through a GitHub Actions CI/CD pipeline, leveraging Terraform for infrastructure and Ansible for server configuration.

## Architecture Overview

The project provisions and configures a full-stack application environment on AWS.

*   **Terraform:** Deploys the core AWS infrastructure, including:
    *   A custom VPC with public and private subnets.
    *   An EC2 instance to host the web application.
    *   An IAM Role and Instance Profile granting the EC2 instance permissions to access S3, DynamoDB, and CloudWatch.
    *   Security Groups to control network traffic to the EC2 instance.
    *   A DynamoDB table for application metadata.
    *   A CloudWatch Log Group for centralized application logging.
    *   Remote state management is configured using an S3 bucket and a DynamoDB table for state locking.

*   **Ansible:** Configures the provisioned EC2 instance by executing the following roles:
    *   **common:** Installs base system packages (`python3-venv`, `build-essential`) and sets up a swap file.
    *   **mysql:** Installs MySQL server, creates a database, and configures a user for the application.
    *   **fastapi:**
        *   Sets up a Python virtual environment and installs application dependencies (FastAPI, Uvicorn, Boto3, etc.).
        *   Deploys the FastAPI application source code.
        *   Imports initial data into the MySQL database.
        *   Configures and enables a `systemd` service to run the FastAPI application via Uvicorn.
    *   **nginx:** Installs Nginx and configures it as a reverse proxy to serve the FastAPI application on port 80.

*   **Application:** A Python-based FastAPI web application that provides a CRUD interface for managing employee records.
    *   **Backend:** FastAPI
    *   **Database:** MySQL
    *   **File Storage:** AWS S3 for employee photos.
    *   **Metadata:** AWS DynamoDB for photo details.
    *   **Logging:** AWS CloudWatch for structured logging via the `watchtower` library.

*   **CI/CD (GitHub Actions):**
    *   **`main.yml`:** A comprehensive deployment pipeline triggered on push to the `main` branch. It validates Terraform code, runs a Trivy security scan, provisions infrastructure with Terraform, and then uses a self-hosted runner to execute the Ansible playbook for application deployment and testing.
    *   **`destroy.yml`:** A manually triggered workflow to tear down all AWS resources managed by Terraform.

## Prerequisites

Before you begin, ensure you have the following:
*   An AWS account with programmatic access (Access Key ID and Secret Access Key).
*   A GitHub account.
*   An SSH key pair. The public key will be added to the EC2 instance, and the private key will be used by Ansible.

## Deployment Guide

The primary method for deployment is via the included GitHub Actions workflow.

### 1. Fork and Clone the Repository

Fork this repository to your own GitHub account and then clone it to your local machine.

### 2. Configure GitHub Secrets

For the CI/CD pipeline to authenticate with AWS and configure the server, you must add the following secrets to your forked repository (`Settings > Secrets and variables > Actions > New repository secret`):

*   `AWS_ACCESS_KEY_ID`: Your AWS access key ID.
*   `AWS_SECRET_ACCESS_KEY`: Your AWS secret access key.
*   `SSH_PUBLIC_KEY`: The content of your public SSH key file (e.g., `~/.ssh/id_rsa.pub`).
*   `SSH_PRIVATE_KEY`: The content of your private SSH key file (e.g., `~/.ssh/id_rsa`). This is used by the self-hosted runner for Ansible.
*   `ANSIBLE_VAULT_PASSWORD`: A password of your choice to decrypt `ansible/vars/secrets.yml`.
*   `DB_PASSWORD`: The password you want to set for the `db_user` in the MySQL database.

### 3. Set up a Self-Hosted Runner

The `ansible-deploy` job in the workflow requires a self-hosted runner. This is because it needs access to the `SSH_PRIVATE_KEY` secret to connect to the newly created EC2 instance, and GitHub-hosted runners do not have this capability for security reasons.

Follow the official GitHub documentation to [add a self-hosted runner](https://docs.github.com/en/actions/hosting-your-own-runners/managing-self-hosted-runners/adding-self-hosted-runners) to your repository. No specific labels are required as the workflow targets `self-hosted`.

### 4. Run the Deployment Pipeline

Push a commit to the `main` branch of your forked repository. This will automatically trigger the `Deploy Infrastructure` workflow.

Alternatively, you can manually trigger the workflow:
1.  Go to the **Actions** tab in your repository.
2.  Select the **Deploy Infrastructure** workflow from the sidebar.
3.  Click **Run workflow**.

The pipeline will execute the following stages:
1.  Validate and plan the Terraform deployment.
2.  Run a Trivy security scan on the configuration files.
3.  Apply the Terraform plan to build the AWS infrastructure.
4.  Run the Ansible playbook on the self-hosted runner to configure the EC2 instance.
5.  Perform a simple HTTP test to verify the application is running.

Upon successful completion, the public IP of the web server will be available in the workflow logs.

## Destroying the Infrastructure

To remove all a-ws resources created by this project, you can run the `Destroy Infrastructure` workflow.

1.  Go to the **Actions** tab in your repository.
2.  Select the **Destroy Infrastructure** workflow.
3.  Click **Run workflow** to trigger the teardown process. Terraform will destroy all managed resources.

## Project Structure

```
.
employee-management-infra/
├── .github/
│   └── workflows/
│       ├── main.yml                    # CI/CD pipeline for deployment
│       └── destroy.yml                 # Workflow to destroy infrastructure
│
├── ansible/
│   ├── roles/
│   │   ├── common/                     # System preparation role
│   │   │   └── tasks/
│   │   │       └── main.yml            # Install packages, setup swap
│   │   ├── mysql/                      # MySQL database role
│   │   │   └── tasks/
│   │   │       └── main.yml            # MySQL installation & DB setup
│   │   ├── fastapi/                    # FastAPI application role
│   │   │   ├── files/
│   │   │   │   ├── app.py              # FastAPI application code
│   │   │   │   ├── employees.sql       # Database schema & sample data
│   │   │   │   └── templates/
│   │   │   │       ├── index.html      # Employee list page
│   │   │   │       └── edit.html       # Employee edit page
│   │   │   ├── tasks/
│   │   │   │   └── main.yml            # App deployment tasks
│   │   │   ├── templates/
│   │   │   │   └── fastapi.service.j2  # Systemd service template
│   │   │   └── handlers/
│   │   │       └── main.yml            # Service restart handlers
│   │   └── nginx/                      # Nginx reverse proxy role
│   │       ├── tasks/
│   │       │   └── main.yml            # Nginx installation & config
│   │       └── handlers/
│   │           └── main.yml            # Nginx restart handler
│   ├── vars/
│   │   └── secrets.yml                 # Encrypted secrets (Ansible Vault)
│   ├── playbook.yml                    # Main Ansible playbook
│   ├── ansible.cfg                     # Ansible configuration
│   ├── aws_ec2.yml                     # Ansible dynamic inventory for AWS EC2
│   └── .vscode/
│       └── sftp.json                   # VS Code SFTP configuration
│
├── terraform/
│   ├── compute.tf                      # EC2 instance and key pair resources
│   ├── network.tf                      # VPC, subnets, route tables, IGW
│   ├── security.tf                     # Security groups and rules
│   ├── iam.tf                          # IAM roles and policies for EC2
│   ├── cloudwatch.tf                   # CloudWatch log group
│   ├── backend_setup.tf                # DynamoDB table for the application
│   ├── provider.tf                     # Terraform provider and backend configuration
│   ├── variables.tf                    # Input variables for Terraform
│   └── outputs.tf                      # Output values (EC2 IP, SSH instructions)
│
├── .gitignore                          # Git ignore file
└── README.md                           # Project documentation
