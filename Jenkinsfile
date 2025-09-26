pipeline {
    agent any

    environment {
        DOCKER_HUB_REPO = "sowmyaadama/my-ec2"
        DOCKER_CREDENTIALS_ID = "dockerhub-credentials"   // your Jenkins DockerHub credentials ID
    }

    stages {
        stage('Build Docker Image') {
            steps {
                script {
                    // Build image with Docker Hub repo name
                    dockerImage = docker.build("${DOCKER_HUB_REPO}:latest", "--no-cache .")
                }
            }
        }

        stage('Push Docker Image') {
            steps {
                script {
                    // Authenticate to DockerHub and push image
                    docker.withRegistry('https://index.docker.io/v1/', DOCKER_CREDENTIALS_ID) {
                        dockerImage.push("latest")
                    }
                }
            }
        }

        stage('Run Docker Container') {
            steps {
                script {
                    // Stop & remove existing container if running
                    sh "docker rm -f my-web-container || true"

                    // Run the new container from pushed image
                    sh "docker run -d -p 80:80 --name my-web-container ${DOCKER_HUB_REPO}:latest"
                }
            }
        }
    }
}
