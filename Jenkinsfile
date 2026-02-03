pipeline {
    agent any

    environment {
        IMAGE_NAME = 'student-management'
        IMAGE_TAG = "${env.BUILD_NUMBER}"
        DOCKER_REPO = 'ahmetch'                       // Ton username Docker Hub
        FULL_IMAGE_NAME = "${DOCKER_REPO}/${IMAGE_NAME}:${IMAGE_TAG}"
        DOCKER_CREDENTIALS_ID = 'docker-hub-credentials'

        APP_PORT = '8080'
        CONTAINER_NAME = 'student-management-app'
    }

    stages {

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
                script {
                    docker.withRegistry('https://index.docker.io/v1/', "${DOCKER_CREDENTIALS_ID}") {
                        sh """
                            docker push ${FULL_IMAGE_NAME}
                            docker push ${DOCKER_REPO}/${IMAGE_NAME}:latest
                        """
                    }
                }
            }
        }

        stage('Run Container') {
    steps {
        sh """
            # Stop and remove any container using port 8080
            docker ps -q --filter "publish=${APP_PORT}" | xargs -r docker stop
            docker ps -aq --filter "publish=${APP_PORT}" | xargs -r docker rm

            # Run new container
            docker run -d \
              --name ${CONTAINER_NAME} \
              -p ${APP_PORT}:${APP_PORT} \
              --restart unless-stopped \
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
            echo "Pipeline SUCCESS - Application running on port ${APP_PORT}"
        }

        failure {
            echo "Pipeline FAILURE - Check Jenkins logs"
        }
    }
}
