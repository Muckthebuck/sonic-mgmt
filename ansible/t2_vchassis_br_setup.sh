#!/bin/bash

# run this script on the host machine

# Define all configuration sets as arrays
PREFIX="29"
IPV6_PREFIX="126"
declare -a CONFIGS


CONFIGS+=(
'BRIDGE_NAME="br5"
BR_VETH_INTERFACE="veth35"
CEOS_DEVICE_NAME="ARISTA01T3"
CEOS_CONTAINER_NAME="ceos_vms6-4-m_VM0100"
nCEOS_CONTAINER_NAME="ceos_vms6-4-n_VM0109"
NET_CONTAINER_NAME="net_vms6-4-m_VM0100"
CEOS_VETH_INTERFACE="35"
CEOS_IPv4="10.0.1.28"
CEOS_IPv6="FC01::5e"
CEOS_ASN="65200"
nCEOS_ASN="65201"
CEOS_n_T2_IPV6="FC00::1"
VM_NAME="vlab-t2-01"
VM_HOST_INTERFACE="vlab-t2-01-13"
VM_ANSIBLE_IP="10.250.0.120"
VM2_ANSIBLE_IP="10.250.0.121"
VM_ANSIBLE_P="password"
VM_INTERFACE="Ethernet88"
VM_ASIC="0"
VM_IPv4="10.0.1.27"
VM_IPv6="FC01::5d"
VM_ASN="65101"
VM_INT_fix = "Ethernet56"
VM_INT_fix_IPv6 = "FC01::9/126"
VM_INT_fix_IP6_ROUTE = "FC01::8/126"
AGGREGATE_PREFIX="fc01::/64"	
AGGREGATE_PREFIX_N="fc00::/64"
ANCHOR_PREFIX="fc01::/48"	
APPLY_ANCHOR_ROUTE=1'
)
# 65201 -> other T3 , and 601# are T1s
#ANCHOR_PREFIX="2064:200::/48"
#AGGREGATE_PREFIX="2064:200::/64"	
CONFIGS+=(
'BRIDGE_NAME="br5"
BR_VETH_INTERFACE="veth36"
CEOS_DEVICE_NAME="ARISTA13T3"
CEOS_CONTAINER_NAME="ceos_vms6-4-n_VM0109"
nCEOS_CONTAINER_NAME="ceos_vms6-4-m_VM0100"
NET_CONTAINER_NAME="net_vms6-4-n_VM0109"
CEOS_VETH_INTERFACE="36"
CEOS_IPv4="10.0.0.26"
CEOS_IPv6="FC00::4e"
CEOS_ASN="65201"
nCEOS_ASN="65200"
CEOS_n_T2_IPV6="FC01::9"
VM_NAME="vlab-t2-03"
VM_HOST_INTERFACE="vlab-t2-03-12"
VM_ANSIBLE_IP="10.250.0.123"
VM2_ANSIBLE_IP="10.250.0.124"
VM_ANSIBLE_P="password"
VM_INTERFACE="Ethernet80"
VM_ASIC="0"
VM_IPv4="10.0.0.25"
VM_IPv6="FC00::4d"
VM_ASN="65100"
VM_INT_fix = "Port-Channel102"
VM_INT_fix_IPv6 = "FC01::1/126"
VM_INT_fix_IP6_ROUTE = "FC01::/126"
AGGREGATE_PREFIX="fc00::/64"	
AGGREGATE_PREFIX_N="fc01::/64"	
ANCHOR_PREFIX="fc00::/48"
APPLY_ANCHOR_ROUTE=0'
)


# CONFIGS+=(
# 'BRIDGE_NAME="br6"
# BR_VETH_INTERFACE="veth25"
# CEOS_DEVICE_NAME="ARISTA04T3"
# CEOS_CONTAINER_NAME="ceos_vms6-4-m_VM0102"
# nCEOS_CONTAINER_NAME="ceos_vms6-4-n_VM0111"
# NET_CONTAINER_NAME="net_vms6-4-m_VM0102"
# CEOS_VETH_INTERFACE="35"
# CEOS_IPv4="10.0.1.34"
# CEOS_IPv6="FC01::6e"
# CEOS_ASN="65200"
# nCEOS_ASN="65201"
# CEOS_n_T2_IPV6="FC00::1"
# VM_NAME="vlab-t2-01"
# VM_HOST_INTERFACE="vlab-t2-01-34"
# VM_ANSIBLE_IP="10.250.0.120"
# VM2_ANSIBLE_IP="10.250.0.121"
# VM_ANSIBLE_P="password"
# VM_INTERFACE="Ethernet232"
# VM_ASIC="1"
# VM_IPv4="10.0.1.33"
# VM_IPv6="FC01::6d"
# VM_ASN="65101"
# AGGREGATE_PREFIX="fc01::/64"	
# AGGREGATE_PREFIX_N="fc00::/64"
# ANCHOR_PREFIX="fc01::/48"	
# APPLY_ANCHOR_ROUTE=1'
# )
# 65201 -> other T3 , and 601# are T1s
#ANCHOR_PREFIX="2064:200::/48"
#AGGREGATE_PREFIX="2064:200::/64"	
# CONFIGS+=(
# 'BRIDGE_NAME="br7"
# BR_VETH_INTERFACE="veth26"
# CEOS_DEVICE_NAME="ARISTA16T3"
# CEOS_CONTAINER_NAME="ceos_vms6-4-n_VM0111"
# nCEOS_CONTAINER_NAME="ceos_vms6-4-m_VM0102"
# NET_CONTAINER_NAME="net_vms6-4-n_VM0111"
# CEOS_VETH_INTERFACE="36"
# CEOS_IPv4="10.0.0.34"
# CEOS_IPv6="FC00::6e"
# CEOS_ASN="65201"
# nCEOS_ASN="65200"
# CEOS_n_T2_IPV6="FC01::9"
# VM_NAME="vlab-t2-03"
# VM_HOST_INTERFACE="vlab-t2-03-25"
# VM_ANSIBLE_IP="10.250.0.123"
# VM2_ANSIBLE_IP="10.250.0.124"
# VM_ANSIBLE_P="password"
# VM_INTERFACE="Ethernet160"
# VM_ASIC="1"
# VM_IPv4="10.0.0.33"
# VM_IPv6="FC00::6d"
# VM_ASN="65100"
# AGGREGATE_PREFIX="fc00::/64"	
# AGGREGATE_PREFIX_N="fc01::/64"	
# ANCHOR_PREFIX="fc00::/48"
# APPLY_ANCHOR_ROUTE=0'
# )


