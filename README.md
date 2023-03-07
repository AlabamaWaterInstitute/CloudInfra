# CIROH Cloud Terraform Configuration

This Terraform configuration is used to build and manage resources on the CIROH cloud, including an EC2 instance running a containerized model.

## Docker Build

To build the Dockerfile, run the following command:
```bash
docker buildx build -f /docker/Dockerfile --platform=linux/amd64 -t $CONTAINER_NAME .
```
This is now done by Github Actions automatically, on push to main branch or when Pull Request is created to a branch - `main`.

## Terraform validate

- GitHub Actions will run Terraform init and validate every time a push or pull request is made to a branch - `main`.

** Note that the terraform init command is also included in the workflow. This command initializes the Terraform working directory and downloads the necessary providers and modules. It is required before running terraform validate to ensure that all dependencies are available.

## Terraform Usage

To run the Terraform configuration, follow these steps:

1. Generate a plan file by running terraform plan -o plan.file.
2. Apply the plan file by running terraform apply plan.file and fill out the Terraform variables.

## Terraform Variables
The following variables can be customized:

`aws_region`: The preferred region in which to launch EC2 instances. Defaults to us-east-1.

`nameprefix`: Prefix to use for some resource names to avoid duplicates. Default value is "Cloud-Example".

`name_tag`: Value of the Name tag for the EC2 instance. Default value is "Cloud-Example-Terraform".

`project_tag`: Value of the Project tag for the EC2 instance. Default value is "Cloud-Example".

`availability_zone`: Availability zone to use. Default value is "us-east-1a".

`instance_type`: EC2 Instance Type. Larger instance is "c5n.18xlarge". Default value is "t3.medium".

`use_efa`: Attach EFA Network. Default value is "true".

`key_name`: The name of the ssh key-pair used to access the EC2 instances.

`container_name`: The name of the containerized model to run. Default value is "zwills/dmod_ngen_slim".

`ngen_catchment_file`: The path of the catchment file, /mnt is the S3 mount default; then path to examples in the ngen repo.

`ngen_nexus_file`: The path of the nexus file, /mnt is the S3 mount default; examples in the ngen repo.

`ngen_realization_file`: The path of the ngen realization file, /mnt is the S3 mount default; examples in the ngen repo.

`allowed_ssh_cidr`: Public IP address/range allowed for SSH access.

`bucket_name`: S3 Bucket Name for AWS bucket to mount (at /mnt) for data.

`public_key`: Contents of the SSH public key to be used for authentication.

`managed_policies`: The attached IAM policies granting machine permissions. Default value is ["arn:aws:iam::aws:policy/AmazonEC2FullAccess", "arn:aws:iam::aws:policy/AmazonS3FullAccess", "arn:aws:iam::aws:policy/AmazonFSxFullAccess"].

`ami_id`: The random ID used for AMIs. Default value is "unknown value".
