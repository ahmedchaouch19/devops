// Declarative Jenkins pipeline for building, testing, Docker image build/push and deployment
pipeline {
  agent any

  environment {
    IMAGE_NAME = 'student-management'
    IMAGE_TAG = "${env.BUILD_NUMBER}"
    DOCKER_REGISTRY = 'docker.io' // ou votre registry (ex: 'registry.gitlab.com')
    DOCKER_REPO = 'your-dockerhub-username' // À MODIFIER avec votre username Docker Hub
    FULL_IMAGE_NAME = "${DOCKER_REPO}/${IMAGE_NAME}:${IMAGE_TAG}"
    DOCKER_CREDENTIALS_ID = 'docker-hub-credentials' // ID des credentials Docker dans Jenkins
    MAVEN_OPTS = "-Dmaven.repo.local=.m2/repository"
    CONTAINER_NAME = "student-management-app"
    APP_PORT = "8080" // Port de l'application
    HOST_PORT = "8080" // Port sur l'hôte Jenkins
  }

  stages {
    stage('Checkout') {
      steps {
        checkout scm
        sh 'chmod +x mvnw'
      }
    }

    stage('Unit Tests') {
      steps {
        script {
          catchError(buildResult: 'UNSTABLE', stageResult: 'UNSTABLE') {
            sh './mvnw -B test'
          }
        }
      }
    }

    stage('Build Application') {
      steps {
        sh './mvnw -B -DskipTests clean package'
      }
    }

    stage('Build Docker Image') {
      steps {
        script {
          // Build de l'image Docker
          sh """
            docker build -t ${FULL_IMAGE_NAME} .
            docker tag ${FULL_IMAGE_NAME} ${DOCKER_REPO}/${IMAGE_NAME}:latest
          """
        }
      }
    }

    stage('Push Docker Image') {
      steps {
        script {
          // Login et push vers Docker Hub (ou autre registry)
          docker.withRegistry("https://${DOCKER_REGISTRY}", "${DOCKER_CREDENTIALS_ID}") {
            sh """
              docker push ${FULL_IMAGE_NAME}
              docker push ${DOCKER_REPO}/${IMAGE_NAME}:latest
            """
          }
        }
      }
    }

    stage('Deploy/Run Container') {
      steps {
        script {
          // Arrêter et supprimer l'ancien container s'il existe
          sh """
            docker stop ${CONTAINER_NAME} || true
            docker rm ${CONTAINER_NAME} || true
          """
          
          // Lancer le nouveau container
          sh """
            docker run -d \
              --name ${CONTAINER_NAME} \
              -p ${HOST_PORT}:${APP_PORT} \
              --restart unless-stopped \
              ${FULL_IMAGE_NAME}
          """
          
          // Vérifier que le container tourne
          sh "docker ps | grep ${CONTAINER_NAME}"
        }
      }
    }
  }

  post {
    always {
      junit allowEmptyResults: true, testResults: 'target/surefire-reports/*.xml'
    }
    success {
      echo "✅ Pipeline réussi ! Application déployée sur http://localhost:${HOST_PORT}"
    }
    failure {
      echo "❌ Pipeline échoué. Vérifiez les logs."
      // Optionnel: envoyer une notification
    }
    cleanup {
      // Nettoyage des images non utilisées (optionnel)
      sh 'docker image prune -f || true'
      cleanWs()
    }
  }
}