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
                    // Vérifie si le conteneur existe déjà et supprime-le
                    sh """
                        if [ \$(docker ps -aq -f name=${CONTAINER_NAME}) ]; then
                            echo "Stopping and removing existing container..."
                            docker stop ${CONTAINER_NAME}
                            docker rm ${CONTAINER_NAME}
                        fi
                    """

                    // Vérifie si le port est utilisé et change de port si nécessaire
                    def freePort = sh(script: "comm -23 <(seq 8080 8090) <(ss -Htan | awk '{print \$4}' | awk -F: '{print \$NF}') | head -n1", returnStdout: true).trim()
                    echo "Using port ${freePort} for container"

                    // Lancer le conteneur
                    sh """
                        docker run -d \
                          --name ${CONTAINER_NAME} \
                          -p ${freePort}:${APP_PORT} \
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