#ANCHOR_PREFIX="2064:100::/48"
#AGGREGATE_PREFIX="2064:100::/64"

# Function to load configuration and execute steps
run_config() {
    echo "Loading configuration..."
    eval "$1"
    get_container_and_vm_pids
    pause_containers_and_create_netns
    create_bridge_and_veth_pairs
    configure_firewall
    configure_ceos_interface
    configure_vm_interface
    # t2_radian_configs
    # t3_radian_configs
    if [ $APPLY_ANCHOR_ROUTE -eq 1 ]; then
      t2_push_radian_configs_v_2
      t3_push_radian_configs_v_2
    fi
}

install_prerequisites() {
    echo "Installing prerequisites..."
    sudo apt install -y sshpass
    sudo sysctl -w net.ipv6.conf.all.disable_ipv6=0
    sudo sysctl -w net.ipv6.conf.default.disable_ipv6=0
}

configure_firewall() {
    echo "Configuring firewall rules..."
    sudo iptables -A FORWARD -i "$BRIDGE_NAME" -j ACCEPT
    sudo iptables -A FORWARD -o "$BRIDGE_NAME" -j ACCEPT
}

get_container_and_vm_pids() {
    echo "Getting PIDs of container and VM..."
    CEOS_PID=$(docker inspect --format='{{.State.Pid}}' "$CEOS_CONTAINER_NAME")
    nCEOS_PID=$(docker inspect --format='{{.State.Pid}}' "$nCEOS_CONTAINER_NAME")
    VM_PID=$(pgrep -f "qemu-system.*$VM_NAME")
    if [[ -z "$CEOS_PID" || -z "$VM_PID" ]]; then
        echo "Error: Could not find PIDs for container or VM. Ensure they are running."
        exit 1
    fi
}

pause_containers_and_create_netns() {
    echo "Pausing containers and setting up network namespaces..."
    docker pause "$CEOS_CONTAINER_NAME"
    docker pause "$NET_CONTAINER_NAME"
    docker pause "$nCEOS_CONTAINER_NAME"
    sudo ln -sf /proc/"$VM_PID"/ns/net /var/run/netns/"$VM_NAME"
    sudo ln -sf /proc/"$CEOS_PID"/ns/net /var/run/netns/"$CEOS_CONTAINER_NAME"
    sudo ln -sf /proc/"$nCEOS_PID"/ns/net /var/run/netns/"$nCEOS_CONTAINER_NAME"
    docker unpause "$nCEOS_CONTAINER_NAME"
}

create_bridge_and_veth_pairs() {
    echo "Creating bridge and veth pairs..."
    sudo brctl addbr "$BRIDGE_NAME"
    sudo ip link set "$BRIDGE_NAME" up
    sudo ip link add "$BR_VETH_INTERFACE" type veth peer name eth"$CEOS_VETH_INTERFACE"
    sudo ip link set "$BR_VETH_INTERFACE" master "$BRIDGE_NAME"
    sudo ip link set "$VM_HOST_INTERFACE" master "$BRIDGE_NAME"
    sudo ip link set eth$CEOS_VETH_INTERFACE netns $CEOS_CONTAINER_NAME
    sudo ip link set "$BR_VETH_INTERFACE" up
    sudo ip link set "$VM_HOST_INTERFACE" up
}

