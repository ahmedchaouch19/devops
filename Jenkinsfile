pipeline {
    agent any

    environment {
        IMAGE_NAME = 'student-management'
        IMAGE_TAG = "${env.BUILD_NUMBER}"
        DOCKER_REPO = 'your-dockerhub-username'
        FULL_IMAGE_NAME = "${DOCKER_REPO}/${IMAGE_NAME}:${IMAGE_TAG}"
        DOCKER_CREDENTIALS_ID = 'docker-hub-credentials'

        APP_PORT = '8080'
        CONTAINER_NAME = 'student-management-app'
    }

    stages {

        stage('Send Welcome Email') {
            steps {
                mail to: 'ahmetchaouch19@gmail',
                     subject: "Pipeline Started - Build #${env.BUILD_NUMBER}",
                     body: """Pipeline started
Project: ${env.JOB_NAME}
Build: ${env.BUILD_NUMBER}
URL: ${env.BUILD_URL}
"""
            }
        }

         stage('Checkout GIT') {
      steps {
        checkout scm
        sh 'chmod +x mvnw'
      }
    }


        stage('Build') {
            steps {
                sh 'mvn clean package -DskipTests'
            }
        }

        stage('Run Unit Tests') {
            steps {
                sh 'mvn test'
            }
        }

        stage('Build Docker Image') {
            steps {
                sh """
                    docker build -t ${FULL_IMAGE_NAME} .
                    docker tag ${FULL_IMAGE_NAME} ${DOCKER_REPO}/${IMAGE_NAME}:latest
                """
            }
        }

        stage('Push Docker Image') {
            steps {
                docker.withRegistry('https://docker.io', DOCKER_CREDENTIALS_ID) {
                    sh """
                        docker push ${FULL_IMAGE_NAME}
                        docker push ${DOCKER_REPO}/${IMAGE_NAME}:latest
                    """
                }
            }
        }

        stage('Run Container') {
            steps {
                sh """
                    docker stop ${CONTAINER_NAME} || true
                    docker rm ${CONTAINER_NAME} || true

                    docker run -d \
                      --name ${CONTAINER_NAME} \
                      -p ${APP_PORT}:${APP_PORT} \
                      ${FULL_IMAGE_NAME}
                """
            }
        }
    }

    post {
        always {
            echo "Pipeline execution completed"
        }

        success {
            mail to: 'ahmetchaouch19@gmail.com',
                 subject: "Pipeline SUCCESS - Build #${env.BUILD_NUMBER}",
                 body: "Application running on port ${APP_PORT}"
        }

        failure {
            mail to: 'ahmetchaouch19@gmail.com',
                 subject: "Pipeline FAILURE - Build #${env.BUILD_NUMBER}",
                 body: "Check Jenkins logs"
        }
    }
}
