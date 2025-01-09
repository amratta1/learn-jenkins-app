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
                                reportDir: 'playwright-report', 
                                reportFiles: 'index.html', 
                                reportName: 'Playwright Local HTML Report', 
                                allowMissing: false, 
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
                    npm install netlify-cli
                    node_modules/.bin/netlify --version
                    node_modules/.bin/netlify status
                    node_modules/.bin/netlify deploy --dir=build
                '''
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
                    publishHTML([
                        reportDir: 'playwright-report', 
                        reportFiles: 'index.html', 
                        reportName: 'Playwright Prod HTML Report', 
                        allowMissing: false, 
                        useWrapperFileDirectly: true
                    ])
                }
            }
        }
    }
}

