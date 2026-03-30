pipeline {
    agent any

    parameters {
        // 1. Action Selector (Active Choice)
        [$class: 'ChoiceParameter', 
         name: 'VPN_ACTION', 
         choiceType: 'PT_SINGLE_SELECT', 
         description: 'Select VPN operation', 
         script: [
             $class: 'GroovyScript', 
             fallbackScript: [sandbox: true, script: "return ['error']"],
             script: [sandbox: true, script: "return ['up', 'down', 'status']"]
         ]
        ]

        // 2. Dynamic Config Field (Reactive Reference for up/down)
        [$class: 'CascadeChoiceParameter', 
         name: 'VPN_CONFIG', 
         referencedParameters: 'VPN_ACTION', 
         choiceType: 'ET_FORMAT_HTML', 
         description: 'The friendly name of the VPN config', 
         script: [
             $class: 'GroovyScript', 
             fallbackScript: [sandbox: true, script: "return ['error']"],
             script: [sandbox: true, script: """
                if (VPN_ACTION == 'up' || VPN_ACTION == 'down') {
                    return '<b>VPN Config friendly name</b><br><input name="value" value="ovpn_wjv_1@bs0000xx" class="setting-input" style="width:100%" type="text">'
                }
                return ""
             """]
         ]
        ]

        // 3. Dynamic File Field (Reactive Reference for up)
        [$class: 'CascadeChoiceParameter', 
         name: 'VPN_FILE', 
         referencedParameters: 'VPN_ACTION', 
         choiceType: 'ET_FORMAT_HTML', 
         description: 'The .ovpn filename', 
         script: [
             $class: 'GroovyScript', 
             fallbackScript: [sandbox: true, script: "return ['error']"],
             script: [sandbox: true, script: """
                if (VPN_ACTION == 'up') {
                    return '<b>.ovpn Filename</b><br><input name="value" value="ovpn_wjv_1.ovpn" class="setting-input" style="width:100%" type="text">'
                }
                return ""
             """]
         ]
        ]

        // 4. Dynamic Credentials ID Field (Reactive Reference for up)
        [$class: 'CascadeChoiceParameter', 
         name: 'VPN_CREDENTIAL_ID', 
         referencedParameters: 'VPN_ACTION', 
         choiceType: 'ET_FORMAT_HTML', 
         description: 'Select credentials', 
         script: [
             $class: 'GroovyScript', 
             fallbackScript: [sandbox: true, script: "return ['error']"],
             script: [sandbox: true, script: """
                if (VPN_ACTION == 'up') {
                    // Manual entry for ID - defaults to vpn-credentials
                    return '<b>VPN Credentials ID</b><br><input name="value" value="vpn-credentials" class="setting-input" style="width:100%" type="text">'
                }
                return ""
             """]
         ]
        ]
    }

    stages {
        stage('VPN Management') {
            steps {
                script {
                    def action = params.VPN_ACTION
                    def config = params.VPN_CONFIG ?: ""
                    def file = params.VPN_FILE ?: ""
                    def credId = params.VPN_CREDENTIAL_ID ?: ""

                    echo "Starting VPN action: ${action}"

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
