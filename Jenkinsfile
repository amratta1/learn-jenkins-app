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
                echo "small changes"
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
                   reportName: 'PlayWright local HTML Report',
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
                 npm install netlify-cli 
                 node_modules/.bin/netlify --version
                 node_modules/.bin/netlify status
                 echo "deploy to production. Site ID $NETLIFY_SITE_ID "
                 node_modules/.bin/netlify deploy --dir=build --prod
                '''
            }
       }
       stage('prod E2E') {
           agent {
               docker {
                  image 'mcr.microsoft.com/playwright:v1.49.1-noble'
                  reuseNode true
                  args '--user root:root'
               }
           environment {
             CI_ENVIRONMENT_URL: 'https://frabjous-semifreddo-fb4dec.netlify.app'
           }

           }
           steps {
               sh '''
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
              reportName: 'PlayWright Prod HTML Report',
              reportTitles: '',
              useWrapperFileDirectly: true
            ])
       }
     }
    }
   }
}
