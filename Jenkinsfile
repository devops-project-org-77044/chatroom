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
    }
}