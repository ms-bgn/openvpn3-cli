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
CONFIG_FILE=$3

if [ -z "$ACTION" ] || [ -z "$CONFIG_NAME" ]; then
    echo "Usage: $0 <up|down> <config-name> [config-file]"
    exit 1
fi

# Default config-file to config-name.ovpn if not provided
if [ -z "$CONFIG_FILE" ]; then
    CONFIG_FILE="${CONFIG_NAME}.ovpn"
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
        
        echo "Checking if configuration '$CONFIG_NAME' is registered..."
        
        # Check if the config is already imported
        # This handles both table formats (name at start) and detailed views (Name: NAME)
        REG_STATUS=$(openvpn3 configs-list | grep -E "(^|[[:space:]])$CONFIG_NAME([[:space:]]|$)" || true)
        
        if [ -n "$REG_STATUS" ]; then
            echo "SUCCESS: Configuration '$CONFIG_NAME' is currently registered."
        else
            echo "NOTICE: Configuration '$CONFIG_NAME' not found in OpenVPN 3 configuration manager."
            echo "Attempting to locate $CONFIG_FILE in $VPN_CONFIG_DIR..."
            
            # Look for the .ovpn file
            OVPN_FILE="$VPN_CONFIG_DIR/$CONFIG_FILE"
            if [ -f "$OVPN_FILE" ]; then
                echo "Found $OVPN_FILE. Importing as '$CONFIG_NAME'..."
                vpn-import "$CONFIG_FILE" "$CONFIG_NAME"
                echo "SUCCESS: Configuration '$CONFIG_NAME' has been imported."
            else
                echo "ERROR: Configuration '$CONFIG_NAME' is not registered, and no source file was found at '$OVPN_FILE'."
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
    status)
        echo "--- VPN Status ---"
        vpn-status
        echo ""
        echo "--- Imported Profiles ---"
        openvpn3 configs-list
        ;;
    *)
        echo "Invalid action: $ACTION. Use 'up', 'down', or 'status'."
        exit 1
        ;;
esac
