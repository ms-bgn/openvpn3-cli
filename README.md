# OpenVPN 3 Management & Jenkins Integration

This repository provides a robust set of tools to manage the OpenVPN 3 Linux client. It includes both local bash profile shortcuts for daily terminal use, and an advanced, fully dynamic Jenkins pipeline for team-wide VPN access.

---

## 🚀 Jenkins Integration (Advanced UI)

The highlight of this repository is the robust Jenkins integration. It provides a secure, self-service "One-Click" VPN portal for your team, powered by the Active Choices Plugin.

### Features
* **Dynamic Form UI**: Fields intelligently appear or hide based on the action selected (e.g., File name and Credentials only appear when connecting).
* **Direct Credentials Lookup**: A dynamic dropdown automatically fetches and lists your available Jenkins credentials—no more typing credential IDs manually!
* **Smart Pre-checks**: The `jenkins_vpn_wrapper.sh` intelligently checks if a session is already running or already stopped before taking action, preventing pipeline failures.
* **Non-Interactive Authentication**: Passes Jenkins credentials directly into the OpenVPN 3 daemon securely.

### Setup Instructions

1. **Install Prerequisites in Jenkins**:
   * Install the [Active Choices Plugin](https://plugins.jenkins.io/uno-choice/).
   * Create a **"Username with password"** credential in Jenkins containing your VPN login details.
2. **Create the Job**:
   * Create a new "Pipeline" job in Jenkins.
   * Point the "Pipeline from SCM" to this repository and specify the `Jenkinsfile`.
3. **Important: First Run & Script Approval**:
   * **Run the pipeline once.** It will fail or skip the first time. This is mandatory to register the dynamic `properties` block.
   * Go to **Manage Jenkins > In-process Script Approval**.
   * You **must approve** the Groovy script signatures that query the `CredentialsProvider` and `Jenkins.instance`. Once approved, the UI dropdowns will populate correctly.
4. **Usage**:
   * Click **Build with Parameters**. Select `up`, `down`, or `status` and watch the form instantly adapt.

---

## 💻 Local Bash Tools

For users who prefer managing OpenVPN directly from their Linux terminal, this repo includes `openvpn3_tools.sh`.

### Setup
1. Add the following line to your `~/.bashrc` or `~/.zshrc`:
   ```bash
   source /path/to/openvpn3-cli/openvpn3_tools.sh
   ```
2. Reload your shell:
   ```bash
   source ~/.bashrc
   ```

### Command Reference

| Command | Usage | Description |
| :--- | :--- | :--- |
| `vpn-list` | `vpn-list` | Lists all imported configs and active sessions. |
| `vpn-up` | `vpn-up <name> [creds-file]` | Starts a VPN session. Automates auth if creds file provided. |
| `vpn-down` | `vpn-down <name> \| --all` | Disconnects a specific session or `--all` sessions. |
| `vpn-import` | `vpn-import <ovpn> <name>` | Imports an `.ovpn` file securely into the config manager. |
| `vpn-status` | `vpn-status` | Shows detailed current session status and IP. |
| `vpn-config-del` | `vpn-config-del <name>` | Deletes an imported configuration profile. |

### Automated Terminal Authentication
To avoid typing your password every time in the terminal, create an account file (e.g., `account/work-creds.txt`):
```text
USERNAME="your_username"
PASSWORD="your_password"
```
Secure the file and connect:
```bash
chmod 600 account/work-creds.txt
vpn-up my-vpn work-creds.txt
```

---

## 📁 Repository Structure

* **`Jenkinsfile`**: Declarative pipeline containing the dynamic Active Choices UI properties and execution steps.
* **`jenkins_vpn_wrapper.sh`**: The bridge script between Jenkins and OpenVPN. Handles pre-checks, credential mapping, and imports.
* **`openvpn3_tools.sh`**: The core bash functions used by both the local developer and the Jenkins wrapper.
* **`config/`**: Default directory for `.ovpn` profile files.
* **`account/`**: Default directory for local credential files (Exclude from version control).
