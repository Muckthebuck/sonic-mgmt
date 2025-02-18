import yaml
import re
import argparse

# Default values for reset
DEFAULT_IPV4 = "10.10.246.254/24"
DEFAULT_IPV6 = "fc0a::ff/64"

def update_yaml_ips(file_path, new_ipv4, new_ipv6):
    # Read the file as a string to preserve all formatting
    with open(file_path, 'r') as file:
        content = file.read()

    # Use regex to find and replace the IPv4 and IPv6 addresses
    ipv4_pattern = r'(?<=ptf_bp_ip:\s)([0-9\.\/]+)'
    ipv6_pattern = r'(?<=ptf_bp_ipv6:\s)([a-fA-F0-9:\/]+)'

    # Replace the IPs
    content = re.sub(ipv4_pattern, new_ipv4, content)
    content = re.sub(ipv6_pattern, new_ipv6, content)

    # Write the updated content back to the file, preserving the structure
    with open(file_path, 'w') as file:
        file.write(content)

    print(f"Updated YAML file saved: {file_path}")

def reset_yaml_ips(file_path):
    # Read the file as a string to preserve all formatting
    with open(file_path, 'r') as file:
        content = file.read()

    # Use regex to find and reset the IPv4 and IPv6 addresses to default
    ipv4_pattern = r'(?<=ptf_bp_ip:\s)([0-9\.\/]+)'
    ipv6_pattern = r'(?<=ptf_bp_ipv6:\s)([a-fA-F0-9:\/]+)'

    # Replace the IPs with default values
    content = re.sub(ipv4_pattern, DEFAULT_IPV4, content)
    content = re.sub(ipv6_pattern, DEFAULT_IPV6, content)

    # Write the updated content back to the file, preserving the structure
    with open(file_path, 'w') as file:
        file.write(content)

    print(f"YAML file reset to default values: {file_path}")

def read_ips_from_file(topo_file_path):
    # Read the IP addresses from another YAML file
    with open(topo_file_path, 'r') as file:
        topo_data = yaml.safe_load(file)

    # Accessing the IPs from the given structure
    try:
        new_ipv4 = topo_data["configuration_properties"]["common"]["nhipv4"]
        new_ipv6 = topo_data["configuration_properties"]["common"]["nhipv6"]
    except KeyError as e:
        raise ValueError(f"Missing key in the IP YAML file: {e}")
    
    # Convert to CIDR notation
    new_ipv4_cidr = f"{new_ipv4}/24"
    new_ipv6_cidr = f"{new_ipv6}/64"

    return new_ipv4_cidr, new_ipv6_cidr

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Update or reset IP addresses in a YAML file using data from another YAML file.")
    parser.add_argument("file", help="Path to the YAML file to be updated: /sonic-mgm/ansible/group_vars/vm_host/main.yml.")
    parser.add_argument("--topo-file", required=False, help="Path to the YAML file containing the topology config.")
    parser.add_argument("--reset", action='store_true', help="Reset IP addresses to default values.")
    args = parser.parse_args()

    # If reset flag is set, reset the IPs to default
    if args.reset:
        reset_yaml_ips(args.file)
    else:
        # Otherwise, read the new IPs from the provided YAML file and update
        if not args.topo_file:
            print("Error: --ips-file must be specified when updating IPs.")
            exit(1)
        try:
            new_ipv4, new_ipv6 = read_ips_from_file(args.topo_file)
            
            # Validate IP address format
            ipv4_pattern = r"^\d{1,3}(\.\d{1,3}){3}/\d{1,2}$"
            ipv6_pattern = r"^[a-fA-F0-9:]+/\d{1,3}$"

            if not re.match(ipv4_pattern, new_ipv4):
                print("Error: Invalid IPv4 address format. Use CIDR notation, e.g., 192.168.1.1/24.")
                exit(1)
            if not re.match(ipv6_pattern, new_ipv6):
                print("Error: Invalid IPv6 address format. Use CIDR notation, e.g., fc00::1/64.")
                exit(1)

            # Update the YAML file with the new IPs
            update_yaml_ips(args.file, new_ipv4, new_ipv6)
        except Exception as e:
            print(f"Error: {e}")
