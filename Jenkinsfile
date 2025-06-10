pipeline{
    agent any
    tools{
        maven "mvn"
    }
    environment{
        SCANNER_HOME = tool 'sqube-scanner'
    }
    stages{
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
        }
        stage('sonarqube code quality'){
            steps{
                withSonarQubeEnv('sqube-server') {
                     sh ''' ${SCANNER_HOME}/bin/sonar-scanner -Dsonar.projectKey=chatroom
                     -Dsonar.projectName=chatroom -Dsonar.java.binaries=target '''
                }
            }
        }

    }
}