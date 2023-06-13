# Welcome to NextGen Framework National Water Model Community Repo. (NextGen In A Box).

``` diff
- NOTE: This repository has been moved to it's new location : https://github.com/CIROH-UA/CloudInfra
- Please do all active work on : https://github.com/CIROH-UA/CloudInfra
- This repository has been archived and made Read Only.
```

====================================================================================================

This repository contains :
- **Dockerfile** for running NextGen Framework (docker/Dockerfile)
- **Terraform** configuration files for provisioning infrastructure in AWS (terraform/README.md)
- Documentation of how to use the **infrastructure** and run the model. (README.md)

## Table of Contents
* [Prerequisites:](#prerequisites-)
    + [Install docker:](#install-docker-)
    + [Download the input data in "ngen-data" folder from S3 bucket :](#download-the-input-data-in--ngen-data--folder-from-s3-bucket--)
      - [Linux & Mac](#linux---mac)
      - [Windows Steps:](#windows-steps-)
  * [Run NextGen-In-A-Box](#run-nextgen-in-a-box)
    + [Clone CloudInfra repo](#clone-cloudinfra-repo)
    + [How to run the model script?](#how-to-run-the-model-script-)
    + [Output of the model script](#output-of-the-model-script)


## Prerequisites:

### Install docker:
    - On *Windows*:
        - [Install Docker Desktop on Windows](https://docs.docker.com/desktop/install/windows-install/#install-docker-desktop-on-windows)
        - Once docker is installed, start Docker Destop.
        - Open powershell -> right click and `Run as an Administrator` 
        - Type `docker ps -a` to make sure docker is working.
    
    - On *Mac*:
        - [Install docker on Mac](https://docs.docker.com/desktop/install/mac-install/) 
        - Once docker is installed, start Docker Desktop.
        - Open terminal app
        - Type `docker ps -a` to make sure docker is working.
        
    - On *Linux*:
        - [Install docker on Linux](https://docs.docker.com/desktop/install/linux-install/)
        - Follow similar steps as *Mac* for starting Docker and verifying the installation
    
### Download the input data in "ngen-data" folder from S3 bucket :

#### Linux & Mac

```Linux   
    $ mkdir NextGen
    $ cd NextGen
    $ mkdir ngen-data
    $ cd ngen-data
    $ wget --no-parent https://ciroh-ua-ngen-data.s3.us-east-2.amazonaws.com/AWI-001/AWI_03W_113060_001.tar.gz
    $ tar -xf AWI_03W_113060_001.tar.gz 
    $ cd AWI_03W_113060_001
```


#### Windows Steps:
```Windows
    Use browser to download the data from https://ciroh-ua-ngen-data.s3.us-east-2.amazonaws.com/AWI-001/AWI_03W_113060_001.tar.gz
   
    $ mkdir NextGen
    $ cd NextGen
    $ mkdir ngen-data
    $ cd ngen-data
    $ Open browser and download data from here: https://ciroh-ua-ngen-data.s3.us-east-2.amazonaws.com/AWI-001/AWI_03W_113060_001.tar.gz
    and copy the downloaded file to ngen-data folder.
    Use WinRAR to extract the files from the tar bundle.
    $ cd AWI_03W_113060_001
```

## Run NextGen-In-A-Box

### Clone CloudInfra repo

Clone the repo using below commands:
```
$ cd NextGen  
$ git clone https://github.com/AlabamaWaterInstitute/CloudInfra.git

$ cd CloudInfra
```  
Once you are in *CloudInfra* directory, you should see `guide.sh` in it. Now, we are ready to run the model using that script. 

### How to run the model script?

Follow below steps to run `guide.sh` script 
```
    # Note: Make sure you are in ~/Documents/NextGen/CloudInfra directory
    $ ./guide.sh   
    
```

### Output of the model guide script

>*What you will see when you run above `guide.sh`?*

- The script prompts the user to enter the file path for the input data directory where the forcing and config files are stored. 

Run the following command based on your OS and copy the path value:

 **Windows:**
```
C:> cd ~\<path>\NextGen\ngen-data
c:> pwd
and copy the path
```

 **Linux/Mac:**
```
$ cd ~/<path>/NextGen/ngen-data
$ pwd
and copy the path

```
where <path> is the localtion of NextGen folder.
    
- The script sets the entered directory as the `HOST_DATA_PATH` variable and uses it to find all the catchment, nexus, and realization files using the `find` command.
- Next, the user is asked whether to run NextGen or exit. If `run_NextGen` is selected, the script pulls the related image from the awiciroh Dockerhub, based on the local machine's architecture:
```
For Mac (arm architecture), it pulls awiciroh/ciroh-ngen-image:latest-arm.
For x86 machines, it pulls awiciroh/ciroh-ngen-image:latest-x86.
```

- The user is then prompted to select whether they want to run the model in parallel or serial mode.
- If the user selects parallel mode, the script uses the `mpirun` command to run the model and generates a partition file for the NGEN model.
- If the user selects the catchment, nexus, and realization files they want to use.

Example NGEN run command for parallel mode: 
```
mpirun -n 2 /dmod/bin/ngen-parallel 
/ngen/ngen/data/config/catchments.geojson "" 
/ngen/ngen/data/config/nexus.geojson "" 
/ngen/ngen/data/config/awi_simplified_realization.json 
/ngen/partitions_2.json
```
- If the user selects serial mode, the script runs the model directly.

Example NGEN run command for serial mode: 
```
/dmod/bin/ngen-serial 
/ngen/ngen/data/config/catchments.geojson "" 
/ngen/ngen/data/config/nexus.geojson "" 
/ngen/ngen/data/config/awi_simplified_realization.json
```
- After the model has finished running, the script prompts the user whether they want to continue.
- If the user selects yes, the script opens an interactive shell. If the user selects no, the script exits.

The output files are copied to the `outputs` folder in `HOST_DATA_PATH`.
