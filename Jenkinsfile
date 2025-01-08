pipeline {
    agent any

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

       stage (Test){
          parallel{
            stage('UnitTest') {
                agent {
                    docker {
                       image 'node:18-alpine'
                       reuseNode true
                       args '--user root'
                    }

                }
                steps {
                    sh '''
                      #test -f ./build/index.html
                      npm test
                    '''
                }
            post{
             always {
               junit 'jest-results/junit.xml'
              }
             }
            }

            stage('E2E') {
                agent {
                    docker {
                       image 'mcr.microsoft.com/playwright:v1.49.1-noble'
                       reuseNode true
                       args '--user root:root'
                    }

                }
                steps {
                    sh '''
                        npm install serve
                        node_modules/.bin/serve -s build &
                        sleep 10
                        npx playwright test --reporter=html
                    '''
              }
             post{
               always {
                 publishHTML([
                   allowMissing: false,
                   alwaysLinkToLastBuild: false,
                   keepAll: false,
                   reportDir: 'playwright-report',
                   reportFiles: 'index.html',
                   reportName: 'PlayWright HTML Report',
                   reportTitles: '',
                   useWrapperFileDirectly: true
                 ])
            }
          }
         }
       }
      }
       stage('Deploy') {
           agent {
                docker {
                   image 'node:18-alpine'
                   reuseNode true
                   args '--user root'
                }

            }
            steps {
                sh '''
                 npm install netlify-cli -g
                 netlify --version
                '''
            }
       }  
   }
}
