pipeline {
    agent any

    parameters {
        choice(name: 'VPN_ACTION', choices: ['up', 'down', 'status'], description: 'Start or stop the VPN, or check status')
        string(name: 'VPN_CONFIG', defaultValue: 'ovpn_wjv_1@bs0000xx', description: 'The friendly name of the imported VPN config')
        string(name: 'VPN_FILE', defaultValue: 'ovpn_wjv_1.ovpn', description: 'The .ovpn filename in the config/ directory')
        credentials(name: 'VPN_CREDENTIAL_ID', defaultValue: 'vpn-credentials', credentialType: "com.cloudbees.plugins.credentials.impl.UsernamePasswordCredentialsImpl", description: 'Select the VPN credentials to use', required: true)
    }

    stages {
        stage('VPN Management') {
            steps {
                script {
                    withCredentials([usernamePassword(credentialsId: params.VPN_CREDENTIAL_ID, passwordVariable: 'VPN_PASSWORD', usernameVariable: 'VPN_USERNAME')]) {
                        sh "chmod +x ./jenkins_vpn_wrapper.sh"
                        sh "./jenkins_vpn_wrapper.sh ${params.VPN_ACTION} ${params.VPN_CONFIG} ${params.VPN_FILE}"
                    }
                }
            }
        }
    }

    post {
        always {
            echo "VPN process finished."
        }
    }
}
