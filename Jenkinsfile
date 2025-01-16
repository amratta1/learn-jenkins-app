pipeline {
    agent any
    environment {
        REACT_APP_VERSION = "1.0.$BUILD_ID"
        AWS_DEFAULT_REGION = 'us-east-1'

    } 
    stages{  
        stage(aws){
           agent {
             docker {
              image 'amazon/aws-cli'
              reuseNode true
              args "-u root --entrypoint=''"
             }
           }
           steps {
              withCredentials([usernamePassword(credentialsId: 'my-aws-access', passwordVariable: 'AWS_SECRET_ACCESS_KEY', usernameVariable: 'AWS_ACCESS_KEY_ID')]) {
             sh '''
             aws --version
             yum install jq -y
             aws ecs register-task-definition --cli-input-json file://aws/task-definition-prod.json
             LATEST_TD_REVISION=$(aws ecs register-task-definition --cli-input-json file://aws/task-definition-prod.json | jq '.taskDefinition.revision')
             echo $LATEST_TD_REVISION
             aws ecs update-service --cluster LearnJenkinsApp-Cluster-Prod --service learnJenkinsApp-Prod --task-definition LearnJenkinsApp-TaskDefinition-Prod:$LATEST_TD_REVISION
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
  }
}
