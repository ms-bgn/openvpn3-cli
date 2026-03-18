#!/bin/bash

# Jenkins VPN Wrapper
# Allows non-interactive VPN connection using environment variables

VPN_TOOLS_PATH="$WORKSPACE/openvpn3_tools.sh"

if [ ! -f "$VPN_TOOLS_PATH" ]; then
    echo "Error: VPN tools script not found at $VPN_TOOLS_PATH"
    exit 1
fi

source "$VPN_TOOLS_PATH"

ACTION=$1
CONFIG_NAME=$2

if [ -z "$ACTION" ] || [ -z "$CONFIG_NAME" ]; then
    echo "Usage: $0 <up|down> <config-name>"
    exit 1
fi

case $ACTION in
    up)
        if [ -z "$VPN_USERNAME" ] || [ -z "$VPN_PASSWORD" ]; then
            echo "Error: VPN_USERNAME or VPN_PASSWORD environment variables are empty."
            echo "Check if the Credential ID in Jenkins matches and is 'Username with password' type."
            exit 1
        fi
        
        echo "Validating credentials..."
        echo "Username: ${VPN_USERNAME:0:1}*** (Length: ${#VPN_USERNAME})"
        echo "Password Length: ${#VPN_PASSWORD}"
        
        # Check if the config is already imported
        if ! openvpn3 configs-list | grep -q "Name: $CONFIG_NAME"; then
            echo "Config '$CONFIG_NAME' not found in imported list. Attempting to import from '$VPN_CONFIG_DIR'..."
            
            # Look for a .ovpn file that matches the name
            OVPN_FILE="$VPN_CONFIG_DIR/$CONFIG_NAME.ovpn"
            if [ -f "$OVPN_FILE" ]; then
                vpn-import "$CONFIG_NAME.ovpn" "$CONFIG_NAME"
            else
                echo "Error: Could not find '$OVPN_FILE' to import."
                exit 1
            fi
        fi

        echo "Starting VPN session for '$CONFIG_NAME'..."
        printf "%s\n%s\n" "$VPN_USERNAME" "$VPN_PASSWORD" | openvpn3 session-start --config "$CONFIG_NAME"
        ;;
    down)
        echo "Disconnecting VPN session for '$CONFIG_NAME'..."
        vpn-down "$CONFIG_NAME"
        ;;
    *)
        echo "Invalid action: $ACTION. Use 'up' or 'down'."
        exit 1
        ;;
esac
