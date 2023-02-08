# CloudInfra
Initial Terraform for the CIROH Cloud 

To build [dockerfile](/docker/Dockerfile) run `docker buildx build -f /docker/Dockerfile --platform=linux/amd64 -t $CONTAINER_NAME .`

and to run the Terraform, run a validate: `terraform validate` and then `terraform plan -o plan.file` and `terraform apply plan.file` and fill out the TF variables. 

variable "aws_region"
"Preferred region in which to launch EC2 instances. Defaults to us-east-1"
default     = "us-east-1"

variable "nameprefix"
description = "Prefix to use for some resource names to avoid duplicates"
default     = "Cloud-Example"

variable "name_tag" 
description = "Value of the Name tag for the EC2 instance"
default     = "Cloud-Example-Terraform"

variable "project_tag"
description = "Value of the Project tag for the EC2 instance"
default     = "Cloud-Example" 

variable "availability_zone"
description = "Availability zone to use"
default     = "us-east-1a"

variable "instance_type" 
description = "[EC2 Instance Type](https://instances.vantage.sh/)"
larger instance = "c5n.18xlarge"
default = "t3.medium"

variable "use_efa"
description = "[Attach EFA Network](https://aws.amazon.com/hpc/efa/)"
default = "true"

variable "key_name" 
description = "The name of the ssh key-pair used to access the EC2 instances"
#default     = "terraform-key.pem"

variable "container_name" 
description = "The name of the conatinerized model to run"
default     = "zwills/dmod_ngen_slim"

variable "ngen_catchment_file"
description = "The path of the catchment file, /mnt is the S3 mount default; then path to examples in the ngen repo"
#default     = "/mnt/ngen/ngen/data/catchment_data.geojson"

variable "ngen_nexus_file"
description = "The path of the nexus file, /mnt is the S3 mount default; examples in the ngen repo"
#default     = "/mnt/ngen/ngen/data/nexus_data.geojson"

variable "ngen_realization_file"
  description = "The path of the ngen realization file, /mnt is the S3 mount default; examples in the ngen repo"
  #default     = "/mnt/ngen/ngen/data/test_bmi_multi_realization_config.json"

variable "allowed_ssh_cidr"
  description = "Public IP address/range allowed for SSH access"

variable "bucket_name"
  description = "S3 Bucket Name for AWS bucket to mount (at /mnt) for data"

variable "public_key"
  description = "Contents of the SSH public key to be used for authentication"

variable "managed_policies"
description = "The attached IAM policies granting machine permissions"
default = ["arn:aws:iam::aws:policy/AmazonEC2FullAccess",
           "arn:aws:iam::aws:policy/AmazonS3FullAccess",
           "arn:aws:iam::aws:policy/AmazonFSxFullAccess"]

variable "ami_id" 
description = "The random ID used for [AMIs](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/finding-an-ami.html)"
default="unknown value"
