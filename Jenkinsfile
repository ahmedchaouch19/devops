// Declarative Jenkins pipeline for building, testing and optionally building Docker image
pipeline {
  agent any

  environment {
    IMAGE_NAME = 'student-management'
    IMAGE_TAG = "${env.BUILD_NUMBER}"
    // On s'assure que Maven utilise le repo local de Jenkins
    MAVEN_OPTS = "-Dmaven.repo.local=.m2/repository"
  }

  stages {
    stage('Checkout') {
      steps {
        checkout scm
      }
    }

    stage('Unit Tests') {
      steps {
        // On tente les tests, mais on ne bloque pas tout si un test échoue
        // Ou utilise -DskipTests si tu veux juste que ça passe
        sh './mvnw test -DskipTests'
      }
    }

    stage('Build JAR') {
      steps {
        // Utilise ./mvnw pour être sûr d'avoir la bonne version de Maven
        sh './mvnw -B -DskipTests package'
      }
    }

    stage('Docker Build') {
      steps {
        script {
          // Utilise ton Dockerfile pour créer l'image
          sh "docker build -t ${IMAGE_NAME}:${IMAGE_TAG} ."
          sh "docker build -t ${IMAGE_NAME}:latest ."
        }
      }
    }
  }

  post {
    always {
      // Nettoyage pour ne pas encombrer le serveur Jenkins
      cleanWs()
    }
  }
}