configure_ceos_interface() {
    echo "Configuring CEOS container interface..."
    sudo ip netns exec "$CEOS_CONTAINER_NAME" ip link set eth"$CEOS_VETH_INTERFACE" up
    sudo ip netns exec "$CEOS_CONTAINER_NAME" ifconfig eth"$CEOS_VETH_INTERFACE" "$CEOS_IPv4/$PREFIX"
    sudo ip netns exec "$CEOS_CONTAINER_NAME" ip link set dev eth"$CEOS_VETH_INTERFACE" mtu 9214
    sudo ip link set dev "$BR_VETH_INTERFACE" mtu 9214


    docker unpause "$CEOS_CONTAINER_NAME"
    docker unpause "$NET_CONTAINER_NAME"
    echo "Logging into CEOS container CLI to restart interfaces..."
    docker exec -it $CEOS_CONTAINER_NAME Cli -c "
        en
        agent Fru terminate
        agent Ebra terminate
        agent Etba terminate
    "
    #Wait for 1 minute
    echo "Waiting for 1 minute to ensure configurations are applied..."
    sleep 60
    echo "Configuring CEOS container BGP..."
    docker exec -it "$CEOS_CONTAINER_NAME" Cli -c "
        en
        configure terminal
        int et$CEOS_VETH_INTERFACE
        no sw
        no shut
        mtu 9214
        ip address $CEOS_IPv4/$PREFIX
        ipv6 enable
        ipv6 address $CEOS_IPv6/$IPV6_PREFIX
        ipv6 nd ra disabled
        end
        write memory
        configure terminal
        router bgp $CEOS_ASN
        neighbor $VM_IPv4 remote-as $VM_ASN
        neighbor $VM_IPv4 description $VM_NAME
        address-family ipv4
        neighbor $VM_IPv4 activate
        !
        neighbor $VM_IPv6 remote-as $VM_ASN
        neighbor $VM_IPv6 description $VM_NAME
        address-family ipv6
        neighbor $VM_IPv6 activate
        exit
        end
        write memory
    "
}

# if pings dont work do this manually
# on downlink do ps aux | grep orch
# you will get the mac address of asic0 
# change the ip -6 neigh entry for your T1 vm
# so here fc01::1a is the t1 vm ip and 22:db:46:9b:0c:d0 is the mac address of asic0 on downlink
## vlab-t2-01
## sudo ip netns exec asic0 ip -6 neigh change fc01::1a dev Ethernet-IB0 lladdr 22:db:46:9b:0c:d0
# vlab-t2-03
## sudo ip netns exec asic0 ip -6 neigh change fc00::1a dev Ethernet-IB0 lladdr 22:d4:83:e7:9c:20
# vlab-t2-04
## sudo ip netns exec asic0 ip -6 neigh change fc00::2 dev Ethernet-IB0 lladdr 22:3a:62:33:aa:20
## sudo ip netns exec asic0 ip -6 neigh add fc00::4e dev Ethernet-IB0 lladdr 22:3a:62:33:aa:20

# sudo ip netns exec asic0 ip -6 neigh change fc00::e dev Ethernet-IB0 lladdr 22:3a:62:33:aa:21
#  sudo ip netns exec asic0 ip -6 neigh add fc00::6e dev Ethernet-IB0 lladdr 22:3a:62:33:aa:21
# sudo ip netns exec asic1 ip -6 neigh change fc00::e dev Ethernet-IB1 lladdr 22:3a:62:33:aa:21
#  sudo ip netns exec asic1 ip -6 neigh add fc00::6e dev Ethernet-IB1 lladdr 22:3a:62:33:aa:21




configure_vm_interface() {
    sudo ssh-keygen -f "/root/.ssh/known_hosts" -R "$VM_ANSIBLE_IP"
    sudo ssh-keygen -f "/root/.ssh/known_hosts" -R "$VM2_ANSIBLE_IP"
    echo "Configuring VM interface via SSH..."
    sshpass -p "$VM_ANSIBLE_P" ssh -t -o StrictHostKeyChecking=no "admin@$VM_ANSIBLE_IP" << EOF
sudo config interface -n asic$VM_ASIC startup $VM_INTERFACE
sudo ip netns exec asic$VM_ASIC ip link set $VM_INTERFACE up
sudo ip netns exec asic$VM_ASIC ip addr add $VM_IPv4/$PREFIX dev $VM_INTERFACE
sudo ip netns exec asic$VM_ASIC ip addr add $VM_IPv6/$IPV6_PREFIX dev $VM_INTERFACE
sudo ip netns exec asic$VM_ASIC sudo ip -6 route add $CEOS_IPv6/$IPV6_PREFIX dev $VM_INTERFACE
sudo ip netns exec asic$VM_ASIC ip addr show $VM_INTERFACE

sudo ip netns exec asic$VM_ASIC ip link set $VM_INT_fix down
sudo ip netns exec asic$VM_ASIC ip -6 addr del $VM_INT_fix_IPv6 dev $VM_INT_fix
sudo ip netns exec asic$VM_ASIC ip link set $VM_INT_fix up
sudo ip netns exec asic$VM_ASIC ip -6 route add $VM_INT_fix_IP6_ROUTE dev $VM_INT_fix metric 0
sudo ip netns exec asic$VM_ASIC ip -6 addr add $VM_INT_fix_IPv6 dev $VM_INT_fix

sudo vtysh -n $VM_ASIC 
configure terminal
router bgp $VM_ASN
neighbor $CEOS_IPv4 remote-as $CEOS_ASN
neighbor $CEOS_IPv4 peer-group RH_V4
neighbor $CEOS_IPv4 description $CEOS_DEVICE_NAME
address-family ipv4 unicast
neighbor $CEOS_IPv4 activate
exit
neighbor $CEOS_IPv6 remote-as $CEOS_ASN
neighbor $CEOS_IPv6 peer-group RH_V6
neighbor $CEOS_IPv6 description $CEOS_DEVICE_NAME
address-family ipv6 unicast
neighbor $CEOS_IPv6 activate
exit
en
write memory
exit
EOF
}



