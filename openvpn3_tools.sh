#!/bin/bash

# OpenVPN3 Management Tools
# Source this file in your .bashrc: source /path/to/openvpn3_tools.sh

# Directory paths
VPN_BASE_DIR="$WORKSPACE"
VPN_CONFIG_DIR="$VPN_BASE_DIR/config"
VPN_ACCOUNT_DIR="$VPN_BASE_DIR/account"

# Function: vpn-list
# Lists imported configurations and active sessions
vpn-list() {
    echo "--- Imported Configurations ---"
    openvpn3 configs-list
    echo ""
    echo "--- Active Sessions ---"
    openvpn3 sessions-list
}

# Function: vpn-up
# Starts a VPN session using a config name
# Usage: vpn-up <config-name> [creds-filename]
# creds-filename will be searched in $VPN_ACCOUNT_DIR
vpn-up() {
    if [ -z "$1" ]; then
        echo "Usage: vpn-up <config-name> [creds-filename]"
        return 1
    fi

    local config_name="$1"
    local creds_input="$2"
    local creds_file=""

    if [ -n "$creds_input" ]; then
        # Check if it's a full path or just a filename in the account folder
        if [[ "$creds_input" == /* || "$creds_input" == \~* ]]; then
            creds_file="$creds_input"
        else
            creds_file="$VPN_ACCOUNT_DIR/$creds_input"
        fi

        if [ ! -f "$creds_file" ]; then
            echo "Error: Credentials file '$creds_file' not found."
            return 1
        fi
        
        # Source the file in a subshell to get variables without polluting the current shell
        local user=$(grep "USERNAME=" "$creds_file" | cut -d'=' -f2 | sed 's/"//g')
        local pass=$(grep "PASSWORD=" "$creds_file" | cut -d'=' -f2 | sed 's/"//g')
        
        if [ -z "$user" ] || [ -z "$pass" ]; then
            echo "Error: Could not find USERNAME or PASSWORD in '$creds_file'."
            return 1
        fi
        
        echo "Starting VPN session for '$config_name' using credentials from '$creds_file'..."
        printf "%s\n%s\n" "$user" "$pass" | openvpn3 session-start --config "$config_name"
    else
        openvpn3 session-start --config "$config_name"
    fi
}

# Function: vpn-down
# Disconnects a VPN session by config name or --all
vpn-down() {
    if [ -z "$1" ]; then
        echo "Usage: vpn-down <config-name> | --all"
        return 1
    fi

    if [ "$1" == "--all" ]; then
        echo "Disconnecting all active sessions..."
        # Extract session paths and disconnect each
        openvpn3 sessions-list | grep "Path:" | awk '{print $2}' | while read -r path; do
            openvpn3 session-manage --session-path "$path" --disconnect
        done
    else
        openvpn3 session-manage --config "$1" --disconnect
    fi
}

# Function: vpn-import
# Imports an .ovpn file and gives it a persistent name
# Usage: vpn-import <ovpn-filename> <config-name>
# ovpn-filename will be searched in $VPN_CONFIG_DIR
vpn-import() {
    if [ "$#" -ne 2 ]; then
        echo "Usage: vpn-import <ovpn-filename> <config-name>"
        return 1
    fi
    
    local ovpn_input="$1"
    local config_name="$2"
    local ovpn_file=""

    if [[ "$ovpn_input" == /* || "$ovpn_input" == \~* ]]; then
        ovpn_file="$ovpn_input"
    else
        ovpn_file="$VPN_CONFIG_DIR/$ovpn_input"
    fi

    if [ ! -f "$ovpn_file" ]; then
        echo "Error: OVPN file '$ovpn_file' not found."
        return 1
    fi

    openvpn3 config-import --config "$ovpn_file" --name "$config_name" --persistent
}

# Function: vpn-status
# Shows details of active sessions
vpn-status() {
    openvpn3 sessions-list
}

# Function: vpn-config-del
# Deletes all imported configurations with the given name
vpn-config-del() {
    if [ -z "$1" ]; then
        echo "Usage: vpn-config-del <config-name>"
        return 1
    fi
    local config_name="$1"
    
    # Identify all configuration paths for this name accurately.
    # The output format can vary, but usually looks like:
    # ------------------------------------------------------------------------------
    # /net/openvpn/v3/configuration/...
    #   Name: ovpn_wjv_1
    # ------------------------------------------------------------------------------
    # OR sometimes name is first.
    
    local paths=$(openvpn3 configs-list | awk -v name="$config_name" '
        # Look for configuration paths
        /\/net\/openvpn\/v3\/configuration\// { 
            current_path = $0; 
            # Clean up leading/trailing whitespace
            gsub(/^[[:space:]]+|[[:space:]]+$/, "", current_path);
        }
        # If we see Name: match, record the last seen path
        /Name: [^ ]+/ && $2 == name { 
            if(current_path != "") { print current_path; current_path = "" }
        }
        # Fallback for if name is on same line as path or other formats
        $0 ~ name && /\/net\/openvpn\/v3\/configuration\// {
             match($0, /\/net\/openvpn\/v3\/configuration\/[^ ]+/);
             print substr($0, RSTART, RLENGTH);
        }
    ')
    
    if [ -z "$paths" ]; then
        # Last-ditch attempt: If no paths found, try to remove by name directly 
        # (will fail if duplicates exist, but it's our last shot)
        echo "No paths found for '$config_name', attempting removal by name..."
        openvpn3 config-remove --config "$config_name"
        return $?
    fi

    echo "Found multiple profiles for '$config_name'. Removing all..."
    for path in $paths; do
        echo "Removing: $path"
        openvpn3 config-remove --config "$path"
    done
}
