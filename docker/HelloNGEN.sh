#!/bin/bash
workdir="${1:-/ngen}"
cd ${workdir}
set -e
echo "Working directory is :" 
pwd
echo -e "\n"

HYDRO_FABRIC_CATCHMENTS=$(find ${workdir} -name "*catchment*.geojson")
HYDRO_FABRIC_NEXUS=$(find ${workdir} -name "*nexus*.geojson")
NGEN_REALIZATIONS=$(find ${workdir} -name "*realization*.json")
#pwd
echo -e "\e[4mFound these Catchment files in ${workdir}:\e[0m" && sleep 1 && echo "$HYDRO_FABRIC_CATCHMENTS"
echo -e "\n"
echo -e "\e[4mFound these Nexus files in ${workdir}:\e[0m" && sleep 1 && echo "$HYDRO_FABRIC_NEXUS"
echo -e "\n"
echo -e "\e[4mFound these Realization files in ${workdir}:\e[0m" && sleep 1 && echo "$NGEN_REALIZATIONS"
echo -e "\n"
generate_partition () {
  # $1 catchment json file
  # $2 nexus json file
  # $3 number of partitions
  /dmod/bin/partitionGenerator $1 $2 partitions_$3.json $3 '' ''
}

PS3="Select an option (type a number): "
options=("Run NextGen model framework in serial mode" "Run NextGen model framework in parallel mode" "Run Bash shell" "Exit")
select option in "${options[@]}"; do
  case $option in
    "Run NextGen model framework in serial mode")
      echo -e "\n"
      read -p "Enter the hydrofabric catchment file path from above: " n1
      echo "$n1 selected"
      read -p "Enter the hydrofabric nexus file path from above: " n2
      echo "$n2 selected"
      read -p "Enter the Realization file path from above: " n3
      echo "$n3 selected"
      echo ""
      echo ""
      echo "Your NGEN run command is /dmod/bin/ngen-serial $n1 \"\" $n2 \"\" $n3"
      break
      ;;
    "Run NextGen model framework in parallel mode")
      echo -e "\n"
      read -p "Enter the hydrofabric catchment file path: " n1
      echo "$n1 selected"
      read -p "Enter the hydrofabric nexus file path: " n2
      echo "$n2 selected"
      read -p "Enter the Realization file path: " n3
      echo "$n3 selected"
      procs=$(nproc)
      procs=2 #for now, just make this 2...
      generate_partition $n1 $n2 $procs
      echo ""
      echo ""
      echo "Your NGEN run command is mpirun -n $procs /dmod/bin/ngen-parallel $n1 \"\" $n2 \"\" $n3 $(pwd)/partitions_$procs.json"
      break
      ;;
    "Run Bash shell")
      echo "Starting a shell, simply exit to stop the process."
      cd ${workdir}
      /bin/bash
      ;;
    "Exit")
      exit 0
      ;;
    *) 
      echo "Invalid option $REPLY"
      ;;
  esac
done
echo "If your model didn't run, or encountered an error, try checking the Forcings paths in the Realizations file you selected."
echo "Your model run is beginning!"
echo ""

case $option in 
  "Run NextGen model in serial mode")
    /dmod/bin/ngen-serial $n1 all $n2 all $n3 
  ;;
  "Run NextGen model in parallel mode")
    mpirun -n $procs /dmod/bin/ngen-parallel $n1 all $n2 all $n3 $(pwd)/partitions_$procs.json
  ;;
esac

echo "Would you like to continue?"
PS3="Select an option (type a number): "
options=("Interactive-Shell" "Copy output data from container to local machine" "Exit")
select option in "${options[@]}"; do
  case $option in
    "Interactive-Shell")
      echo "Starting a shell, simply exit to stop the process."
      cd ${workdir}
      /bin/bash
      break
      ;;
    "Copy output data from container to local machine")
      [ -d /ngen/ngen/data/outputs ] || mkdir /ngen/ngen/data/outputs
      # Loop through all of the .csv files in the /ngen/ngen/data directory
      for i in /ngen/ngen/data/*.csv; do
        # Check if the file exists
        if [[ -f $i ]]; then
          # Move the file to the /ngen/ngen/data/outputs directory
          mv "$i" /ngen/ngen/data/outputs
        fi
      done
      # Loop through all of the .parquet files in the /ngen/ngen/data directory
      for i in /ngen/ngen/data/*.parquet; do
        # Check if the file exists
        if [[ -f $i ]]; then
          # Move the file to the /ngen/ngen/data/outputs directory
          mv "$i" /ngen/ngen/data/outputs
        fi
      done
      # Loop through all of the .json files in the /ngen/ngen/data directory
      for i in /ngen/ngen/data/*.json; do
        # Check if the file exists
        if [[ -f $i ]]; then
          # Move the file to the /ngen/ngen/data/outputs directory
          mv "$i" /ngen/ngen/data/outputs
        fi
      done
      break
      ;;
    "Exit")
      echo "Have a nice day."
      break
      ;;
    *) 
      echo "Invalid option $REPLY"
      ;;
  esac
done
exit