#####################################################
#####################################################
# Convert an AH into a RA
#####################################################
#####################################################
setup_RA(){
    echo "Setting up ARISTA06T3 as a Route Aggregator..."
    RA_ASN=65300
    RA_CEOS_CONTAINER_NAME="ceos_vms6-4-m_VM0103"
    RA_CEOS_PID=$(docker inspect --format='{{.State.Pid}}' "$RA_CEOS_CONTAINER_NAME")
    docker pause "$RA_CEOS_CONTAINER_NAME"
    sudo ln -sf /proc/"$RA_CEOS_PID"/ns/net /var/run/netns/"$RA_CEOS_CONTAINER_NAME"	 
  
    # remove ARISTA06T3 from vlab-t2-03
    remove_06t3
    # connect it to two RHs
    connect_RH
    add configs to RA and RHs
    push_RH_configs "$CEOS_CONTAINER_NAME" "$CEOS_ASN" "fc02::2" "$RA_ASN"
    push_RH_configs "$nCEOS_CONTAINER_NAME" "$nCEOS_ASN" "fc02::6" "$RA_ASN"
    push_RA_configs "$RA_CEOS_CONTAINER_NAME" "$RA_ASN" "fc02::1" "$CEOS_ASN" "fc02::5" "$nCEOS_ASN" "eth23" "eth25"
    
}
# Using ARISTA06T3 as the RA
# remove it from vlab-t2-03
remove_06t3(){
    echo "Removing ARISTA06T3 from vlab-t2-03..."
    sudo ssh-keygen -f "/root/.ssh/known_hosts" -R "$VM_ANSIBLE_IP"
    sshpass -p "$VM_ANSIBLE_P" ssh -t -o StrictHostKeyChecking=no "admin@$VM_ANSIBLE_IP" << EOF
sudo config interface -n asic1 shutdown Ethernet152
sudo vtysh -n 1
configure terminal
router bgp $VM_ASN
no neighbor 10.0.0.11 remote-as 65200
no neighbor fc00::16 remote-as 65200
end
write memory
EOF
}

connect_RH(){
    docker pause "$CEOS_CONTAINER_NAME"
    docker pause "$nCEOS_CONTAINER_NAME"
    # create veth pairs for RH1 and RA
    create_veth_pair "eth22" "eth23" "fc02::1/126" "fc02::2/126" "$CEOS_CONTAINER_NAME" "$RA_CEOS_CONTAINER_NAME"
    # create veth pairs for RH2 and RA
    docker pause "$RA_CEOS_CONTAINER_NAME"
    create_veth_pair "eth24" "eth25" "fc02::5/126" "fc02::6/126" "$nCEOS_CONTAINER_NAME" "$RA_CEOS_CONTAINER_NAME"
}

# veth ip config fucntion
create_veth_pair() {
      local veth1=$1
      local veth2=$2
      local ip1=$3
      local ip2=$4
      local container1=$5
      local container2=$6

      sudo ip link add "$veth1" type veth peer name "$veth2"
      ceos_interface_config "$container1" "$veth1" "$ip1"
      ceos_interface_config "$container2" "$veth2" "$ip2"
}

ceos_interface_config(){
  local container=$1
  local interface=$2
  local ip=$3
  echo "Configuring interface $interface in container $container..."
  sudo ip link set "$interface" up
  sudo ip link set "$interface" netns "$container"
  sudo ip netns exec "$container" ip link set "$interface" up
  sudo ip netns exec "$container" ip link set dev "$interface" mtu 9214
  reset_container "$container"
  docker exec -it "$container" Cli -c "
    en
    !
    configure terminal
    int $interface	
    no sw
    no shut
    mtu 9214
    ipv6 enable
    ipv6 address $ip
    ipv6 nd ra disabled
    end
    write memory
  "
}

reset_container(){
  local container=$1
  docker unpause "$container"
  docker exec -it "$container" Cli -c "
    en
    agent Fru terminate
    agent Ebra terminate
    agent Etba terminate
  "
  sleep 60
}

push_RH_configs(){
  local container=$1
  local asn=$2
  local RA_ip=$3
  local RA_asn=$4
  echo "Pushing configs to $container..."
  docker exec -it "$container" Cli -c "
    en
    configure terminal
    !
    ipv6 prefix-list DEFAULT_IPV6
     seq 5 permit ::/0
    !
    router bgp $asn
    neighbor RA_V6 peer group
    neighbor RA_V6 route-map TO_RA_V6 out
    neighbor RA_V6 route-map FROM_RA_V6 in
    neighbor RA_V6 send-community
    neighbor RA_V6 maximum-routes 64000 warning-only
    neighbor $RA_ip remote-as $RA_asn
    neighbor $RA_ip peer group RA_V6
    neighbor $RA_ip description RA
    address-family ipv6 
    neighbor $RA_ip activate
    exit
    !
    route-map TO_RA_V6 permit 50
     match ipv6 address prefix-list DEFAULT_IPV6
    route-map TO_RA_V6 deny 60
    route-map FROM_RA_V6 permit 50
    end
    write memory
  "
}

