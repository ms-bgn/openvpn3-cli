pipeline {
    agent any

    parameters {
        choice(name: 'VPN_ACTION', choices: ['up', 'down'], description: 'Start or stop the VPN')
        string(name: 'VPN_CONFIG', defaultValue: 'ovpn_wjv_1', description: 'The friendly name of the imported VPN config')
        credentials(name: 'VPN_CREDENTIAL_ID', defaultValue: 'vpn-credentials', credentialType: "com.cloudbees.plugins.credentials.impl.UsernamePasswordCredentialsImpl", description: 'Select the VPN credentials to use', required: true)
    }

    environment {
        // Use the credential ID from the parameter
        VPN_CREDS = credentials("${params.VPN_CREDENTIAL_ID}")
        VPN_USERNAME = "${env.VPN_CREDS_USR}"
        VPN_PASSWORD = "${env.VPN_CREDS_PSW}"
    }

    stages {
        stage('VPN Management') {
            steps {
                script {
                    sh "chmod +x ./jenkins_vpn_wrapper.sh"
                    sh "./jenkins_vpn_wrapper.sh ${params.VPN_ACTION} ${params.VPN_CONFIG}"
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
