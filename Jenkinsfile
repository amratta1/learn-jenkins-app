pipeline {
    agent any
    environment {
        NETLIFY_SITE_ID = '988a9df0-1a53-4224-87c7-dccf69b689fb'
        NETLIFY_AUTH_TOKEN = credentials('netlify-token')
        REACT_APP_VERSION = "1.0.$BUILD_ID"
    }

    stages {
        stage(aws){
           agent {
             docker {
              image 'amazon/aws-cli'
              args "--entrypoint=''"
             }
           }
           steps {
              withCredentials([usernamePassword(credentialsId: 'my-aws-access', passwordVariable: 'AWS_SECRET_ACCESS_KEY', usernameVariable: 'AWS_ACCESS_KEY_ID')]) {
             sh '''
              aws --version
              echo "Hello S3!" > index.html
              aws s3 cp index.html s3://learn-jenkins-amratta85/index.html 
              
             '''
            }
          }
        }
        stage('Build') {
            agent {
                docker {
                    image 'node:18-alpine'
                    reuseNode true
                    args '--user root'
                }
            }
            steps {
                sh '''
                    echo "Building the project..."
                    node --version
                    npm --version
                    npm install
                    npm ci
                    npm run build
                '''
            }
        }

        stage('Test') {
            parallel {
                stage('Unit Tests') {
                    agent {
                        docker {
                            image 'node:18-alpine'
                            reuseNode true
                            args '--user root:root'
                        }
                    }
                    steps {
                        sh '''
                            echo "Running Unit Tests..."
                            npm test
                        '''
                    }
                    post {
                        always {
                            junit 'jest-results/junit.xml'
                        }
                    }
                }

                stage('E2E ') {
                    agent {
                        docker {
                            image 'my-playwright'
                            reuseNode true
                            args '--user root:root'
                        }
                    }
                    steps {
                        sh '''
                            serve -s build &
                            sleep 10
                            npx playwright test --reporter=html
                        '''
                    }
                    post {
                        always {
                            publishHTML([
                                allowMissing: false, alwaysLinkToLastBuild: false, keepAll: false, reportDir: 'playwright-report', reportFiles: 'index.html', reportName: 'Playwright Local', 
                                reportTitles: '', useWrapperFileDirectly: true ])
                        }
                    }
                }
            }
        }

        stage('Deploy Staging') {
            agent {
                docker {
                    image 'my-playwright'
                    reuseNode true
                    args '--user root:root'
                }
            }
            environment {
                CI_ENVIRONMENT_URL = "Tobe Defined"
            }
            steps {
                sh '''
                    netlify --version
                    netlify status
                    netlify deploy --dir=build
                    netlify deploy --dir=build --json > deploy-output.json
                    CI_ENVIRONMENT_URL=$(node-jq -r '.deploy_url' deploy-output.json)
                    npx playwright test --reporter=html
                '''
            }

            post {
                always {
                    publishHTML([allowMissing: false,alwaysLinkToLastBuild: false,keepAll: false,reportDir: 'playwright-report',reportFiles: 'index.html', reportName: 'Staging E2E', 
                    reportTitles: '',useWrapperFileDirectly: true ])
                }
            }
         }

        stage('Deploy Prod') {
            agent {
                docker {
                    image 'my-playwright'
                    reuseNode true
                    args '--user root:root'
                }
            }
            environment {
                CI_ENVIRONMENT_URL = 'https://jenkins-amroo.netlify.app'
            }
            steps {
                sh '''
                    netlify --version
                    netlify status
                    netlify deploy --dir=build --prod
                    npx playwright test --reporter=html
                '''
            }
            post {
                always {
                    publishHTML([allowMissing: false, alwaysLinkToLastBuild: false, keepAll: false, reportDir: 'playwright-report', reportFiles: 'index.html', reportName: 'Production E2E', 
                    reportTitles: '', useWrapperFileDirectly: true ])
                }
            }
        }
    }
}