push_RA_configs(){
  local container=$1
  local asn=$2
  local RH1_ip=$3
  local RH1_asn=$4
  local RH2_ip=$5
  local RH2_asn=$6
  local eth1=$7
  local eth2=$8

  echo "Pushing configs to $container..."
  docker exec -it "$container" Cli -c "
    en
    configure terminal
    !
    ipv6 prefix-list DEFAULT_IPV6
     seq 5 permit ::/0
    !
    ! 
    ipv6 route ::/0 $eth1
    ipv6 route ::/0 $eth2	
    !
    no router bgp 65200
    router bgp $asn
    router-id 100.1.0.6
    neighbor RH_V6 peer group
    neighbor RH_V6 route-map TO_RH_V6 out
    neighbor RH_V6 route-map FROM_RH_V6 in
    neighbor RH_V6 send-community
    neighbor RH_V6 maximum-routes 64000 warning-only
    neighbor $RH1_ip peer group RH_V6
    neighbor $RH1_ip remote-as $RH1_asn
    neighbor $RH1_ip description $CEOS_CONTAINER_NAME
    neighbor $RH2_ip peer group RH_V6
    neighbor $RH2_ip remote-as $RH2_asn
    neighbor $RH2_ip description $nCEOS_CONTAINER_NAME
    address-family ipv4
    network 100.1.0.6/32
    address-family ipv6 
    neighbor $RH1_ip activate
    neighbor $RH2_ip activate
    neighbor RH_V6 activate
    network 2064:100::6/128
    network ::/0
    exit
    !
    route-map TO_RH_V6 permit 10
     match ipv6 address prefix-list DEFAULT_IPV6
    route-map TO_RH_V6 permit 50
    route-map FROM_RH_V6 permit 10
     match ipv6 address prefix-list DEFAULT_IPV6
    route-map FROM_RH_V6 permit 50
    end
    write memory
"

}


#####################################################
#####################################################
# ANCHOR Specific Configurations
#####################################################
#####################################################
t2_radian_configs(){
    # t2_push_aggregate_configs
    # t2_downlink_aggregate_configs
    if [ $APPLY_ANCHOR_ROUTE -eq 1 ]; then
        t2_push_radian_configs
        t2_configure_downlink_card
        t2_post_checks
        t2_post_checks_advertise_anchors
    fi

}

t3_radian_configs(){
    t3_prechecks_anchor
    t3_push_radian_configs
    t3_post_checks
}
#####################################################
#####################################################
# T2 Specific Configurations
#####################################################
#####################################################



t2_push_aggregate_configs(){
    echo "Adding RADIAN Configs to T2..."
    sudo ssh-keygen -f "/root/.ssh/known_hosts" -R "$VM_ANSIBLE_IP"
    sshpass -p "$VM_ANSIBLE_P" ssh -t -o StrictHostKeyChecking=no "admin@$VM_ANSIBLE_IP" << EOF
sudo vtysh -n $VM_ASIC
configure terminal
!
bgp community-list standard AGGREGATE_ROUTES permit 8075:54002
!
ipv6 prefix-list AGGREGATE_ROUTES_V6 seq 30 permit $AGGREGATE_PREFIX
!
route-map TO_RH_V6 permit 400
match ipv6 address prefix-list AGGREGATE_ROUTES_V6
set community 8075:54002 additive

route-map FROM_RH_V6 deny 600
    match ipv6 address prefix-list AGGREGATE_ROUTES_V6

route-map TO_VOQ_CHASSIS_V6_PEER deny 700
    match community AGGREGATE_ROUTES
    set comm-list INREGION_LEAK_COMMUNITY delete
exit

router bgp $VM_ASN
  address-family ipv6
    aggregate-address $AGGREGATE_PREFIX summary-only
  exit
exit
end
write memory
EOF
}

t2_downlink_aggregate_configs(){
    echo "Adding RADIAN Configs to T2..."
    sudo ssh-keygen -f "/root/.ssh/known_hosts" -R "$VM2_ANSIBLE_IP"
    sshpass -p "$VM_ANSIBLE_P" ssh -t -o StrictHostKeyChecking=no "admin@$VM2_ANSIBLE_IP" << EOF
sudo vtysh -n $VM_ASIC
configure terminal
!
bgp community-list standard AGGREGATE_ROUTES permit 8075:54002
!
route-map TO_TIER1_V6 deny 30
  match community AGGREGATE_ROUTES
end
write memory

EOF
}



