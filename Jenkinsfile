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
                    mkdir /.npm
                    chown -R 992:989 /.npm
                    npm ci
                    npm run build 
                    ls -la
                '''
            }
        }
    }
}
