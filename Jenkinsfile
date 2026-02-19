pipeline {
    agent any

    environment {
        IMAGE_NAME = 'student-management'
        IMAGE_TAG = "${env.BUILD_NUMBER}"
        DOCKER_REPO = 'ahmetch'
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

        // ✅ AJOUT : SonarQube demandé par le TP (slide 24)
        stage('SonarQube Analysis') {
            steps {
                sh '''
                    mvn sonar:sonar \
                      -Dsonar.projectKey=spring-app \
                      -Dsonar.projectName=spring-app \
                      -Dsonar.host.url=http://192.168.49.1:31000 \
                      -Dsonar.token=sqp_35566255ed274268856be620601c08e2374fb374
                '''
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

        // ✅ AJOUT : Deploy Kubernetes demandé par le TP (slides 16-21)
        stage('Deploy to Kubernetes') {
            steps {
                sh '''
                    kubectl apply -f spring-deployment.yaml -n devops
                    kubectl rollout status deployment/spring-app -n devops
                '''
            }
        }

        stage('Verify Deployment') {
            steps {
                sh '''
                    kubectl get pods -n devops
                    kubectl get svc -n devops
                '''
            }
        }

    }

    post {
        always {
            echo "Pipeline execution completed"
        }
        success {
            echo "Pipeline SUCCESS"
        }
        failure {
            echo "Pipeline FAILURE - Check Jenkins logs"
        }
    }
}