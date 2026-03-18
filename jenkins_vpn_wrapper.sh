#!/bin/bash

# Jenkins VPN Wrapper
# Allows non-interactive VPN connection using environment variables

VPN_TOOLS_PATH="$WORKSPACE/openvpn3-cli/openvpn3_tools.sh"

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
            echo "Error: VPN_USERNAME and VPN_PASSWORD environment variables must be set."
            exit 1
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
