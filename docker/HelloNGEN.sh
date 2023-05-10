#!/bin/bash
workdir="${1:-/ngen}"
cd ${workdir}
set -e
echo "Working directory is " 
pwd

HYDRO_FABRIC_CATCHMENTS=$(find ${workdir} -name "*catchment*.geojson")
HYDRO_FABRIC_NEXUS=$(find ${workdir} -name "*nexus*.geojson")
NGEN_REALIZATIONS=$(find ${workdir} -name "*realization*.json")
#pwd
echo -e "\e[4mFound these Catchment files in ${workdir}:\e[0m" && sleep 1 && echo "$HYDRO_FABRIC_CATCHMENTS"
echo -e "\e[4mFound these Nexus files in ${workdir}:\e[0m" && sleep 1 && echo "$HYDRO_FABRIC_NEXUS"
echo -e "\e[4mFound these Realization files in ${workdir}:\e[0m" && sleep 1 && echo "$NGEN_REALIZATIONS"

generate_partition () {
  # $1 catchment json file
  # $2 nexus json file
  # $3 number of partitions
  /dmod/bin/partitionGenerator $1 $2 partitions_$3.json $3 '' ''
}

select opt in ngen-parallel ngen-serial bash quit; do

  case $opt in
    ngen-parallel)
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
      echo "Your NGEN run command is mpirun -n $procs /dmod/bin/$opt $n1 \"\" $n2 \"\" $n3 $(pwd)/partitions_$procs.json"
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
      cd ${workdir}
      /bin/bash
      ;;
    quit)
      exit
      ;;
    *) 
      echo "Invalid option $REPLY"
      ;;
  esac
done
echo "The tested model is /dmod/bin/ngen-serial /ngen/data/catchment_data.geojson "" /ngen/data/nexus_data.geojson "" /ngen/ngen/data/example_realization_config.json"
echo "If your model didn't run, or encountered an error, try checking the Forcings paths in the Realizations file you selected."
echo "Your model run is beginning!"
echo ""

case $opt in 
  ngen-parallel)
    mpirun -n $procs /dmod/bin/$opt $n1 all $n2 all $n3 $(pwd)/partitions_$procs.json
  ;;
  ngen-serial)
    /dmod/bin/$opt $n1 all $n2 all $n3
  ;;
esac

echo "Would you like to continue?"
select interact in interactive-shell copy_data exit; do

  case $interact in
    interactive-shell)
      echo "Starting a shell, simply exit to stop the process."
      cd ${workdir}
      /bin/bash
      break
      ;;
    copy_data)
      [ -d /ngen/ngen/data/outputs ] || mkdir /ngen/ngen/data/outputs
      for i in /ngen/ngen/data/*.csv; do mv "$i" /ngen/ngen/data/outputs; done
      for i in /ngen/ngen/data/*.json; do mv "$i" /ngen/ngen/data/outputs; done
      for i in /ngen/ngen/data/*.parquet; do mv "$i" /ngen/ngen/data/outputs; done
#      [ -e /ngen/ngen/data/*.json ] || mv /ngen/ngen/data/*.json /ngen/ngen/data/outputs
#      [ -e /ngen/ngen/data/*.parquet ] || mv /ngen/ngen/data/*.parquet /ngen/ngen/data/outputs
      break
      ;;
    exit)
      echo "Have a nice day."
      break
      ;;
    *) 
      echo "Invalid option $REPLY"
      ;;
  esac
done
exit
