pipeline {
    agent any

    parameters {
        // 1. Action Selector
        activeChoice(name: 'VPN_ACTION', 
            choiceType: 'PT_SINGLE_SELECT', 
            description: 'Select VPN operation',
            script: groovyScript(script: "return ['up', 'down', 'status']")
        )

        // 2. Dynamic Config Field (Shown for 'up' and 'down')
        activeChoiceReactiveReference(name: 'VPN_CONFIG', 
            referencedParameters: 'VPN_ACTION', 
            choiceType: 'ET_FORMAT_HTML', 
            script: groovyScript(script: """
                if (VPN_ACTION == 'up' || VPN_ACTION == 'down') {
                    return "<b>VPN Config friendly name</b><br><input name='value' value='ovpn_wjv_1@bs0000xx' class='setting-input' type='text'>"
                }
                return ""
            """)
        )

        // 3. Dynamic File Field (Shown only for 'up')
        activeChoiceReactiveReference(name: 'VPN_FILE', 
            referencedParameters: 'VPN_ACTION', 
            choiceType: 'ET_FORMAT_HTML', 
            script: groovyScript(script: """
                if (VPN_ACTION == 'up') {
                    return "<b>.ovpn Filename</b><br><input name='value' value='ovpn_wjv_1.ovpn' class='setting-input' type='text'>"
                }
                return ""
            """)
        )

        // 4. Dynamic Credentials Dropdown (Shown only for 'up')
        // Note: Using a reactive reference for the dropdown since standard credentials parameter cannot be hidden.
        activeChoiceReactiveReference(name: 'VPN_CREDENTIAL_ID', 
            referencedParameters: 'VPN_ACTION', 
            choiceType: 'ET_FORMAT_HTML', 
            script: groovyScript(script: """
                if (VPN_ACTION == 'up') {
                    // In a production environment, you would use Jenkins API to list credentials here.
                    // For now, we provide a text entry that defaults to 'vpn-credentials'.
                    return "<b>VPN Credentials ID</b><br><input name='value' value='vpn-credentials' class='setting-input' type='text'>"
                }
                return ""
            """)
        )
    }

    stages {
        stage('VPN Management') {
            steps {
                script {
                    def action = params.VPN_ACTION
                    def config = params.VPN_CONFIG ?: ""
                    def file = params.VPN_FILE ?: ""
                    def credId = params.VPN_CREDENTIAL_ID ?: ""

                    echo "Action: ${action}"

                    if (action == 'up') {
                        withCredentials([usernamePassword(credentialsId: credId, passwordVariable: 'VPN_PASSWORD', usernameVariable: 'VPN_USERNAME')]) {
                            sh "chmod +x ./jenkins_vpn_wrapper.sh"
                            sh "./jenkins_vpn_wrapper.sh up ${config} ${file}"
                        }
                    } else if (action == 'down') {
                        sh "chmod +x ./jenkins_vpn_wrapper.sh"
                        sh "./jenkins_vpn_wrapper.sh down ${config}"
                    } else if (action == 'status') {
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
