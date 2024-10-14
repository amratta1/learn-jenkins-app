pipeline {
    agent any

    stages {
        stage('Build') {
            agent {
                docker {
                    image 'node:18.20-alpine3.19'
                    reuseNode true
                }
            }
            steps {
                sh '''
                    ls -la
                    node --version
                    npm --version
                    npm ci
                    npm run build 
                    ls -la
                '''
            }
        }
    }
}
