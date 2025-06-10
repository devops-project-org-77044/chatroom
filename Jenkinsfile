pipeline{
    agent any
    tools{
        maven "mvn"
    }
    environment{
        SCANNER_HOME = tool 'sqube-scanner'

    }
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
        stage('trivy file scan'){
            steps{
                sh 'trivy fs . --severity HIGH,CRITICAL --format json -o trivy-report.json'
            }
            post{
                always{
                    sh ''' trivy convert \
                    --format template --template "@/usr/local/share/trivy/templates/html.tpl" \
                    -o trivy-report.html trivy-report.json
                    '''
                }
            }
        }
        stage('sonarqube code quality'){
            steps{
                withSonarQubeEnv('sqube-server') {
                    sh ''' ${SCANNER_HOME}/bin/sonar-scanner -Dsonar.projectKey=chatroom -Dsonar.projectName=chatroom -Dsonar.java.binaries=target '''
                }
            }
        }
        // stage('dp check'){
        //     steps {
        //         withCredentials([string(credentialsId: 'nvd-api-key', variable: 'NVD-API-KEY')]) {
        //             dependencyCheck additionalArguments: '--scan ./ --disableYarnAudit --disableNodeAudit --nvdApiKey ${NVD-API-KEY}', odcInstallation: 'owasp'
        //         }
        //      }
        // }

        stage('sonarqube quality gate'){
            steps{
                timeout(time: 1, unit: 'MINUTES') {
                    waitForQualityGate abortPipeline: false, credentialsId: 'sqube-cred'
                }
            }
        }
        stage('Docker build'){
            steps{
                sh 'docker build -t abdullah77044/chatroom .'
            }
        }
        stage('Trivy image scan') {
            steps{
                sh ''' trivy image --severity LOW,MEDIUM,HIGH --format json -o trivy-image-HIGH-result.json --exit-code 0 abdullah77044/chatroom
                 trivy image --severity CRITICAL --format json -o trivy-image-CRITICAL-result.json --exit-code 0 abdullah77044/chatroom'''
            }
            post{
                always {
                    // Convert JSON results to HTML
                    sh ''' trivy convert \
                    --format template --template "@/usr/local/share/trivy/templates/html.tpl" \
                    -o trivy-image-HIGH-result.html trivy-image-HIGH-result.json
                    trivy convert \
                    --format template --template "@/usr/local/share/trivy/templates/html.tpl" \
                    -o trivy-image-CRITICAL-result.html trivy-image-CRITICAL-result.json '''
                }
            }
        }
        stage('docker push'){
            steps{
                withDockerRegistry(credentialsId: 'docker-cred') {
                    sh 'docker push abdullah77044/chatroom'
                }
            }
        }
        stage('deploy'){
            steps{
                sshagent(['ssh-cred']) {
                    withAWS(credentials: 'aws-cred' ,region: 'us-east-1') {
                        sh ''' ssh -o StrictHostKeyChecking=no ubuntu@54.227.84.201 "
                                docker stop chatroom-app || true
                                docker rm chatroom-app || true
                                docker rmi $(docker images -q) || true
                            
                                docker run --rm -itd --name chatroom-cont -p 8080:8080 abdullah77044/chatroom:${BUILD_NUMBER}
                            "
                            '''
                    }
                }
            }
        }
    }
}