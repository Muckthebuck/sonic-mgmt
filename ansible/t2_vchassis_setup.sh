#!/bin/bash
# Define the topology variables
TOPOLOGIES=("vms-kvm-t2-min" "vms-kvm-t2-min-1")
TOPO_FILE_PATHS=("$PWD/vars/topo_t2_2lc_min_ports-masic.yml" "$PWD/vars/topo_t2_2lc_min_ports-masic_2.yml")
MAIN_YML_PATH="$PWD/group_vars/vm_host/main.yml"
# set an incrementer
i=-1

# Reset the bridge names
echo "======================================"
echo "Resetting the br-T2Inband, br-T2Midplane, bridge names..."
echo "======================================"
python3 t2_vchassis_modify_br.py reset
python3 t2_vchassis_modify_bp_ip.py $MAIN_YML_PATH --reset
for TOPOLOGY in ${TOPOLOGIES[@]}; do
  i=$((i+1))
  echo "======================================"
  echo "Setting up topology $TOPOLOGY..."
  echo "======================================"
  # Modify the backplane ips based on topo file
  echo "======================================"
  echo "======================================"
  echo "Modifying the backplane IPs for $TOPOLOGY..."
  echo "======================================"
  echo "======================================"
  python3 t2_vchassis_modify_bp_ip.py $MAIN_YML_PATH --topo-file ${TOPO_FILE_PATHS[$i]}

  # Spin up a t2 testbed
  echo "======================================"
  echo "======================================"
  echo "Spinning up a t2 testbed for $TOPOLOGY..."
  echo "======================================"
  echo "======================================"
  ./testbed-cli.sh -t vtestbed.yaml -m veos_vtb -k ceos add-topo $TOPOLOGY password.txt 

  # Initialize the t2 testbed to have chassis-related configuration
  echo "======================================"
  echo "======================================"
  echo "Initializing the t2 testbed to have chassis-related configuration for $TOPOLOGY..."
  echo "======================================"
  echo "======================================"
  ./testbed-cli.sh -m veos_vtb -t vtestbed.yaml -k ceos config-vs-chassis $TOPOLOGY veos_vtb password.txt

  # Deploy the minigraph
  echo "======================================"
  echo "======================================"
  echo "Deploying the minigraph for $TOPOLOGY..."
  echo "======================================"
  echo "======================================"
  ./testbed-cli.sh -t vtestbed.yaml -m veos_vtb deploy-mg $TOPOLOGY veos_vtb password.txt -vvv

  echo "======================================"
  echo "Finished setting up the topology $TOPOLOGY."
  echo "======================================"

  # Increment the bridge names
  python3 t2_vchassis_modify_br.py
done

python3 t2_vchassis_modify_br.py reset
python3 t2_vchassis_modify_bp_ip.py $MAIN_YML_PATH --reset

echo "======================================"
echo "======================================"
echo "All tasks completed."
echo "======================================"
echo "======================================"
