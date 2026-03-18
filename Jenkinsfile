pipeline {
    agent any

    parameters {
        choice(name: 'VPN_ACTION', choices: ['up', 'down'], description: 'Start or stop the VPN')
        string(name: 'VPN_CONFIG', defaultValue: 'work-vpn', description: 'The friendly name of the imported VPN config')
    }

    environment {
        // Assume credentials with ID 'vpn-credentials' are stored in Jenkins
        VPN_CREDS = credentials('vpn-credentials')
        // Extract username and password from the credentials object
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
