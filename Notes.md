This file contains some notes used by @mgdenno to get NextGen running in my 
AWS account. Your mileage may very.

# Clone Repo
`git clone https://github.com/AlabamaWaterInstitute/CloudInfra.git`

# Generate ssh key pairs
`ssh-keygen -t rsa -f ~/.ssh/ngen_aws_key -C ngen_aws_key -b 2048`
The content of `ngen_aws_key` should be used as the 

# SSH connection to EC2 VM (pulling IP from terraform)
`ssh ec2-user@$(terraform output -raw aws_instance_public_ip)`

# S3 Bucket
Terraform does not create an S3 bucket.  You must create this on 
your own. Provide the  name of the bucket to terraform 
after `terraform apply`

There are two steps to this. 1) you need to mount the EC2 instance to the
S3 bucket, 2) you need to mount the docker container to the EC2 directory 
mounted to the S3 bucket.

You also need to move data to the bucket. 

One approach when just getting started is to run `ngen` in the container 
using some of the provided examples and the copy the resulting output over 
to S3 for inspection. If `docker run` is run with a volume mount flag 
`-v /mnt/ngen/ngen:/mnt/ngen/ngen` then you can copy the files over to S3 
from within the interactive shell in the docker container like:
Outputs: `cp cat-* /mnt/ngen/ngen/` `cp nex-* /mnt/ngen/ngen/` 
Inputs: `cp -r data /mnt/ngen/ngen/`

From here you can view the model inputs.outputs in S3 and/or modify them 
in S3 and run them from there by changing the paths when you call 
`docker run` ort use the interactive shell.

Another option would be to copy the test inputs from the OWP/ngen GitHub repo
to the S3 bucket.

There are a few different paths here depending on whether you are just testing 
it out or setting up and running "real runs".  For now it seems you just need 
to dive in and understand the way that buckets/paths/etc. work.

# Troubleshooting Init Script
The script at `CloudInfra/terraform/script.tftpl` is populated by Terraform and 
run on the EC2 instance.
The logs when it is run are at `/var/log/cloud-init-output.log`
The populated script is at `/var/lib/cloud/instance/scripts/part-001`
