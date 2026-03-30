pipeline {
    agent any

    parameters {
        choice(name: 'VPN_ACTION', choices: ['up', 'down', 'status'], description: 'Select the operation to perform')
    }

    stages {
        stage('Configure & Run VPN') {
            steps {
                script {
                    def vpnConfig = ""
                    def vpnFile = ""
                    def vpnCredId = ""

                    // Dynamic handling based on Action
                    if (params.VPN_ACTION == 'up') {
                        def userInput = input(
                            id: 'vpnInputUp', message: 'Enter details for VPN connection', parameters: [
                                string(name: 'VPN_CONFIG', defaultValue: 'ovpn_wjv_1@bs0000xx', description: 'The friendly name of the VPN config'),
                                string(name: 'VPN_FILE', defaultValue: 'ovpn_wjv_1.ovpn', description: 'The .ovpn filename'),
                                credentials(name: 'VPN_CREDENTIAL_ID', defaultValue: 'vpn-credentials', credentialType: "com.cloudbees.plugins.credentials.impl.UsernamePasswordCredentialsImpl", description: 'Select credentials', required: true)
                            ]
                        )
                        vpnConfig = userInput.VPN_CONFIG
                        vpnFile = userInput.VPN_FILE
                        vpnCredId = userInput.VPN_CREDENTIAL_ID
                    } else if (params.VPN_ACTION == 'down') {
                        def userInput = input(
                            id: 'vpnInputDown', message: 'Enter details to disconnect VPN', parameters: [
                                string(name: 'VPN_CONFIG', defaultValue: 'ovpn_wjv_1@bs0000xx', description: 'The friendly name of the VPN config to disconnect')
                            ]
                        )
                        vpnConfig = userInput.VPN_CONFIG
                    }

                    // Execution block
                    echo "Starting VPN action: ${params.VPN_ACTION}"
                    
                    if (params.VPN_ACTION == 'up') {
                        withCredentials([usernamePassword(credentialsId: vpnCredId, passwordVariable: 'VPN_PASSWORD', usernameVariable: 'VPN_USERNAME')]) {
                            sh "chmod +x ./jenkins_vpn_wrapper.sh"
                            sh "./jenkins_vpn_wrapper.sh up ${vpnConfig} ${vpnFile}"
                        }
                    } else if (params.VPN_ACTION == 'down') {
                        sh "chmod +x ./jenkins_vpn_wrapper.sh"
                        sh "./jenkins_vpn_wrapper.sh down ${vpnConfig}"
                    } else if (params.VPN_ACTION == 'status') {
                        sh "chmod +x ./jenkins_vpn_wrapper.sh"
                        sh "./jenkins_vpn_wrapper.sh status"
                    }
                }
            }
        }
    }

    post {
        always {
            echo "VPN process finished for action: ${params.VPN_ACTION}"
        }
    }
}
