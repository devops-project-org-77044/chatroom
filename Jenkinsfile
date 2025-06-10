pipeline{
    agent any
    tools{
        maven "mvn"
    }
    stages{
        stage('Compile'){
            steps{
                sh 'mvn compile'
            }
        }
        stage('package'){
            steps{
                sh 'mvn package -DskipTests'
            }
        }
        stage('trivy file scan'){
            steps{
                sh 'trivy fs --severity HIGH,CRITICAL --format json -o trivy-report.json'
            }
        }
        
    }
}