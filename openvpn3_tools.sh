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
    
    # Get all configuration paths for this name
    # OpenVPN 3 configs-list output format usually contains the name followed by the path or can be queried.
    # To be safe, we use 'openvpn3 configs-list' and grep for the requested name, then extract paths.
    # Note: openvpn3 configs-list output can vary, but usually 'openvpn3 config-remove --config NAME' 
    # fails if duplicates exist. Systematically removing by path is safer.
    
    local paths=$(openvpn3 configs-list | grep -A 1 "Name: $config_name$" | grep "Config path:" | awk '{print $3}')
    
    if [ -z "$paths" ]; then
        # Fallback for different output formats or if name is used directly in older versions
        echo "Searching for configurations named '$config_name'..."
        # If openvpn3 config-remove fails with name, we try to find paths more aggressively
        # Some versions show 'Configuration path: ...' on the line after 'Name: ...'
        paths=$(openvpn3 configs-list | grep -B 1 -E "^$config_name\s+" | grep -o "/net/openvpn/v3/configuration/[^ ]*")
        
        if [ -z "$paths" ]; then
            # One last try using a broad grep if the above fails
            paths=$(openvpn3 configs-list | grep "$config_name" | awk '{print $1}' | while read -r name; [ "$name" == "$config_name" ] && echo "match")
            # If we still can't find paths, we might have to rely on the user or a different command.
            # But usually, openvpn3 configs-list shows paths.
            echo "Error: Could not find unique paths for '$config_name'. You may need to remove them manually using 'openvpn3 config-remove --config <PATH>'."
            return 1
        fi
    fi

    echo "Found multiple profiles for '$config_name'. Removing all..."
    for path in $paths; do
        echo "Removing: $path"
        openvpn3 config-remove --config "$path"
    done
}
