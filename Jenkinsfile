pipeline {
    agent any

    stages {
        stage('Build') {
            agent {
                docker {
                    image 'node:18-alpine'
                    reuseNode true
                }
            }
            steps {
                sh '''
                    ls -la
                    node --version
                    npm --version
                    ls -la /
                    sudo chown -R $(whoami) ~/.npm
                    npm ci
                    npm run build 
                    ls -la
                '''
            }
        }
    }
}
