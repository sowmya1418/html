provider "aws" {
  region = "us-east-1"
}

############VPC############
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "main"
  }
}
#########SUBNET############
resource "aws_subnet" "subnet_1" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.1.0/24"

  tags = {
    Name = "Main"
  }
}
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "main"
  }
}
resource "aws_route_table" "example" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }


  tags = {
    Name = "example"
  }
}

resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.subnet_1.id
  route_table_id = aws_route_table.example.id
}
resource "aws_security_group" "allow_ssh" {
  vpc_id = aws_vpc.main.id

  # Inbound - allow SSH
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Outbound - allow all
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "allow-ssh"
  }
}


######### EC2 instance with Jenkins and Docker (Amazon Linux 2023 compatible) ##########

resource "aws_instance" "sowmya" {
  ami                         = var.ami
  instance_type               = var.instance_type
  subnet_id                   = aws_subnet.subnet_1.id
  key_name                    = "testkey"
  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.allow_ssh.id]

  user_data = <<-EOF
    #!/bin/bash
    set -ex
    dnf update -y

    # Install Java 17 (Amazon Corretto)
    dnf install -y java-17-amazon-corretto
    echo "JAVA_HOME=/usr/lib/jvm/java-17-amazon-corretto.x86_64" >> /etc/environment
    export JAVA_HOME=/usr/lib/jvm/java-17-amazon-corretto.x86_64
    export PATH=$JAVA_HOME/bin:$PATH

    # Install Docker
    dnf install -y docker
    systemctl enable docker
    systemctl start docker
    usermod -aG docker ec2-user

    # Install Jenkins
    wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo
    rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io-2023.key
    dnf install -y jenkins git

    # Ensure Jenkins sees the correct Java
    sed -i 's|JENKINS_JAVA_CMD=.*|JENKINS_JAVA_CMD="/usr/lib/jvm/java-17-amazon-corretto.x86_64/bin/java"|' /etc/sysconfig/jenkins

    # Enable Jenkins on boot and start it
    systemctl daemon-reload
    systemctl enable jenkins
    systemctl start jenkins
  EOF

  tags = {
    Name = "jenkins-server"
  }
}

output "jenkins_ip" {
  value       = aws_instance.sowmya.public_ip
  description = "Public IP of Jenkins server"
}
