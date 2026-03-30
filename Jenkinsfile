properties([
    parameters([
        // 1. Action Selector (Active Choice)
        [$class: 'ChoiceParameter', 
         choiceType: 'PT_SINGLE_SELECT', 
         description: 'Select VPN operation', 
         filterLength: 1, 
         filterable: false, 
         name: 'VPN_ACTION', 
         randomName: 'choice-parameter-30303030', 
         script: [
             $class: 'GroovyScript', 
             fallbackScript: [sandbox: true, script: "return ['error']"], 
             script: [sandbox: true, script: "return ['up', 'down', 'status']"]
         ]
        ],

        // 2. Dynamic Config (Reactive Reference)
        [$class: 'DynamicReferenceParameter', 
         choiceType: 'ET_FORMATTED_HTML', 
         description: 'The friendly name of the VPN config', 
         name: 'VPN_CONFIG', 
         randomName: 'dynamic-reference-parameter-30303031', 
         referencedParameters: 'VPN_ACTION', 
         script: [
             $class: 'GroovyScript', 
             fallbackScript: [sandbox: true, script: "return ['error']"], 
             script: [sandbox: true, script: """
                if (VPN_ACTION.equals("up") || VPN_ACTION.equals("down")) {
                    return "<b>VPN Config friendly name</b><br><input name='value' value='ovpn_wjv_1@bs0000xx' class='setting-input' style='width:100%' type='text'>"
                }
                return ""
             """]
         ]
        ],

        // 3. Dynamic File (Reactive Reference for up)
        [$class: 'DynamicReferenceParameter', 
         choiceType: 'ET_FORMATTED_HTML', 
         description: 'The .ovpn filename', 
         name: 'VPN_FILE', 
         randomName: 'dynamic-reference-parameter-30303032', 
         referencedParameters: 'VPN_ACTION', 
         script: [
             $class: 'GroovyScript', 
             fallbackScript: [sandbox: true, script: "return ['error']"], 
             script: [sandbox: true, script: """
                if (VPN_ACTION.equals("up")) {
                    return "<b>.ovpn Filename</b><br><input name='value' value='ovpn_wjv_1.ovpn' class='setting-input' style='width:100%' type='text'>"
                }
                return ""
             """]
         ]
        ],

        // 4. Dynamic Credentials Dropdown (Reactive Reference for up)
        [$class: 'DynamicReferenceParameter', 
         choiceType: 'ET_FORMATTED_HTML', 
         description: 'Select VPN credentials', 
         name: 'VPN_CREDENTIAL_ID', 
         randomName: 'dynamic-reference-parameter-30303033', 
         referencedParameters: 'VPN_ACTION', 
         script: [
             $class: 'GroovyScript', 
             fallbackScript: [sandbox: true, script: "return ['error']"], 
             script: [sandbox: true, script: """
                if (VPN_ACTION.equals("up")) {
                    def instance = jenkins.model.Jenkins.instance
                    def creds = com.cloudbees.plugins.credentials.CredentialsProvider.lookupCredentials(
                        com.cloudbees.plugins.credentials.common.StandardUsernameCredentials.class,
                        instance,
                        hudson.security.ACL.SYSTEM,
                        null
                    )
                    
                    def options = creds.collect { "<option value='\${it.id}'>\${it.id} (\${it.description ?: 'No description'})</option>" }.join('')
                    return "<b>Select VPN Credentials</b><br><select name='value' class='setting-input' style='width:100%'>\${options}</select>"
                }
                return ""
             """]
         ]
        ]
    ])
])

pipeline {
    agent any

    stages {
        stage('VPN Management') {
            steps {
                script {
                    def action = params.VPN_ACTION
                    // Active Choices DynamicReferenceParameter often appends a trailing comma.
                    // We strip it here to ensure the values are clean strings.
                    def config = (params.VPN_CONFIG ?: "").split(',')[0]
                    def file = (params.VPN_FILE ?: "").split(',')[0]
                    def credId = (params.VPN_CREDENTIAL_ID ?: "").split(',')[0]

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
