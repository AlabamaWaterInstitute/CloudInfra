#!/bin/bash

set -e
echo "Working directory is " 
pwd
HYDRO_FABRIC_CATCHMENTS=$(find /ngen -name "*catchment*.geojson")
HYDRO_FABRIC_NEXUS=$(find /ngen -name "*nexus*.geojson")
NGEN_REALIZATIONS=$(find /ngen -name "*realization*.json")
#pwd
echo -e "\e[4mFound these Catchment files:\e[0m" && sleep 1 && echo "$HYDRO_FABRIC_CATCHMENTS"
echo -e "\e[4mFound these Nexus files:\e[0m" && sleep 1 && echo "$HYDRO_FABRIC_NEXUS"
echo -e "\e[4mFound these Realization files:\e[0m" && sleep 1 && echo "$NGEN_REALIZATIONS"

select opt in ngen-parallel ngen-serial bash quit; do

  case $opt in
    ngen-parallel)
      read -p "Enter the hydrofabric catchment file path: " n1
      echo "$n1 selected"
      read -p "Enter the hydrofabric nexus file path: " n2
      echo "$n2 selected"
      read -p "Enter the Realization file path: " n3
      echo "$n3 selected"
      echo ""
      echo ""
      echo "Your NGEN run command is $opt $n1 \"\" $n2 \"\" $n3"
      echo "Copy and paste it into the terminal to run your model."
      break
      ;;
    ngen-serial)
      read -p "Enter the hydrofabric catchment file path: " n1
      echo "$n1 selected"
      read -p "Enter the hydrofabric nexus file path: " n2
      echo "$n2 selected"
      read -p "Enter the Realization file path: " n3
      echo "$n3 selected"
      echo ""
      echo ""
      echo "Your NGEN run command is /dmod/bin/$opt $n1 \"\" $n2 \"\" $n3"
      echo "Copy and paste it into the terminal to run your model."
      break
      ;;
    bash)
      echo "Starting a shell, simply exit to stop the process."
      /bin/bash
      ;;
    bash)
      exit
      ;;
    *) 
      echo "Invalid option $REPLY"
      ;;
  esac
done
echo "The tested model is /dmod/bin/ngen-serial /ngen/data/catchment_data.geojson "" /ngen/data/nexus_data.geojson "" /ngen/ngen/data/example_realization_config.json"
echo "If your model didn't run, or encountered an error, try checking the Forcings paths in the Realizations file you selected."
echo ""
echo "Your model run is beginning!"
echo ""
/dmod/bin/$opt $n1 \"\" $n2 \"\" $n3 
echo "Would you like to continue?"
select interact in interactive-shell exit; do

  case $interact in
    interactive-shell)
      echo "Starting a shell, simply exit to stop the process."
      /bin/bash
      break
      ;;
    exit)
      echo "Have a nice day."
      break
      ;;
    quit)
      break
      ;;
    *) 
      echo "Invalid option $REPLY"
      ;;
  esac
done
exit
