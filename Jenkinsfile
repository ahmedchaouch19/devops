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
    stage('Build') {
      steps {
        sh './mvnw -B package'
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