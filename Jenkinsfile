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
        // Ensure the Maven wrapper is executable on the agent
        sh 'chmod +x mvnw'
      }
    }

    stage('Unit Tests') {
      steps {
        script {
          // Run tests and mark build UNSTABLE instead of FAILURE on test failures
          catchError(buildResult: 'UNSTABLE', stageResult: 'UNSTABLE') {
            sh './mvnw -B test'
          }
        }
      }
    }
    stage('Build') {
      steps {
        sh './mvnw -B -DskipTests package'
      }
    }
  }

  post {
    always {
      // Publish test reports (if any) so Jenkins shows failures/stacktraces
      junit allowEmptyResults: true, testResults: 'target/surefire-reports/*.xml'
      // Nettoyage pour ne pas encombrer le serveur Jenkins
      cleanWs()
    }
  }
}