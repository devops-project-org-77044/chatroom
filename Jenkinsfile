pipeline
{
    agent any
    tools{
        maven "mvn"
    }
    // environment{
    //     SCANNER_HOME = tool 'sqube-scanner'

    // }
    stages{
        stage('clean workspace') {
            steps{
                cleanWs()
                checkout scm // re-fetch your source code after cleaning
            }
        }
        stage('Compile'){
            steps{
                sh 'mvn clean compile -DskipTests'
            }
        }
        stage('package'){
            steps{
                sh 'mvn package -DskipTests'
            }
        }
        // stage('trivy file scan'){
        //     steps{
        //         sh 'trivy fs . --severity HIGH,CRITICAL --format json -o trivy-report.json'
        //     }
        //     post{
        //         always{
        //             sh ''' trivy convert \
        //             --format template --template "@/usr/local/share/trivy/templates/html.tpl" \
        //             -o trivy-report.html trivy-report.json
        //             '''
        //         }
        //     }
        // }
        // stage('sonarqube code quality'){
        //     steps{
        //         withSonarQubeEnv('sqube-server') {
        //             sh ''' ${SCANNER_HOME}/bin/sonar-scanner -Dsonar.projectKey=chatroom -Dsonar.projectName=chatroom -Dsonar.java.binaries=target '''
        //         }
        //     }
        // }
        // stage('dp check'){
        //     steps {
        //         withCredentials([string(credentialsId: 'nvd-api-key', variable: 'NVD-API-KEY')]) {
        //             dependencyCheck additionalArguments: '--scan ./ --disableYarnAudit --disableNodeAudit --nvdApiKey ${NVD-API-KEY}', odcInstallation: 'owasp'
        //         }
        //      }
        // }

        // stage('sonarqube quality gate'){
        //     steps{
        //         timeout(time: 1, unit: 'MINUTES') {
        //             waitForQualityGate abortPipeline: false, credentialsId: 'sqube-cred'
        //         }
        //     }
        // }
        stage('Docker build'){
            steps{
                sh 'docker build -t abdullah77044/chatroom .'
            }
        }
        // stage('Trivy image scan') {
        //     steps{
        //         sh ''' trivy image --severity LOW,MEDIUM,HIGH --format json -o trivy-image-HIGH-result.json --exit-code 0 abdullah77044/chatroom
        //          trivy image --severity CRITICAL --format json -o trivy-image-CRITICAL-result.json --exit-code 0 abdullah77044/chatroom'''
        //     }
        //     post{
        //         always {
        //             // Convert JSON results to HTML
        //             sh ''' trivy convert \
        //             --format template --template "@/usr/local/share/trivy/templates/html.tpl" \
        //             -o trivy-image-HIGH-result.html trivy-image-HIGH-result.json
        //             trivy convert \
        //             --format template --template "@/usr/local/share/trivy/templates/html.tpl" \
        //             -o trivy-image-CRITICAL-result.html trivy-image-CRITICAL-result.json '''
        //         }
        //     }
        // }
        stage('docker push'){
            steps{
                withDockerRegistry(credentialsId: 'docker-cred', url: 'https://index.docker.io/v1/')
                {
                    sh 'docker push abdullah77044/chatroom'
                }
            }
        }
        stage('deploy'){
            when{
                branch 'dev'
            }
            steps{
                sshagent(['ssh-cred']) {
                    withAWS(credentials: 'aws-cred' ,region: 'us-east-1') {
                        sh ''' ssh -o StrictHostKeyChecking=no ubuntu@44.204.181.165 "
                                docker stop chatroom-cont || true
                                docker rm chatroom-cont || true
                                docker rmi $(docker images -q) || true
                            
                                docker run --rm -itd --name chatroom-cont -p 8080:8080 abdullah77044/chatroom:${BUILD_NUMBER}
                            "
                            '''
                    }
                }
            }
        }
        stage("updating K8s files"){
            when{
                branch 'master'
            }
            steps{
                script{
                    def DOCKER_IMAGE = "abdullah77044/chatroom:${BUILD_NUMBER}"
                    def DEPLOYMENT_FILE = "kubernetes/chatroom-deploy.yaml"

                    sh 'git clone -b master https://github.com/devops-project-org-77044/chatroom-k8s.git'
                    dir('chatroom-k8s') {
                        // Update the YAML file
                        sh """
                            sed -i 's|image: abdullah77044/chatroom:.*|image: ${DOCKER_IMAGE}|g' ${DEPLOYMENT_FILE}
                        """

                        withCredentials([string(credentialsId: 'git-token', variable: 'GIT_TOKEN')]) {
                            sh """
                                git config --global user.name "Rancidwhale"
                                git config --global user.email "muhammadabdullah3602@gmail.com"
                                git add ${DEPLOYMENT_FILE}
                                git commit -m "Updated deployment image to ${DOCKER_IMAGE}"
                                git push https://${GIT_TOKEN}@ggithub.com/devops-project-org-77044/chatroom-k8s.git master
                            """
                        }
                    }
                }
            }
        }
    }
}