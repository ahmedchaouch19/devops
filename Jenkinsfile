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
            // Stop et supprime le conteneur existant
            sh """
                if [ \$(docker ps -aq -f name=${CONTAINER_NAME}) ]; then
                    echo "Stopping and removing existing container..."
                    docker stop ${CONTAINER_NAME}
                    docker rm ${CONTAINER_NAME}
                fi
            """

            // Lancer un script bash pour trouver un port libre et démarrer le conteneur
            sh """
                #!/bin/bash
                # Trouver un port libre entre 8080 et 8090
                freePort=\$(comm -23 <(seq 8080 8090) <(ss -Htan | awk '{print \$4}' | awk -F: '{print \$NF}') | head -n1)
                echo "Using port \$freePort for container"

                docker run -d \
                  --name ${CONTAINER_NAME} \
                  -p \$freePort:${APP_PORT} \
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
