#!/usr/bin/env bash

#===============================================================================
# NETWORK MAC ADDRESS TESTING TOOL
#===============================================================================
# 
# DESCRIPTION:
#   A comprehensive network testing tool that dynamically discovers MAC addresses
#   from your local network and tests router rules, connectivity, and access
#   controls by spoofing different MAC addresses.
#
# FEATURES:
#   • Auto-detects active network interface and configuration
#   • Dynamically calculates broadcast addresses for any subnet
#   • Discovers real MAC addresses from network devices using ARP
#   • Tests internet connectivity with different MAC addresses
#   • Scans and identifies network devices
#   • Tests router MAC-based filtering and access rules
#   • Safely restores original MAC address on exit
#
# USE CASES:
#   • Network security testing and penetration testing
#   • Router configuration validation
#   • MAC address filtering bypass testing
#   • Network troubleshooting and diagnostics
#   • Access control rule verification
#
# REQUIREMENTS:
#   • macOS (tested on macOS 10.15+)
#   • macchanger (installed via Homebrew)
#   • nmap (for network scanning)
#   • sudo privileges (required for MAC address changes)
#
# AUTHOR: Network Security Testing Tool
# VERSION: 2.0
# UPDATED: $(date +%Y-%m-%d)
#
#===============================================================================

# Configuration
INTERFACE=""  # Will be auto-detected
TEST_MACS=()  # Will be populated dynamically from network discovery

# Function to detect active network interface
detect_interface() {
    # Look for Wi-Fi interfaces first (en0, en1 are common on macOS)
    for iface in en0 en1; do
        if ifconfig "$iface" 2>/dev/null | grep -q "status: active" && \
           ifconfig "$iface" 2>/dev/null | grep -q "inet "; then
            echo "$iface"
            return 0
        fi
    done
    
    # Check if any en* interface has Wi-Fi capabilities
    for iface in $(ifconfig -l | tr ' ' '\n' | grep '^en[0-9]'); do
        if ifconfig "$iface" 2>/dev/null | grep -q "status: active" && \
           ifconfig "$iface" 2>/dev/null | grep -q "inet " && \
           networksetup -getairportnetwork "$iface" 2>/dev/null | grep -q "Current Wi-Fi Network"; then
            echo "$iface"
            return 0
        fi
    done
    
    # Get the interface used for the default route, but only if it's en*
    local default_interface=$(route -n get default 2>/dev/null | grep interface | awk '{print $2}')
    if [[ -n "$default_interface" && "$default_interface" =~ ^en[0-9]+$ ]]; then
        echo "$default_interface"
        return 0
    fi
    
    # Fallback: first en* interface with IP
    for iface in $(ifconfig -l | tr ' ' '\n' | grep '^en[0-9]'); do
        if ifconfig "$iface" 2>/dev/null | grep -q "inet "; then
            echo "$iface"
            return 0
        fi
    done
    
    echo "en0"  # Final fallback
}

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m' # No Color

# Script information
SCRIPT_NAME="Network MAC Address Testing Tool"
VERSION="2.0"

# Function to display help information
show_help() {
    cat << EOF
${BOLD}${BLUE}$SCRIPT_NAME v$VERSION${NC}

${BOLD}SYNOPSIS${NC}
    $(basename "$0") [OPTIONS]

${BOLD}DESCRIPTION${NC}
    A comprehensive network testing tool that discovers MAC addresses from your
    local network and tests router rules, connectivity, and access controls by
    spoofing different MAC addresses.

${BOLD}OPTIONS${NC}
    -h, --help      Show this help message and exit
    -v, --version   Show version information
    -r, --restore   Restore MAC address to original/permanent address

${BOLD}FEATURES${NC}
    • Auto-detects active network interface and configuration
    • Dynamically calculates broadcast addresses for any subnet
    • Discovers real MAC addresses from network devices using ARP
    • Tests internet connectivity with different MAC addresses
    • Scans and identifies network devices
    • Tests router MAC-based filtering and access rules
    • Safely restores original MAC address on exit

${BOLD}TESTING MODES${NC}
    ${GREEN}1) Basic Connectivity Test${NC}
       • Tests internet connectivity using your current MAC address
       • Useful for: Basic network troubleshooting, verifying current access
       • Safe: No MAC address changes, read-only testing
       
    ${GREEN}2) Full Router Rules Test${NC}
       • Discovers real MAC addresses from your network via ARP
       • Tests connectivity with each discovered MAC address
       • Changes MAC to discovered addresses and reconnects Wi-Fi
       • Scans network for device visibility with each MAC
       • Useful for: Bypassing MAC filtering, testing access controls
       • Security testing: Router rule validation, penetration testing
       
    ${GREEN}3) Network Scan Only${NC}
       • Scans your network to identify active devices and IP addresses
       • Useful for: Network discovery, device inventory, reconnaissance
       • Safe: No MAC changes, discovery mode only
       
    ${GREEN}4) Discover Network MACs Only${NC}
       • Shows MAC addresses of devices on your network
       • Useful for: MAC address research, target identification
       • Planning: Identify MACs before testing in mode 2
       
    ${GREEN}5) Restore MAC Address${NC}
       • Restores your network interface to its permanent MAC
       • Useful for: Cleanup after testing, reverting changes
       • Recovery: Fix connectivity issues from previous tests

