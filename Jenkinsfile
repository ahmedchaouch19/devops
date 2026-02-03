pipeline {
    agent any

    environment {
        IMAGE_NAME = 'student-management'
        IMAGE_TAG = "${env.BUILD_NUMBER}"
        DOCKER_REPO = 'ahmetch'                       // Ton username Docker Hub
        FULL_IMAGE_NAME = "${DOCKER_REPO}/${IMAGE_NAME}:${IMAGE_TAG}"
        DOCKER_CREDENTIALS_ID = 'docker-hub-credentials'

        APP_PORT = '8080'                             // port interne et par défaut
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
        script {
            // Stop et supprime le conteneur existant s'il existe
            sh """
                EXISTING=\$(docker ps -aq -f name=${CONTAINER_NAME})
                if [ ! -z "\$EXISTING" ]; then
                    echo "Stopping and removing existing container..."
                    docker stop ${CONTAINER_NAME}
                    docker rm ${CONTAINER_NAME}
                fi
            """

            // Lancer le conteneur
            sh """
                docker run -d \
                  --name ${CONTAINER_NAME} \
                  -p ${APP_PORT}:${APP_PORT} \
                  --restart unless-stopped \
                  ${FULL_IMAGE_NAME}
            """
        }
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
