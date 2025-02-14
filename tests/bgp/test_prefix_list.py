import logging
import pytest
import random

from tests.common import config_reload
from tests.common.helpers.assertions import pytest_assert
from tests.common.helpers.constants import DEFAULT_ASIC_ID
from tests.common.utilities import wait_until
from route_checker import assert_only_loopback_routes_announced_to_neighs, parse_routes_on_neighbors
from route_checker import verify_current_routes_announced_to_neighs, check_and_log_routes_diff
import ipaddress

pytestmark = [
    pytest.mark.topology('t2')
]

logger = logging.getLogger(__name__)

def verify_prefix_list_in_db(host, prefix_type, prefix, cmd="sudo prefix_list status", add=True):
    """
    Verify if the prefix list is in the CONFIG_DB for asic_index
    PREFIX_LIST status shows
    BGP0: Current prefix lists:
    {('PREFIX_TYPE', 'PREFIX1'): {}}
    {('PREFIX_TYPE', 'PREFIX2'): {}}
    BGP1: Current prefix lists:
    {('PREFIX_TYPE', 'PREFIX1'): {}}
    {('PREFIX_TYPE', 'PREFIX2'): {}}

    Parameters:
    host (SonicHost): The SonicHost object
    prefix_type (str): The prefix type
    prefix (str): The prefix
    outputs (str): The output of the command
    add (bool): True if the prefix was added, False if the prefix was removed
    """
    outputs = host.shell(cmd)['stdout']
    # string matching to see if prefix type and prefix are in the output 
    expected = len(host.get_frontend_asic_ids()) if add else 0
    # check if we have n_asic entry matches of (PREFIX_TYPE, PREFIX) in the output
    result_str = f"('{prefix_type}', '{prefix}')"
    count = outputs.count(result_str)
    if count != expected:
        logger.error(f"Expected {expected} occurences of {result_str} in the output, but found {count} occurences")
        return False
    return True

def add_prefix(host, prefix_type, prefix, with_config_reload=False):
    """
    Add a prefix to the prefix list

    Parameters:
    host (SonicHost): The SonicHost object
    prefix_type (str): The prefix type
    prefix (str): The prefix
    asic_index (int): The asic index
    """
    # add the prefix to the prefix list
    cmd= f"sudo prefix-list add {prefix_type} {prefix}"
    host.shell(cmd)
    if with_config_reload:
        host.shell("sudo config save -y")
        config_reload(host, safe_reload=True, check_intf_up_ports=True, wait_for_bgp=True)
    if not verify_prefix_list_in_db(host, prefix_type, prefix):
        logger.error(f"Failed to add prefix {prefix} to the prefix list")
        return False
    return True

def remove_prefix(host, prefix_type, prefix, with_config_reload=False):
    """
    Remove a prefix from the prefix list

    Parameters:
    host (SonicHost): The SonicHost object
    prefix_type (str): The prefix type
    prefix (str): The prefix
    asic_index (int): The asic index
    """
    # remove the prefix from the prefix list
    cmd= f"sudo prefix-list remove {prefix_type} {prefix}"
    outputs = host.shell(cmd)
    if with_config_reload:
        host.shell("sudo config save -y")
        config_reload(host, safe_reload=True, check_intf_up_ports=True, wait_for_bgp=True)
    if not verify_prefix_list_in_db(host, prefix_type, prefix, outputs, add=False):
        logger.error(f"Failed to remove prefix {prefix} from the prefix list")
        return False
    return True

def verify_prefix_in_table(host, prefix, present=True, table="bgp"):
    """
    Verify if the prefix is in the specified table

    Parameters:
    host (SonicHost): The SonicHost object
    asic_index (int): The asic index
    prefix (str): The prefix
    add (bool): True if the prefix was added, False if the prefix was removed
    table (str): The table to check the prefix in {bgp, route}
    """
    if table not in ["bgp", "route"]:
        raise ValueError("Invalid table specified. Must be 'bgp' or 'route'.")

    ipv = "ip" if ipaddress.ip_network(prefix).version==4 else "ipv6"

    for asic_index in host.get_frontend_asic_ids():
        if table == "bgp":
            cmd = f"vtysh -n {asic_index} -c 'show bgp {ipv} {prefix}'"
        else:
            cmd = f"vtysh -n {asic_index} -c 'show {ipv} route {prefix}'"

        outputs = host.shell(cmd)['stdout']
        if present:
            if f"Network not in table" in outputs:
                logger.error(f"Expected prefix {prefix} to be in the {table} table, but it was not found")
                return False
        else:
            if f"Network not in table" not in outputs:
                logger.error(f"Expected prefix {prefix} to not be in the {table} table, but found it")
                return False
        
    return True

@pytest.fixture(scope="module")
def rand_one_uplink_duthost(duthosts, tbinfo):
    """
    Pick one uplink linecard duthost randomly
    """
    if tbinfo['topo']['type'] != 't2':
        return []
    uplink_dut_list = []
    for duthost in duthosts:
        if duthost.is_supervisor_node():
            continue
        # First get all T3 neighbors, which are of type RegionalHub, AZNGHub
        config_facts = duthost.config_facts(host=duthost.hostname, source="running")['ansible_facts']
        device_neighbor_metadata = config_facts['DEVICE_NEIGHBOR_METADATA']
        for k, v in device_neighbor_metadata.items():
            # if this duthost has peer of type RH/AZNG, then it is uplink LC
            if v['type'] == "RegionalHub":
                uplink_dut_list.append(duthost)
                break

    if len(uplink_dut_list) > 0 :
        return random.choice(uplink_dut_list)
    pytest.skip("No uplink linecard found")


def test_add_radian_prefix(rand_one_uplink_duthost, nbrhosts):
    """
    Testing cli command to add a prefix along with its configs
    1. Add prefix using the cli command
    2. Verify the prefix is in the CONFIG_DB
    3. Verify the configs are present in the running-config
    4. Verify the prefix is in the BGP table
    5. Verify the prefix is not in the Route table
    6. Verify the prefix is announced to the neighbor RH
    7. Verify the prefix is not announced to other neighbors
    """

    asic_index = DEFAULT_ASIC_ID

    # remove the prefix from the prefix list
    prefix_type = "ANCHOR_PREFIX"
    prefix = "FC00::/48"

    duthost = rand_one_uplink_duthost
    pytest_assert(add_prefix(duthost, prefix_type, prefix), f"Failed to add prefix {prefix} to the prefix list")
    pytest_assert(verify_prefix_in_table(duthost, prefix), f"Failed to verify prefix {prefix} in the BGP table")
    pytest_assert(verify_prefix_in_table(duthost, prefix, present=False, table="route"), f"Failed to verify prefix {prefix} not in the Route table")
    





    

def test_remove_radian_prefix(duthosts, rand_one_dut_hostname, tbinfo):
    """
    Testing cli command to remove a prefix along with its configs
    1. Remove prefix using the cli command
    2. Verify the prefix is not in the CONFIG_DB
    3. Verify the configs are removed from the running-config
    4. Verify the prefix is not in the BGP table
    5. Verify the prefix is not in the Route table
    """
    
    duthost = duthosts[rand_one_dut_hostname]
    asic_index = DEFAULT_ASIC_ID

    # remove the prefix from the prefix list
    prefix_type = "ANCHOR_PREFIX"
    prefix = "FC00::/48"
    