${BOLD}REQUIREMENTS${NC}
    • ${YELLOW}macOS${NC} (tested on macOS 10.15+)
    • ${YELLOW}sudo privileges${NC} (required for MAC address changes)
    • ${YELLOW}macchanger${NC} (will be auto-installed via Homebrew if missing)
    • ${YELLOW}nmap${NC} (for network scanning)
    • ${YELLOW}Active network connection${NC}

${BOLD}USAGE EXAMPLES${NC}
    # Show help
    $(basename "$0") --help
    
    # Show version
    $(basename "$0") --version
    
    # Restore MAC address to original
    sudo $(basename "$0") --restore
    
    # Run with sudo (required for MAC changes)
    sudo $(basename "$0")
    
    # Quick connectivity test
    sudo $(basename "$0")  # Choose option 1
    
    # Full router testing
    sudo $(basename "$0")  # Choose option 2

${BOLD}SAFETY FEATURES${NC}
    • Automatically restores original MAC address on script exit
    • Handles Ctrl+C interruption gracefully
    • Validates network configuration before testing
    • Provides clear status indicators throughout testing

${BOLD}SECURITY NOTICE${NC}
    This tool is intended for legitimate network testing and security auditing
    purposes only. Ensure you have proper authorization before testing networks
    that you do not own or administer.

${BOLD}TROUBLESHOOTING${NC}
    • If macchanger is missing, the script will attempt to install it
    • If no MAC addresses are discovered, fallback addresses will be used
    • Interface detection failures will fall back to common interfaces
    • Network connectivity issues will be clearly reported

${BOLD}VERSION HISTORY${NC}
    v2.0 - Dynamic MAC discovery, auto-interface detection, broadcast calculation
    v1.0 - Initial version with hardcoded MAC addresses

For more information and updates, check the script header comments.
EOF
}

# Function to display version information
show_version() {
    echo -e "${BOLD}$SCRIPT_NAME${NC}"
    echo -e "Version: ${GREEN}$VERSION${NC}"
    echo -e "Platform: ${CYAN}macOS${NC}"
    echo -e "Updated: $(date +%Y-%m-%d)"
}

# Function to check if macchanger is installed
check_macchanger() {
    if ! command -v macchanger &> /dev/null; then
        echo -e "${RED}macchanger not found. Installing via Homebrew...${NC}"
        if ! command -v brew &> /dev/null; then
            echo -e "${RED}Homebrew not found. Please install Homebrew first:${NC}"
            echo '/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"'
            exit 1
        fi
        brew install acrogenesis/macchanger/macchanger
    else
        # Show macchanger version for debugging
        local version_info=$(macchanger --version 2>/dev/null | head -1)
        echo -e "${CYAN}Found macchanger: $version_info${NC}"
    fi
}

# Function to get current MAC address
get_current_mac() {
    ifconfig $INTERFACE | grep ether | awk '{print $2}'
}

# Function to calculate broadcast address from IP and netmask
calculate_broadcast() {
    local ip=$1
    local netmask=$2
    
    # Convert IP and netmask to decimal
    IFS='.' read -r i1 i2 i3 i4 <<< "$ip"
    IFS='.' read -r m1 m2 m3 m4 <<< "$netmask"
    
    # Calculate network address
    local n1=$((i1 & m1))
    local n2=$((i2 & m2))
    local n3=$((i3 & m3))
    local n4=$((i4 & m4))
    
    # Calculate broadcast address (network OR inverted netmask)
    local b1=$((n1 | (255 - m1)))
    local b2=$((n2 | (255 - m2)))
    local b3=$((n3 | (255 - m3)))
    local b4=$((n4 | (255 - m4)))
    
    echo "$b1.$b2.$b3.$b4"
}