t2_push_radian_configs(){
    echo "Adding RADIAN Configs to T2..."
    sudo ssh-keygen -f "/root/.ssh/known_hosts" -R "$VM_ANSIBLE_IP"
    sshpass -p "$VM_ANSIBLE_P" ssh -t -o StrictHostKeyChecking=no "admin@$VM_ANSIBLE_IP" << EOF
sudo vtysh -n $VM_ASIC
configure terminal
!
bgp community-list standard ANCHOR_ROUTE_COMMUNITY permit 8075:9319
! 
ipv6 prefix-list ANCHOR_ROUTE_V6 seq 10 permit ::1/128
ipv6 prefix-list ANCHOR_ROUTE_V6 seq 20 permit $ANCHOR_PREFIX
!
route-map SELECTIVE_ROUTE_DOWNLOAD_V6 deny 10
 match ipv6 address prefix-list ANCHOR_ROUTE_V6

route-map SELECTIVE_ROUTE_DOWNLOAD_V6 permit 1000
route-map TAG_ANCHOR_COMMUNITY permit 10
 set community 8075:9319

route-map FROM_RH_V6 deny 15
 match ipv6 address prefix-list ANCHOR_ROUTE_V6

route-map TO_AH_V6 deny 1
 match ipv6 address prefix-list ANCHOR_ROUTE_V6

route-map TO_RH_V6 permit 20
 match ipv6 address prefix-list ANCHOR_ROUTE_V6

router bgp $VM_ASN
  address-family ipv6 
    neighbor RH_V6 send-community both
    neighbor VOQ_CHASSIS_V6_PEER send-community both
    aggregate-address $ANCHOR_PREFIX route-map TAG_ANCHOR_COMMUNITY
    table-map SELECTIVE_ROUTE_DOWNLOAD_V6
  exit
exit
end
write memory
EOF
}

t2_configure_downlink_card(){
    echo "Configuring downlink card on T2..."
    sudo ssh-keygen -f "/root/.ssh/known_hosts" -R "$VM2_ANSIBLE_IP"
    sshpass -p "$VM_ANSIBLE_P" ssh -t -o StrictHostKeyChecking=no "admin@$VM2_ANSIBLE_IP" << EOF
sudo vtysh -n $VM_ASIC
configure terminal
!
ipv6 prefix-list ANCHOR_ROUTE_V6 seq 10 permit ::1/128
ipv6 prefix-list ANCHOR_ROUTE_V6 seq 20 permit $ANCHOR_PREFIX
!
route-map TO_TIER1_V6 deny 15
  match ipv6 address prefix-list ANCHOR_ROUTE_V6
end

write memory
EOF
}

t2_remove_radian_configs(){
    echo "Removing RADIAN Configs from T2..."
    sudo ssh-keygen -f "/root/.ssh/known_hosts" -R "$VM_ANSIBLE_IP"
    sshpass -p "$VM_ANSIBLE_P" ssh -t -o StrictHostKeyChecking=no "admin@$VM_ANSIBLE_IP" << EOF
sudo vtysh -n $VM_ASIC
configure terminal
!
no bgp community-list standard ANCHOR_ROUTE_COMMUNITY permit 8075:9319
! 
no ipv6 prefix-list ANCHOR_ROUTE_V6 seq 10 permit ::1/128
no ipv6 prefix-list ANCHOR_ROUTE_V6 seq 20 permit $ANCHOR_PREFIX
!
no route-map SELECTIVE_ROUTE_DOWNLOAD_V6 deny 10
no route-map SELECTIVE_ROUTE_DOWNLOAD_V6 permit 1000
no route-map TAG_ANCHOR_COMMUNITY permit 10

no route-map FROM_RH_V6 deny 15

no route-map TO_AH_V6 deny 1

no route-map TO_RH_V6 permit 20

router bgp $VM_ASN
  address-family ipv6
    no aggregate-address $ANCHOR_PREFIX route-map TAG_ANCHOR_COMMUNITY
    no table-map SELECTIVE_ROUTE_DOWNLOAD_V6
  exit

end
write memory
EOF
}

t2_post_checks(){
    echo "Postchecks for T2..."
    sshpass -p "$VM_ANSIBLE_P" ssh -t -o StrictHostKeyChecking=no "admin@$VM_ANSIBLE_IP" << EOF
sudo vtysh -n $VM_ASIC
show ip route 0.0.0.0
!
show ipv6 route ::/0
!
show ipv6 route $ANCHOR_PREFIX
!
show bgp ipv6 summary
!
show bgp ipv6 $ANCHOR_PREFIX
!
show bgp ipv6 community-list ANCHOR_ROUTE_COMMUNITY
EOF
}

t2_post_checks_advertise_anchors(){
    echo "Postchecks for T2 after advertising Anchors..."
    sshpass -p "$VM_ANSIBLE_P" ssh -t -o StrictHostKeyChecking=no "admin@$VM_ANSIBLE_IP" << EOF
sudo vtysh -n $VM_ASIC
show ip route 0.0.0.0
!
show ipv6 route ::/0
!
show ipv6 route $ANCHOR_PREFIX
!
show bgp ipv6 summary
!
show bgp ipv6 community-list ANCHOR_ROUTE_COMMUNITY
!
show bgp ipv6 $ANCHOR_PREFIX
EOF
}

#####################################################
#####################################################
# T3 Specific Configurations
#####################################################
#####################################################

