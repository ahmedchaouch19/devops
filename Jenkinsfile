// Declarative Jenkins pipeline for building, testing and optionally building Docker image
pipeline {
  agent any

  environment {
    IMAGE_NAME = 'student-management'
    IMAGE_TAG = "${env.BUILD_NUMBER ?: 'latest'}"
    DOCKER_BUILD = 'true'    // set to 'false' to skip docker build
    DOCKER_PUSH  = 'false'   // set to 'true' to push to registry
    DOCKER_REGISTRY = ''     // e.g. myregistry.io/myteam
  }

  options {
    skipStagesAfterUnstable()
    timestamps()
  }

  stages {
    stage('Checkout') {
      steps { checkout scm }
    }
    stage('Unit Tests') {
      steps {
        sh 'mvn test'
      }
    }

    stage('Build') {
      steps {
        sh 'mvn -B -DskipTests package'
      }
    }
  }

  post {
    always {
      junit allowEmptyResults: true, testResults: 'target/surefire-reports/*.xml'
      cleanWs()
    }
  }
}