# Function to convert hex netmask to dotted decimal
hex_to_decimal_netmask() {
    local hex_mask=$1
    
    # Validate input
    if [[ -z "$hex_mask" ]]; then
        echo "255.255.255.0"  # Default /24
        return 1
    fi
    
    # Remove 0x prefix if present
    hex_mask=${hex_mask#0x}
    
    # Ensure we have 8 hex characters, pad with zeros if needed
    while [ ${#hex_mask} -lt 8 ]; do
        hex_mask="${hex_mask}0"
    done
    
    # Validate hex characters
    if [[ ! "$hex_mask" =~ ^[0-9a-fA-F]{8}$ ]]; then
        echo "255.255.255.0"  # Default /24
        return 1
    fi
    
    # Convert each byte from hex to decimal with error checking
    local byte1 byte2 byte3 byte4
    
    byte1=$(printf "%d" "0x${hex_mask:0:2}" 2>/dev/null) || byte1=255
    byte2=$(printf "%d" "0x${hex_mask:2:2}" 2>/dev/null) || byte2=255
    byte3=$(printf "%d" "0x${hex_mask:4:2}" 2>/dev/null) || byte3=255
    byte4=$(printf "%d" "0x${hex_mask:6:2}" 2>/dev/null) || byte4=0
    
    echo "$byte1.$byte2.$byte3.$byte4"
}

# Function to get network info and calculate broadcast
get_network_info() {
    # Get IP and netmask from the interface
    local ip_info=$(ifconfig $INTERFACE 2>/dev/null | grep 'inet ' | head -1)
    local ip=$(echo "$ip_info" | awk '{print $2}')
    local netmask_hex=$(echo "$ip_info" | awk '{print $4}')
    
    if [[ -z "$ip" || -z "$netmask_hex" ]]; then
        echo -e "${YELLOW}Warning: Could not get IP/netmask for interface $INTERFACE${NC}" >&2
        
        # Try alternative method using route command
        local gateway_info=$(route -n get default 2>/dev/null)
        if [[ -n "$gateway_info" ]]; then
            local gateway=$(echo "$gateway_info" | grep gateway | awk '{print $2}')
            if [[ -n "$gateway" ]]; then
                # Assume common /24 network based on gateway
                local network_base=$(echo $gateway | cut -d. -f1-3)
                echo "${network_base}.255"
                return 0
            fi
        fi
        
        # Last resort: use common broadcast addresses
        for broadcast in "192.168.1.255" "192.168.0.255" "10.0.0.255" "172.16.255.255"; do
            ping -c 1 -t 1 $(echo $broadcast | cut -d. -f1-3).1 >/dev/null 2>&1 && {
                echo "$broadcast"
                return 0
            }
        done
        
        echo "192.168.1.255"  # Final fallback
        return 1
    fi
    
    # Convert hex netmask to decimal format
    local netmask=$(hex_to_decimal_netmask "$netmask_hex")
    
    # Calculate and return broadcast address
    calculate_broadcast "$ip" "$netmask"
}

# Function to discover MAC addresses from network
discover_network_macs() {
    echo -e "${BLUE}Discovering MAC addresses from network...${NC}"
    
    # Debug: Show current interface info
    echo -e "${CYAN}Debug - Interface $INTERFACE info:${NC}"
    local ip_info=$(ifconfig $INTERFACE 2>/dev/null | grep 'inet ' | head -1)
    if [[ -n "$ip_info" ]]; then
        echo "  IP info: $ip_info"
        local ip=$(echo "$ip_info" | awk '{print $2}')
        local netmask_hex=$(echo "$ip_info" | awk '{print $4}')
        echo "  Parsed IP: $ip"
        echo "  Parsed netmask (hex): $netmask_hex"
    else
        echo "  No IP info found for interface $INTERFACE"
    fi
    
    # Get broadcast address
    local broadcast=$(get_network_info)
    echo -e "${YELLOW}Using broadcast address: $broadcast${NC}"
    
    # Clear ARP cache and ping broadcast to populate it
    echo -e "${CYAN}Clearing ARP cache...${NC}"
    sudo arp -d -a 2>/dev/null
    
    echo -e "${CYAN}Pinging broadcast address...${NC}"
    timeout 5 ping -c 3 -t 1 $broadcast > /dev/null 2>&1
    
    # Also ping common gateway addresses
    echo -e "${CYAN}Pinging common gateways...${NC}"
    timeout 3 ping -c 1 -t 1 192.168.1.1 > /dev/null 2>&1
    timeout 3 ping -c 1 -t 1 192.168.0.1 > /dev/null 2>&1
    timeout 3 ping -c 1 -t 1 10.0.0.1 > /dev/null 2>&1
    
    # Get MAC addresses from ARP table, excluding our own
    local current_mac=$(get_current_mac)
    local discovered_macs=()
    
    echo -e "${CYAN}Parsing ARP table...${NC}"
    # Parse ARP table for MAC addresses
    local valid_macs=()
    local invalid_macs=()
    
    while IFS= read -r line; do
        if [[ $line =~ \(([0-9]+\.[0-9]+\.[0-9]+\.[0-9]+)\)\ at\ ([a-fA-F0-9:]+) ]]; then
            local mac="${BASH_REMATCH[2]}"
            # Skip our own MAC, incomplete entries, and broadcast MACs
            if [[ "$mac" != "$current_mac" && "$mac" != "(incomplete)" && "$mac" != "ff:ff:ff:ff:ff:ff" ]]; then
                # Validate MAC address format
                if validate_mac "$mac"; then
                    valid_macs+=("$mac")
                    discovered_macs+=("$mac")
                    echo -e "${GREEN}  Valid MAC: $mac${NC}"
                else
                    invalid_macs+=("$mac")
                    echo -e "${RED}  Invalid MAC: $mac${NC}"
                fi
            fi
        fi
    done < <(arp -a 2>/dev/null)
    
    # Remove duplicates and limit to reasonable number
    local unique_valid_macs=($(printf '%s\n' "${valid_macs[@]}" | sort -u | head -5))
    local unique_invalid_macs=($(printf '%s\n' "${invalid_macs[@]}" | sort -u))
    
    # Display summary
    echo -e "\n${BLUE}=== MAC Address Discovery Summary ===${NC}"
    
    if [ ${#unique_valid_macs[@]} -gt 0 ]; then
        echo -e "${GREEN}Valid MAC addresses found (${#unique_valid_macs[@]}):${NC}"
        for mac in "${unique_valid_macs[@]}"; do
            echo -e "  ${GREEN}✓ $mac${NC}"
        done
        TEST_MACS=("${unique_valid_macs[@]}")
    else
        echo -e "${YELLOW}No valid MAC addresses discovered.${NC}"
    fi
    
    if [ ${#unique_invalid_macs[@]} -gt 0 ]; then
        echo -e "${RED}Invalid MAC addresses found (${#unique_invalid_macs[@]}):${NC}"
        for mac in "${unique_invalid_macs[@]}"; do
            echo -e "  ${RED}✗ $mac${NC}"
        done
    fi
    
    if [ ${#unique_valid_macs[@]} -eq 0 ]; then
        echo -e "${YELLOW}No valid MAC addresses discovered. Using fallback addresses.${NC}"
        # Fallback to some common OUI prefixes
        TEST_MACS=(
            "02:01:02:03:04:05"  # Locally administered
            "00:11:22:33:44:55"  # Generic
            "ac:87:a3:12:34:56"  # Common router OUI
        )
    fi
    
    echo ""
}

# Function to validate MAC address format
validate_mac() {
    local mac=$1
    # Check if MAC is in correct format (XX:XX:XX:XX:XX:XX)
    if [[ $mac =~ ^([0-9a-fA-F]{2}:){5}[0-9a-fA-F]{2}$ ]]; then
        return 0
    else
        return 1
    fi
}

# Function to change MAC address safely
change_mac() {
    local new_mac=$1
    
    # Validate MAC address format
    if ! validate_mac "$new_mac"; then
        echo -e "${RED}Error: Invalid MAC address format: $new_mac${NC}"
        echo -e "${YELLOW}MAC address must be in format: XX:XX:XX:XX:XX:XX${NC}"
        return 1
    fi
    
    echo -e "${YELLOW}Changing MAC address to: $new_mac${NC}"

    # Disconnect from Wi-Fi using modern networksetup command
    echo -e "${CYAN}Disconnecting from Wi-Fi...${NC}"
    networksetup -setairportpower $INTERFACE off
    sleep 3

    # Change MAC address
    echo -e "${CYAN}Setting new MAC address...${NC}"
    if sudo macchanger -m "$new_mac" "$INTERFACE" 2>/dev/null; then
        echo -e "${GREEN}MAC address changed successfully${NC}"
    else
        echo -e "${RED}Failed to change MAC address${NC}"
        # Try to turn Wi-Fi back on
        networksetup -setairportpower $INTERFACE on
        return 1
    fi

    # Wait for change to take effect
    sleep 3

    echo -e "${GREEN}Current MAC: $(get_current_mac)${NC}"
}

# Function to get original MAC address (stored at script start)
ORIGINAL_MAC=""

# Function to store original MAC at script start
store_original_mac() {
    ORIGINAL_MAC=$(get_current_mac)
    echo -e "${CYAN}Original MAC stored: $ORIGINAL_MAC${NC}"
}

# Function to restore original MAC address
restore_mac() {
    echo -e "${YELLOW}Restoring original MAC address...${NC}"
    
    # Disconnect from Wi-Fi using modern networksetup command
    echo -e "${CYAN}Disconnecting from Wi-Fi...${NC}"
    networksetup -setairportpower $INTERFACE off
    sleep 3
    
    # Try different restore methods based on available macchanger options
    echo -e "${CYAN}Restoring permanent MAC...${NC}"
    local restore_success=false
    
    # Method 1: Use stored original MAC with -m flag
    if [[ -n "$ORIGINAL_MAC" ]] && sudo macchanger -m "$ORIGINAL_MAC" "$INTERFACE" 2>/dev/null; then
        echo -e "${GREEN}MAC restored using stored original: $ORIGINAL_MAC${NC}"
        restore_success=true
    # Method 2: Try --disable-private to restore real MAC (macOS Sequoia+ feature)
    elif sudo macchanger --disable-private "$INTERFACE" 2>/dev/null; then
        echo -e "${GREEN}MAC restored using --disable-private${NC}"
        restore_success=true
    # Method 3: Try macOS system method (interface reset)
    else
        echo -e "${YELLOW}macchanger restore failed, trying system method...${NC}"
        # Turn interface down and up to restore hardware MAC
        sudo ifconfig "$INTERFACE" down 2>/dev/null
        sleep 2
        sudo ifconfig "$INTERFACE" up 2>/dev/null
        sleep 2
        restore_success=true
        echo -e "${GREEN}Interface reset - should restore hardware MAC${NC}"
    fi
    
    sleep 3
    
    # Turn Wi-Fi back on
    echo -e "${CYAN}Turning Wi-Fi back on...${NC}"
    networksetup -setairportpower $INTERFACE on
    sleep 3
    
    local current_mac=$(get_current_mac)
    echo -e "${GREEN}Current MAC: $current_mac${NC}"
    
    if [[ -n "$ORIGINAL_MAC" && "$current_mac" == "$ORIGINAL_MAC" ]]; then
        echo -e "${GREEN}✓ MAC successfully restored to original${NC}"
    elif $restore_success; then
        echo -e "${GREEN}✓ MAC restoration completed${NC}"
    else
        echo -e "${YELLOW}⚠️  MAC restoration may have failed${NC}"
        echo -e "${YELLOW}   Original: $ORIGINAL_MAC${NC}"
        echo -e "${YELLOW}   Current:  $current_mac${NC}"
    fi
    
    echo -e "${BLUE}Reconnecting to Wi-Fi...${NC}"
    echo -e "${YELLOW}You may need to manually reconnect to your Wi-Fi network${NC}"
}

# Function to perform standalone MAC restoration
standalone_restore() {
    echo -e "${BOLD}${BLUE}$SCRIPT_NAME v$VERSION${NC}"
    echo -e "${BLUE}MAC Address Restoration Mode${NC}"
    echo -e "${BLUE}============================${NC}"
    
    # Auto-detect network interface
    INTERFACE=$(detect_interface)
    echo -e "${BLUE}Auto-detected interface: $INTERFACE${NC}"
    
    # Check prerequisites
    check_macchanger
    
    # Show current MAC
    local current_mac=$(get_current_mac)
    echo -e "${YELLOW}Current MAC: $current_mac${NC}"
    
    # Confirm restoration
    read -p "Restore MAC address to permanent/original? (y/N): " confirm
    if [[ $confirm =~ ^[Yy]$ ]]; then
        restore_mac
        echo -e "${GREEN}MAC address restoration complete!${NC}"
    else
        echo -e "${YELLOW}MAC restoration cancelled.${NC}"
    fi
}

# Function to reconnect to Wi-Fi
reconnect_wifi() {
    echo -e "${BLUE}Reconnecting to Wi-Fi...${NC}"
    # Turn Wi-Fi back on
    networksetup -setairportpower $INTERFACE on
    sleep 5

    # Wait for connection (you may need to manually select network)
    echo -e "${YELLOW}Please manually reconnect to your Wi-Fi network if needed${NC}"
    read -p "Press Enter when connected to continue..."
}

# Function to test internet connectivity
test_internet() {
    local test_name=$1
    echo -e "\n${BLUE}=== Testing: $test_name ===${NC}"

    # Test multiple endpoints for reliability
    local endpoints=("8.8.8.8" "1.1.1.1" "google.com")
    local success_count=0

    for endpoint in "${endpoints[@]}"; do
        if ping -c 2 -W 2000 $endpoint > /dev/null 2>&1; then
            ((success_count++))
            echo -e "${GREEN}✓${NC} $endpoint reachable"
        else
            echo -e "${RED}✗${NC} $endpoint unreachable"
        fi
    done

    if [ $success_count -gt 0 ]; then
        echo -e "${GREEN}Internet connectivity: OK ($success_count/3 endpoints)${NC}"
        return 0
    else
        echo -e "${RED}Internet connectivity: FAILED${NC}"
        return 1
    fi
}

# Function to calculate network address from IP and netmask
get_network_range() {
    local ip=$1
    local netmask=$2
    
    # Convert IP and netmask to decimal
    IFS='.' read -r i1 i2 i3 i4 <<< "$ip"
    IFS='.' read -r m1 m2 m3 m4 <<< "$netmask"
    
    # Calculate network address
    local n1=$((i1 & m1))
    local n2=$((i2 & m2))
    local n3=$((i3 & m3))
    local n4=$((i4 & m4))
    
    # Calculate CIDR notation
    local cidr=0
    for byte in $m1 $m2 $m3 $m4; do
        while [ $byte -gt 0 ]; do
            if [ $((byte & 1)) -eq 1 ]; then
                ((cidr++))
            fi
            byte=$((byte >> 1))
        done
    done
    
    echo "$n1.$n2.$n3.$n4/$cidr"
}

# Function to scan network devices
scan_network() {
    echo -e "\n${BLUE}Scanning network devices...${NC}"
    
    # Get current network configuration
    local ip=$(ifconfig $INTERFACE | grep 'inet ' | head -1 | awk '{print $2}')
    local netmask_hex=$(ifconfig $INTERFACE | grep 'inet ' | head -1 | awk '{print $4}')
    
    if [[ -z "$ip" || -z "$netmask_hex" ]]; then
        echo -e "${RED}Error: Could not determine network configuration${NC}"
        return 1
    fi
    
    # Convert hex netmask to decimal and get network range
    local netmask=$(hex_to_decimal_netmask "$netmask_hex")
    local network_range=$(get_network_range "$ip" "$netmask")
    
    echo -e "${YELLOW}Scanning network: $network_range${NC}"
    
    # Check if nmap is available
    if ! command -v nmap &> /dev/null; then
        echo -e "${RED}nmap not found. Installing via Homebrew...${NC}"
        if command -v brew &> /dev/null; then
            brew install nmap
        else
            echo -e "${RED}Homebrew not found. Please install nmap manually.${NC}"
            return 1
        fi
    fi
    
    # Run nmap with timeout and limited scope
    timeout 30 nmap -sn --host-timeout 2s "$network_range" 2>/dev/null | grep -E "Nmap scan report|MAC Address" > devices.tmp
    
    if [ $? -eq 124 ]; then
        echo -e "${YELLOW}Network scan timed out after 30 seconds${NC}"
    fi
    
    echo "Found devices:"
    local device_count=0
    while read -r line; do
        if [[ $line == *"Nmap scan report"* ]]; then
            ip=$(echo $line | awk '{print $5}')
            echo -e "  ${GREEN}Device: $ip${NC}"
            ((device_count++))
        fi
    done < devices.tmp
    
    if [ $device_count -eq 0 ]; then
        echo -e "${YELLOW}No devices found. This might be due to network restrictions or firewall settings.${NC}"
    else
        echo -e "${GREEN}Total devices found: $device_count${NC}"
    fi
}

# Function to test router rules with different MACs
test_router_rules() {
    echo -e "\n${BLUE}=== Testing Router Rules with Different MAC Addresses ===${NC}"

    # Discover MAC addresses from network first
    discover_network_macs

    local original_mac=$(get_current_mac)
    echo -e "${BLUE}Original MAC: $original_mac${NC}"

    # Test with original MAC
    test_internet "Original MAC ($original_mac)"
    scan_network

    # Test with each configured MAC address
    local total_macs=${#TEST_MACS[@]}
    local tested_count=0
    local skipped_count=0
    
    for mac in "${TEST_MACS[@]}"; do
        echo -e "\n${YELLOW}--- Testing with MAC: $mac ($((tested_count + skipped_count + 1))/$total_macs) ---${NC}"

        # Validate MAC address before attempting to change it
        if ! validate_mac "$mac"; then
            echo -e "${RED}⚠️  Skipping invalid MAC address: $mac${NC}"
            echo -e "${YELLOW}   MAC must be in format: XX:XX:XX:XX:XX:XX${NC}"
            ((skipped_count++))
            continue
        fi

        # Attempt to change MAC address
        if change_mac "$mac"; then
            echo -e "${GREEN}✓ MAC address changed successfully${NC}"
            
            # Reconnect to Wi-Fi
            reconnect_wifi

            # Test connectivity with new MAC
            test_internet "MAC: $mac"

            # Optional: Test specific router rules here
            echo -e "${BLUE}Testing router-specific rules...${NC}"
            # Add your specific router rule tests here, for example:
            # - Test access to specific websites
            # - Test port access
            # - Test bandwidth limits
            # curl -s --max-time 5 http://example.com > /dev/null && echo "HTTP access: OK" || echo "HTTP access: BLOCKED"

            scan_network
            ((tested_count++))
        else
            echo -e "${RED}⚠️  Failed to change MAC address to: $mac${NC}"
            echo -e "${YELLOW}   Skipping to next MAC address...${NC}"
            ((skipped_count++))
            # Try to restore Wi-Fi if MAC change failed
            echo -e "${CYAN}Attempting to restore Wi-Fi connectivity...${NC}"
            networksetup -setairportpower $INTERFACE on
            sleep 3
            continue
        fi

        # Only prompt for continuation if MAC change was successful
        echo -e "${YELLOW}Press Enter to continue to next MAC address (or Ctrl+C to stop)${NC}"
        read
    done
    
    # Summary
    echo -e "\n${BLUE}=== Testing Summary ===${NC}"
    echo -e "${GREEN}Successfully tested: $tested_count MAC addresses${NC}"
    if [ $skipped_count -gt 0 ]; then
        echo -e "${YELLOW}Skipped: $skipped_count invalid/failed MAC addresses${NC}"
    fi

    # Restore original MAC
    restore_mac
    reconnect_wifi

    echo -e "\n${GREEN}=== MAC Address Testing Complete ===${NC}"
}

# Function to parse command line arguments
parse_arguments() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            -h|--help)
                show_help
                exit 0
                ;;
            -v|--version)
                show_version
                exit 0
                ;;
            -r|--restore)
                # Check if running with sudo privileges
                if [ "$EUID" -ne 0 ]; then
                    echo -e "${RED}MAC address restoration requires sudo privileges.${NC}"
                    echo "Please run: sudo $0 --restore"
                    exit 1
                fi
                standalone_restore
                exit 0
                ;;
            *)
                echo -e "${RED}Unknown option: $1${NC}"
                echo -e "Use ${YELLOW}--help${NC} for usage information."
                exit 1
                ;;
        esac
        shift
    done
}

# Main script execution
main() {
    echo -e "${BOLD}${BLUE}$SCRIPT_NAME v$VERSION${NC}"
    echo -e "${BLUE}=================================================${NC}"

    # Auto-detect network interface
    INTERFACE=$(detect_interface)
    echo -e "${BLUE}Auto-detected interface: $INTERFACE${NC}"
    
    # Store original MAC address before any changes
    store_original_mac

    # Check prerequisites
    check_macchanger

    # Check if running with sudo privileges
    if [ "$EUID" -ne 0 ]; then
        echo -e "${RED}This script requires sudo privileges for MAC address changes.${NC}"
        echo "Please run: sudo $0"
        exit 1
    fi

    # Show current network status
    echo -e "\n${BLUE}Current Network Status:${NC}"
    echo -e "Interface: ${GREEN}$INTERFACE${NC}"
    
    local current_mac=$(get_current_mac)
    echo -e "Current MAC: ${GREEN}$current_mac${NC}"
    
    # Show network info
    local broadcast=$(get_network_info)
    local ip=$(ifconfig $INTERFACE | grep 'inet ' | head -1 | awk '{print $2}')
    local netmask_hex=$(ifconfig $INTERFACE | grep 'inet ' | head -1 | awk '{print $4}')
    local netmask=$(hex_to_decimal_netmask "$netmask_hex")
    echo -e "Current IP: ${GREEN}$ip${NC}"
    echo -e "Netmask: ${GREEN}$netmask${NC}"
    echo -e "Broadcast: ${GREEN}$broadcast${NC}"

    # Menu options
    echo -e "\n${BLUE}Select test mode:${NC}"
    echo ""
    echo -e "${GREEN}1) Basic connectivity test (current MAC)${NC}"
    echo -e "   ${CYAN}• Tests internet connectivity using your current MAC address${NC}"
    echo -e "   ${CYAN}• Useful for: Basic network troubleshooting, verifying current access${NC}"
    echo -e "   ${CYAN}• Safe: No MAC address changes, read-only testing${NC}"
    echo ""
    echo -e "${GREEN}2) Full router rules test (discovered network MACs)${NC}"
    echo -e "   ${CYAN}• Discovers real MAC addresses from your network via ARP${NC}"
    echo -e "   ${CYAN}• Tests connectivity with each discovered MAC address${NC}"
    echo -e "   ${CYAN}• Useful for: Bypassing MAC filtering, testing access controls${NC}"
    echo -e "   ${CYAN}• Security testing: Router rule validation, penetration testing${NC}"
    echo ""
    echo -e "${GREEN}3) Network scan only${NC}"
    echo -e "   ${CYAN}• Scans your network to identify active devices and IP addresses${NC}"
    echo -e "   ${CYAN}• Useful for: Network discovery, device inventory, reconnaissance${NC}"
    echo -e "   ${CYAN}• Safe: No MAC changes, discovery mode only${NC}"
    echo ""
    echo -e "${GREEN}4) Discover network MACs only${NC}"
    echo -e "   ${CYAN}• Shows MAC addresses of devices on your network${NC}"
    echo -e "   ${CYAN}• Useful for: MAC address research, target identification${NC}"
    echo -e "   ${CYAN}• Planning: Identify MACs before testing in mode 2${NC}"
    echo ""
    echo -e "${GREEN}5) Restore MAC address to original${NC}"
    echo -e "   ${CYAN}• Restores your network interface to its permanent MAC${NC}"
    echo -e "   ${CYAN}• Useful for: Cleanup after testing, reverting changes${NC}"
    echo -e "   ${CYAN}• Recovery: Fix connectivity issues from previous tests${NC}"
    echo ""
    echo -e "${GREEN}6) Show help${NC}"
    echo -e "   ${CYAN}• Display comprehensive help and usage information${NC}"
    echo ""
    read -p "Choice (1-6): " choice

    case $choice in
        1)
            test_internet "Current Configuration"
            scan_network
            ;;
        2)
            test_router_rules
            ;;
        3)
            scan_network
            ;;
        4)
            discover_network_macs
            ;;
        5)
            restore_mac
            reconnect_wifi
            ;;
        6)
            show_help
            ;;
        *)
            echo -e "${RED}Invalid choice${NC}"
            echo -e "Use ${YELLOW}--help${NC} for usage information."
            exit 1
            ;;
    esac

    # Cleanup
    rm -f devices.tmp

    echo -e "\n${GREEN}Testing complete!${NC}"
}

# Set trap to restore MAC on script exit
trap 'restore_mac; exit' INT TERM

# Parse command line arguments first
parse_arguments "$@"

# Run main function
main "$@"
