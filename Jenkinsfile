pipeline {
    agent any
    environment {
        REACT_APP_VERSION = "1.0.$BUILD_ID"
        AWS_DEFAULT_REGION = 'us-east-1'
        AWS_ECS_CLUSTER = 'LearnJenkinsApp-Cluster-Prod'
        AWS_ECS_SERVICE_PROD = 'learnJenkinsApp-Prod'
        AWS_ECS_TD_PROD = 'LearnJenkinsApp-TaskDefinition-Prod'
    } 
    stages{ 
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

          stage('Build Docker Images') {
            agent {
               docker {
                 image 'amazon/aws-cli'
                 reuseNode true
                 args "-u root -v /var/run/docker.sock:/var/run/docker.sock --entrypoint=''"
               }
            }
             steps {
                sh '''
                  amazon-linux-extras install docker
                  docker build -t myjenkinsapp .
                '''
             }
          }

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
             aws ecs update-service --cluster $AWS_ECS_CLUSTER --service $AWS_ECS_SERVICE_PROD --task-definition $AWS_ECS_TD_PROD:$LATEST_TD_REVISION
             aws ecs wait services-stable --cluster $AWS_ECS_CLUSTER --services $AWS_ECS_SERVICE_PROD
             '''
            }
          }
       }
    } 
}
