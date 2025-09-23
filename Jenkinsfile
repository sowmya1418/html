pipeline {
    agent any

    stages {
        stage('Build Docker Image') {
            steps {
                script {
                    // Force rebuild to always include updated index.html
                    dockerImage = docker.build("my-ec2-web-app:latest", "--no-cache .")
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
