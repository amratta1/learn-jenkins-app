pipeline {
    agent any
    environment {
        NETLIFY_SITE_ID = '988a9df0-1a53-4224-87c7-dccf69b689fb'
        NETLIFY_AUTH_TOKEN = credentials('netlify-token')
    }

    stages {
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
                    ls -la
                    node --version
                    npm --version
                    npm install
                    npm ci
                    npm run build
                    ls -la
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
                            args '--user root'
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

                stage('E2E Tests') {
                    agent {
                        docker {
                            image 'mcr.microsoft.com/playwright:v1.49.1-noble'
                            reuseNode true
                            args '--user root:root'
                        }
                    }
                    steps {
                        sh '''
                            echo "Running E2E Tests..."
                            npm install serve
                            node_modules/.bin/serve -s build &
                            sleep 10
                            npx playwright test --reporter=html
                        '''
                    }
                    post {
                        always {
                            publishHTML([
                                allowMissing: false, 
                                alwaysLinkToLastBuild: false, 
                                keepAll: false, 
                                reportDir: 'playwright-report', 
                                reportFiles: 'index.html', 
                                reportName: 'Playwright Local', 
                                reportTitles: '', 
                                useWrapperFileDirectly: true
                            ])
                        }
                    }
                }
            }
        }

        stage('Deploy to Staging') {
            agent {
                docker {
                    image 'node:18-alpine'
                    reuseNode true
                    args '--user root'
                }
            }
            steps {
                sh '''
                    echo "Deploying to Staging..."
                    npm install netlify-cli node-jq
                    node_modules/.bin/netlify --version
                    node_modules/.bin/netlify status
                    node_modules/.bin/netlify deploy --dir=build
                    node_modules/.bin/netlify deploy --dir=build --json > deploy-output.json
                '''
                script {
                  env.STAGING_URL = sh(script: "node_modules/.bin/node-jq -r '.deploy_url' deploy-output.json", returnStdout: true)
               }
            }
        }

        stage('Staging E2E') {
            agent {
                docker {
                    image 'mcr.microsoft.com/playwright:v1.49.1-noble'
                    reuseNode true
                    args '--user root:root'
                }
            }
            environment {
                CI_ENVIRONMENT_URL = "${env.STAGING_URL}"
            }
            steps {
                sh '''
                    echo "Running Staging E2E Tests..."
                    npx playwright test --reporter=html
                '''
            }

            post {
                always {
                    publishHTML([allowMissing: false,alwaysLinkToLastBuild: false,keepAll: false,reportDir: 'playwright-report',reportFiles: 'index.html',
                    reportName: 'Staging E2E', reportTitles: '',useWrapperFileDirectly: true ])
                }
            }
         }

         stage('Approval Stage') {
            steps {
               timeout(time: 15, unit: 'MINUTES') {
                  input message: 'Reday to deploy to Production ??', ok: 'Yes, Deploy to Production.'
              }
           }
        }

        stage('Deploy to Production') {
            agent {
                docker {
                    image 'node:18-alpine'
                    reuseNode true
                    args '--user root'
                }
            }
            steps {
                sh '''
                    echo "Deploying to Production..."
                    npm install netlify-cli
                    node_modules/.bin/netlify --version
                    node_modules/.bin/netlify status
                    node_modules/.bin/netlify deploy --dir=build --prod
                '''
            }
        }

        stage('Production E2E Tests') {
            agent {
                docker {
                    image 'mcr.microsoft.com/playwright:v1.49.1-noble'
                    reuseNode true
                    args '--user root:root'
                }
            }
            environment {
                CI_ENVIRONMENT_URL = 'https://jenkins-amroo.netlify.app'
            }
            steps {
                sh '''
                    echo "Running Production E2E Tests..."
                    npx playwright test --reporter=html
                '''
            }
            post {
                always {
                    publishHTML([allowMissing: false, alwaysLinkToLastBuild: false, keepAll: false, reportDir: 'playwright-report', reportFiles: 'index.html', 
                    reportName: 'Production E2E', reportTitles: '', useWrapperFileDirectly: true ])
                }
            }
        }
    }
}

