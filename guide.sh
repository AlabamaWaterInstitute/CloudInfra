#!/bin/bash

# Bold
BBlack='\033[1;30m'       # Black
BRed='\033[1;31m'         # Red
BGreen='\033[1;32m'       # Green
BYellow='\033[1;33m'      # Yellow
BBlue='\033[1;34m'        # Blue
BPurple='\033[1;35m'      # Purple
BCyan='\033[1;36m'        # Cyan
BWhite='\033[1;37m'       # White

# Underline
UBlack='\033[4;30m'       # Black
URed='\033[4;31m'         # Red
UGreen='\033[4;32m'       # Green
UYellow='\033[4;33m'      # Yellow
UBlue='\033[4;34m'        # Blue
UPurple='\033[4;35m'      # Purple
UCyan='\033[4;36m'        # Cyan
UWhite='\033[4;37m'       # White

# Reset
Color_Off='\033[0m'       # Text Reset


set -e

echo -e "${UWhite}Welcome to CIROH-UA : Nextgen National Water Model guide!${Color_Off}"

echo -e "Looking for a directory containing the following directories: forcings outputs config"
echo -e "${BBlue}forcings${Color_Off} is the input data for your model(s)."
echo -e "${BPurple}outputs${Color_Off} is where we'll put your data when it's finished running"
echo -e "${BGreen}config${Color_Off} is where changes to models can be made"
echo -e "\n"
echo -e "Make sure to use an absolute path."
read -p "Enter your data directory file path: " HOST_DATA_PATH

echo -e "The Directory you've given is:" && echo "$HOST_DATA_PATH"

Outputs_Count=$(ls $HOST_DATA_PATH/outputs | wc -l)


#Validate paths exist:
[ -d "$HOST_DATA_PATH/forcings" ] && echo -e "${BBlue}forcings${Color_Off} exists. $(ls $HOST_DATA_PATH/forcings | wc -l) forcings found." || echo -e "Error: Directory $HOST_DATA_PATH/${BBlue}forcings${Color_Off} does not exist."
[ -d "$HOST_DATA_PATH/outputs" ] && echo -e "${BPurple}outputs${Color_Off} exists. $(ls $HOST_DATA_PATH/outputs | wc -l) outputs found." || echo -e "Error: Directory $HOST_DATA_PATH/${BPurple}outputs${Color_Off} does not exist." 
[ -d "$HOST_DATA_PATH/config" ] && echo -e "${BGreen}config${Color_Off} exists. $(ls $HOST_DATA_PATH/config | wc -l) configs found." || echo -e "Error: Directory $HOST_DATA_PATH/${BGreen}config${Color_Off} does not exist."

echo "Looking in the provided directory gives us:" 

HYDRO_FABRIC_CATCHMENTS=$(find $HOST_DATA_PATH -iname "*catchment*.geojson")
HYDRO_FABRIC_NEXUS=$(find $HOST_DATA_PATH -iname "*nexus*.geojson")
NGEN_REALIZATIONS=$(find $HOST_DATA_PATH -iname "*realization*.json")
#pwd
echo -e "${UGreen}Found these Catchment files:${Color_Off}" && sleep 1 && echo "$HYDRO_FABRIC_CATCHMENTS"
echo -e "${UGreen}Found these Nexus files:${Color_Off}" && sleep 1 && echo "$HYDRO_FABRIC_NEXUS"
echo -e "${UGreen}Found these Realization files:${Color_Off}" && sleep 1 && echo "$NGEN_REALIZATIONS"

#Detect Arch
AARCH=$(uname -a)
echo -e "Detected ISA = $AARCH" 
if docker --version ; then
	echo "Docker found"
else 
	echo "Docker not found"
	break
fi 

select modelrun in run_NextGen exit; do

  case $modelrun in
    run_NextGen)
      echo "Pulling and running AWI NextGen Image"
      break
      ;;
    exit)
      echo "Have a nice day."
      exit 0
      ;;
    *) 
      echo "Invalid option $REPLY, 1 to continue and 2 to exit"
      ;;
  esac
done


if uname -a | grep arm64 ; then

docker pull awiciroh/ciroh-ngen-image:latest-arm
echo -e "pulled arm ngen image"
IMAGE_NAME=awiciroh/ciroh-ngen-image:latest-arm
else

docker pull awiciroh/ciroh-ngen-image:latest-x86
echo -e "pulled x86 ngen image"
IMAGE_NAME=awiciroh/ciroh-ngen-image:latest-x86
fi

echo -e "Running docker with local host mounting $HOST_DATA_PATH to /ngen/ngen/data within the container."
docker run --rm -it -v $HOST_DATA_PATH:/ngen/ngen/data $IMAGE_NAME

Final_Outputs_Count=$(ls $HOST_DATA_PATH/outputs | wc -l)

count=$((Final_Outputs_Count-Outputs_Count))
echo -e "$count new outputs created."

echo -e "Have a nice day!"