t3_prechecks_anchor(){
    echo "Prechecks for T3..."
    docker exec -it $CEOS_CONTAINER_NAME Cli -c "
        en
        show ip route 0.0.0.0
        !
        show ipv6 route ::/0
        !
        show ipv6 route $ANCHOR_PREFIX
        !
        show ipv6 bgp summary
        !
    "
}
#        ip community-list AGGREGATE_ROUTES permit 8075:54002
#         route-map FROM_T2_V6 permit 30
          # match community AGGREGATE_ROUTES
          # set community community-list INREGION_LEAK_COMMUNITY additive



t3_push_radian_configs(){
    echo "Adding RADIAN Configs to T3..."
    docker exec -it $CEOS_CONTAINER_NAME Cli -c "
        en
        configure terminal
        !
        ip prefix-list DEFAULT_IPV4 seq 5 permit 0.0.0.0/0
        ipv6 prefix-list DEFAULT_IPV6 
            seq 5 permit ::/0
        !
        ip community-list ANCHOR_ROUTE_COMMUNITY permit 8075:9319

        ip community-list FABRIC_INFRA_COMMUNITY permit 8075:316
        ip community-list INREGION_LEAK_COMMUNITY permit 8075:8848
        ip community-list LEAK_COMMUNITY permit 8075:10400
        !
        router bgp $CEOS_ASN
          neighbor T2_V6 peer group
          neighbor T2_V6 route-map TO_T2_V6 out
          neighbor T2_V6 route-map FROM_T2_V6 in
          neighbor T2_V6 send-community
          neighbor T2_V6 maximum-routes 64000 warning-only
          neighbor $VM_IPv6 peer group T2_V6
          neighbor $CEOS_n_T2_IPV6 peer group T2_V6
          address-family ipv6
            bgp route install-map SELECTIVE_ROUTE_DOWNLOAD_V6
          exit
        !
        route-map TO_T2_V6 permit 10
          match ip address prefix-list DEFAULT_IPV6
        route-map TO_T2_V6 permit 20
          match community LEAK_COMMUNITY
        route-map TO_T2_V6 permit 30
          match community FABRIC_INFRA_COMMUNITY
        route-map TO_T2_V6 permit 40
          match community INREGION_LEAK_COMMUNITY
        route-map TO_T2_V6 deny 50
        !
        route-map FROM_T2_V6 deny 10
          match ip address prefix-list DEFAULT_IPV6
        route-map FROM_T2_V6 permit 20
          match community ANCHOR_ROUTE_COMMUNITY
          set community community-list INREGION_LEAK_COMMUNITY additive
        route-map FROM_T2_V6 permit 50
        !
        route-map SELECTIVE_ROUTE_DOWNLOAD_V6 deny 10
          match community ANCHOR_ROUTE_COMMUNITY
        route-map SELECTIVE_ROUTE_DOWNLOAD_V6 permit 1000
        !
        route-map TO_RWA_V6 deny 350
          match community ANCHOR_ROUTE_COMMUNITY
        !
        route-map TO_RA_V6 deny 22
          match community ANCHOR_ROUTE_COMMUNITY
        !
        end
        copy run start
    "
    echo "RADIAN Configs added to T3..."
    
}

t3_post_checks(){
    echo "Postchecks for T3..."
    t3_prechecks_anchor
    docker exec -it $CEOS_CONTAINER_NAME Cli -c "
        en
        !
        show ipv6 bgp community-list ANCHOR_ROUTE_COMMUNITY 
    "
}

t3_rollback_radian_configs(){
    echo "Rolling back RADIAN Configs from T3..."
    docker exec -it $CEOS_CONTAINER_NAME Cli -c "
        en
        router bgp $CEOS_ASN
        address-family ipv6
        no bgp route install-map Selective_Route_Download_V6
        no route-map FROM_T2_V6 permit 30
        no route-map TO_RWA_V6 deny 350
        no route-map TO_RA_V6 deny 22
        no route-map Selective_Route_Download_V6
        no ip community-list ANCHOR_ROUTE_COMMUNITY permit 8075:9319
        end
        copy run start
    "
}


#####################################################
#####################################################
# T2 -T3 V2 Specific Configurations
#####################################################
#####################################################

