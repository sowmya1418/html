pipeline {
    agent any

        }

        stage('Build Docker Image') {
            steps {
                script {
                    dockerImage = docker.build("my-ec2-web-app:latest")
                }
            }
        }

        stage('Run Docker Container') {
            steps {
                script {
                    // Stop & remove existing container if any
                    sh "docker rm -f my-web-container || true"

                    // Run new container mapping port 80
                    sh "docker run -d -p 80:80 --name my-web-container my-ec2-web-app:latest"
                }
            }
        }
    }
}
