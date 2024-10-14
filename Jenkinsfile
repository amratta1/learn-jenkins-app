pipeline {
    agent any

    stages {
        stage('Build') {
            agent {
                docker {
                    image 'amratta85/node:app'
                    reuseNode true
                }
            }
            steps {
                sh '''
                    ls -la
                    node --version
                    npm --version
                    npm install
                    npm run build 
                    ls -la
                '''
            }
        }
    }
}
