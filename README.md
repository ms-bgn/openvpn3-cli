# OpenVPN 3 Bash Management Tools

A set of bash functions to simplify managing the OpenVPN 3 Linux client.

## Setup

1. Add the following line to your `~/.bashrc`:
   ```bash
   source /Users/rafi/Documents/biznetgio/openvpn3-cli/openvpn3_tools.sh
   ```
2. Reload your shell:
   ```bash
   source ~/.bashrc
   ```

## Available Commands

| Command | Usage | Description |
| :--- | :--- | :--- |
| `vpn-list` | `vpn-list` | Lists all imported configs and active sessions. |
| `vpn-up` | `vpn-up <name> [creds-file]` | Starts a VPN session. `creds-file` searched in `account/`. |
| `vpn-down` | `vpn-down <name> \| --all` | Disconnects a specific or all sessions. |
| `vpn-import` | `vpn-import <ovpn> <name>` | Imports an `.ovpn` from `config/` persistently. |
| `vpn-status` | `vpn-status` | Shows current session status. |
| `vpn-config-del` | `vpn-config-del <name>` | Deletes an imported configuration. |

## Automated Authentication

To use a credentials file, place a file in the `account/` folder (e.g., `account/work-creds.txt`):

```text
USERNAME="your_username"
PASSWORD="your_password"
```

Secure it and connect:
```bash
chmod 600 account/work-creds.txt
vpn-up my-vpn work-creds.txt
```

## Jenkins Integration

To integrate with Jenkins, use the provided `Jenkinsfile` and `jenkins_vpn_wrapper.sh`.

1.  **Credentials**: In Jenkins, create a "Username with password" credential with the ID `vpn-credentials`.
2.  **Job Setup**: Create a new Pipeline job and point it to the `Jenkinsfile` in this repository.
3.  **Parameters**: The pipeline includes parameters for the VPN action (`up`/`down`) and the config name.

For detailed setup instructions, see the walkthrough.
