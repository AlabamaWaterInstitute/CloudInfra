# Welcome to NextGen Framework National Water Model Community Repo. (NextGen In A Box).

This repository contains :
- Dockerfile for running NextGen Framework (docker/Dockerfile)
- Terraform configuration files for provisioning infrastructure in AWS (terraform/README.md)
- Documentation of how to use the infrastructure and run the model. (README.md)

## Clone the repo

`git clone https://github.com/AlabamaWaterInstitute/CloudInfra.git`

## Prerequisites:

1. Install docker in local machine and docker deamon is running.
2. Download the input data in "ngen-data" folder under $PATH (any location in local machine) :
    - Download input data from S3 bucket:

        $ mkdir ngen-data

        $ cd ngen-data

        $ `wget --no-parent https://ciroh-ua-ngen-data.s3.us-east-2.amazonaws.com/AWI-001/AWI_03W_113060_001.tar.gz` 
        OR
        Use browser to download the data from https://ciroh-ua-ngen-data.s3.us-east-2.amazonaws.com/AWI-001/AWI_03W_113060_001.tar.gz

     - Untar:
        $ tar -xvf AWI_03W_113060_001.tar.gz
        
     - Copy the path from below command:
        $ pwd

## Run the script:

### Guide.sh - Bash script that is used to run the NGEN model. 

1.	The script first prompts for entering the Input data directory file path where forcings and config files are stored. (Prerequisites Step#2 - copied path)

2.	It sets the provided directory to `HOST_DATA_PATH` variable and use it. It then uses the find command to find all of the catchment, nexus, and realization files in the working directory.

3.	It will then ask for option to `run_NextGen` or exit. If run_NextGen is selected, then based on the local machine’s architecture, the script pulls the related image from awiciroh Dockerhub. 

-	For Mac (arm architecture), it pulls `awiciroh/ciroh-ngen-image:latest-arm`
-	For x86 machines, it pulls `awiciroh/ciroh-ngen-image:latest-x86`

4.	It then prompts the user to select whether they want to run the model in parallel or serial mode. If the user selects parallel mode, the script uses the mpirun command to run the model. The script generates a partition file for the NGEN model. 
It then prompts the user to select the catchment, nexus, and realization files that they want to use.

    e.g for parallel run:
    NGEN run command is `mpirun -n 2 /dmod/bin/ngen-parallel /ngen/ngen/data/config/catchments.geojson "" /ngen/ngen/data/config/nexus.geojson "" /ngen/ngen/data/config/awi_simplified_realization.json /ngen/partitions_2.json Your NGEN run command is mpirun -n 2 /dmod/bin/ngen-parallel /ngen/ngen/data/config/catchments.geojson "" /ngen/ngen/data/config/nexus.geojson "" /ngen/ngen/data/config/awi_simplified_realization.json /ngen/partitions_2.json`

5.	If the user selects serial mode, the script runs the model directly. 

    e.g for serial run:
    NGEN run command is `/dmod/bin/ngen-serial /ngen/ngen/data/config/catchments.geojson "" /ngen/ngen/data/config/nexus.geojson "" /ngen/ngen/data/config/awi_simplified_realization.json`

6.	After the model has run, the script prompts the user whether they want to continue. If the user selects yes, the script opens an interactive shell. If the user selects no, the script exits. 

7.	The output files get copied to the `“outputs”` folder in HOST_DATA_PATH.