t2_push_radian_configs_v_2(){
    echo "Adding RADIAN Configs to T2..."
    sudo ssh-keygen -f "/root/.ssh/known_hosts" -R "$VM_ANSIBLE_IP"
    sshpass -p "$VM_ANSIBLE_P" ssh -t -o StrictHostKeyChecking=no "admin@$VM_ANSIBLE_IP" << EOF
sudo vtysh -n $VM_ASIC
configure terminal
!
bgp community-list standard ANCHOR_ROUTE_COMMUNITY permit 8075:9319
bgp community-list standard LOCAL_ANCHOR_ROUTE_COMMUNITY permit 8075:9320
bgp community-list standard ANCHOR_CONTRIBUTING_ROUTE_COMMUNITY permit 8075:9321
!
ipv6 prefix-list ANCHOR_CONTRIBUTING_ROUTES seq 5 permit $ANCHOR_PREFIX ge 48 
!
bgp as-path access-list T2_Group_ASNS permit _{$VM_ASN}$

route-map SELECTIVE_ROUTE_DOWNLOAD_V6 deny 10
 match community LOCAL_ANCHOR_ROUTE_COMMUNITY
route-map SELECTIVE_ROUTE_DOWNLOAD_V6 permit 1000

route-map TAG_ANCHOR_COMMUNITY permit 10
 set community 8075:9320 8075:9319 additive

route-map FROM_RH_V6 deny 15
 match as-path T2_Group_ASNS

route-map TO_RH_V6 permit 30
 match ipv6 address prefix-list ANCHOR_CONTRIBUTING_ROUTES
 set community 8075:9321 additive
 on-match next
route-map TO_RH_V6 permit 40
 set comm-list LOCAL_ANCHOR_ROUTE_COMMUNITY delete

route-map TO_AH_V6 deny 1
 match community LOCAL_ANCHOR_ROUTE_COMMUNITY

route-map TO_VOQ_CHASSIS_V6_PEER deny 15
 match community LOCAL_ANCHOR_ROUTE_COMMUNITY


router bgp $VM_ASN
  address-family ipv6
    neighbor RH_V6 send-community both
    neighbor VOQ_CHASSIS_V6_PEER send-community both
    aggregate-address $ANCHOR_PREFIX route-map TAG_ANCHOR_COMMUNITY
    table-map SELECTIVE_ROUTE_DOWNLOAD_V6
  exit
end
EOF

# downlink card
sudo ssh-keygen -f "/root/.ssh/known_hosts" -R "$VM2_ANSIBLE_IP"
sshpass -p "$VM_ANSIBLE_P" ssh -t -o StrictHostKeyChecking=no "admin@$VM2_ANSIBLE_IP" << EOF
sudo vtysh -n $VM_ASIC
configure terminal
!
bgp community-list standard LOCAL_ANCHOR_ROUTE_COMMUNITY permit 8075:9320
!
route-map TO_TIER1_V6 deny 15
 match community LOCAL_ANCHOR_ROUTE_COMMUNITY

!
route-map V6_CONNECTED_ROUTES permit 10
  no call HIDE_INTERNAL
end
write memory
EOF
}

t3_push_radian_configs_v_2(){
      echo "Adding RADIAN Configs to T3..."
    docker exec -it $CEOS_CONTAINER_NAME Cli -c "
        en
        configure terminal
        !
        ip prefix-list DEFAULT_IPV4 seq 5 permit 0.0.0.0/0
        ipv6 prefix-list DEFAULT_IPV6 
            seq 5 permit ::/0
        !
        ip community-list LOCAL_ANCHOR_ROUTE_COMMUNITY permit 8075:9320
        ip community-list ANCHOR_ROUTE_COMMUNITY permit 8075:9319
        ip community-list FABRIC_INFRA_COMMUNITY permit 8075:316
        ip community-list INREGION_LEAK_COMMUNITY permit 8075:8848
        ip community-list LEAK_COMMUNITY permit 8075:10400
        !
        route-map SELECTIVE_ROUTE_DOWNLOAD_V6 deny 10
          match community ANCHOR_ROUTE_COMMUNITY
        route-map SELECTIVE_ROUTE_DOWNLOAD_V6 permit 1000
        !
        router bgp $CEOS_ASN
          neighbor T2_V6 peer group
          neighbor T2_V6 route-map TO_T2_V6 out
          neighbor T2_V6 route-map FROM_T2_V6 in
          neighbor T2_V6 send-community
          neighbor T2_V6 maximum-routes 64000 warning-only
          neighbor $VM_IPv6 peer group T2_V6
          neighbor $CEOS_n_T2_IPV6 peer group T2_V6
          address-family ipv6
            neighbor T2_V6 activate
            bgp route install-map SELECTIVE_ROUTE_DOWNLOAD_V6
          exit
        !
        route-map TO_T2_V6 permit 10
          match ipv6 address prefix-list DEFAULT_IPV6
        route-map TO_T2_V6 permit 20
          match community LEAK_COMMUNITY
        route-map TO_T2_V6 permit 30
          match community FABRIC_INFRA_COMMUNITY
        route-map TO_T2_V6 permit 40
          match community INREGION_LEAK_COMMUNITY
        route-map TO_T2_V6 deny 50
        !
        route-map FROM_T2_V6 deny 10
          match ipv6 address prefix-list DEFAULT_IPV6
        route-map FROM_T2_V6 permit 20
          match community LOCAL_ANCHOR_ROUTE_COMMUNITY
          set community community-list LOCAL_ANCHOR_ROUTE_COMMUNITY delete
          on-match next
        route-map FROM_T2_V6 permit 30
          match community ANCHOR_ROUTE_COMMUNITY
          set community community-list INREGION_LEAK_COMMUNITY additive

        route-map FROM_T2_V6 permit 50
        !
        route-map TO_RWA_V6 deny 350
          match community ANCHOR_ROUTE_COMMUNITY
        !
        route-map TO_RA_V6 deny 22
          match community ANCHOR_ROUTE_COMMUNITY
        !
        end
        copy run start
    "
    echo "RADIAN Configs added to T3..."
}






main() {
    install_prerequisites
    for config in "${CONFIGS[@]}"; do
        echo "Running configuration set..."
        run_config "$config"
    done
    # echo "setup_RA"
    # setup_RA
    # echo "All configurations processed."
}

# Run the main function
main
