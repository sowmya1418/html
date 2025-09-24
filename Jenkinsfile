pipeline {
    agent any

    environment {
    DOCKER_HUB_REPO = "sowmyaadama/my-ec2"
    DOCKER_CREDENTIALS_ID = "dockerhub-credentials"
}

    stages {
        stage('Build Docker Image') {
            steps {
                script {
                    // Force rebuild to always include updated index.html
                    dockerImage = docker.build("my-ec2-web-app:latest", "--no-cache .")
                }
            }
        }
        stage('push docker image')
        {
            steps{
                script{
                  docker.withRegistry('', DOCKER_CREDENTIALS_ID) {
                    dockerImage.push("latest")
                   }
                }
            }

        stage('Run Docker Container') {
            steps {
                script {
                    // Stop & remove existing container if running
                    sh "docker rm -f my-web-container || true"

                    // Run new container with updated image
                    sh "docker run -d -p 80:80 --name my-web-container my-ec2-web-app:latest"
                }
            }
        }
    }
}
