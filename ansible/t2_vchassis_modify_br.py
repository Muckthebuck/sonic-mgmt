import re
import sys
import os

def increment_string_in_file(file_path, search_string, reset=False):
    """
    Increment the number in the search string within the specified file.
    
    Args:
        file_path (str): Path to the file to be modified.
        search_string (str): The string to search for in the file.
        reset (bool): If True, reset the number to zero. Default is False.
    """
    try:
        with open(file_path, 'r') as file:
            content = file.read()
    except FileNotFoundError:
        print(f"Error: File not found - {file_path}")
        return

    # Find all occurrences of the search string with or without a number
    matches = re.findall(f'{search_string}(\\d*)', content)
    
    if matches:
        last_number = int(matches[-1]) if matches[-1].isdigit() else 0
        new_number = last_number + 1
    else:
        print(f"Error: No occurrences of '{search_string}' found in {file_path}")
        return

    # Replace the old string with the new incremented string
    if reset:
        new_content = re.sub(f'{search_string}(\\d*)', f'{search_string}', content)
    else:
        new_content = re.sub(f'{search_string}(\\d*)', f'{search_string}{new_number}', content)
    
    with open(file_path, 'w') as file:
        file.write(new_content)
    
    print(f"Modified {len(matches)} occurrences of '{search_string}' in {file_path}")

def main():
    """
    Main function to execute the script.
    """
    # Get the current working directory
    script_dir = '/data/sonic-mgmt/ansible'
    
    # Define file paths relative to the script directory
    file_paths = [
        os.path.join(script_dir, 'testbed_add_vm_topology.yml'),
        os.path.join(script_dir, 'roles/vm_set/library/vm_topology.py')
    ]
    
    # Define the search strings to look for in the files
    search_strings = ['br-T2Inband', 'br-T2Midplane']
    
    # Check if the reset argument is provided
    reset = len(sys.argv) > 1 and sys.argv[1] == 'reset'
    
    # Increment the search strings in the specified files
    for file_path in file_paths:
        for search_string in search_strings:
            increment_string_in_file(file_path, search_string, reset)

if __name__ == "__main__":
    main()
