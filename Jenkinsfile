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
                    id 
                    chown node:node -R .npm 
                    npm install
                    npm run build 
                    ls -la
                '''
            }
        }
    }
}
