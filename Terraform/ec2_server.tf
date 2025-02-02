resource "aws_key_pair" "deployer" {
  key_name   = "terra-automate-key"
  public_key = file("./terra_key.pub")
}

resource "aws_instance" "AppServer" {
  ami                         = "ami-04b4f1a9cf54c11d0"
  instance_type               = "t2.micro"
  key_name                    = aws_key_pair.deployer.key_name
  subnet_id                   = aws_subnet.pub_sub.id
  vpc_security_group_ids      = [aws_security_group.security.id]
  associate_public_ip_address = true

  user_data = base64encode(<<-EOF
  #!/bin/bash
  sudo apt update -y
  sudo apt install -y fontconfig openjdk-17-jre
  sudo wget -O /usr/share/keyrings/jenkins-keyring.asc https://pkg.jenkins.io/debian/jenkins.io-2023.key
  echo "deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] https://pkg.jenkins.io/debian binary/" | sudo tee /etc/apt/sources.list.d/jenkins.list > /dev/null
  sudo apt-get update
  sudo apt-get install -y jenkins
  sudo systemctl start jenkins
  sudo systemctl enable jenkins
  EOF
)


  tags = {
    Name = "Jenkins-Master"
  }

}

resource "aws_instance" "AppServer2" {
  ami                         = "ami-04b4f1a9cf54c11d0"
  instance_type               = "t2.micro"
  key_name                    = aws_key_pair.deployer.key_name
  subnet_id                   = aws_subnet.pub_sub.id
  vpc_security_group_ids      = [aws_security_group.work_security.id]
  associate_public_ip_address = true

  user_data = base64encode(<<-EOF
  #!/bin/bash
  sudo apt update -y
  sudo apt install -y fontconfig openjdk-17-jre
  sudo wget -O /usr/share/keyrings/jenkins-keyring.asc https://pkg.jenkins.io/debian/jenkins.io-2023.key
  echo "deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] https://pkg.jenkins.io/debian binary/" | sudo tee /etc/apt/sources.list.d/jenkins.list > /dev/null
  sudo apt-get update
  sudo apt-get install -y jenkins
  sudo systemctl start jenkins
  sudo systemctl enable jenkins
  sudo apt-get install -y git
  sudo apt-get install -y docker.io
  sudo usermod -aG docker $USER && newgrp docker
  sudo apt-get install dovker-compose
  EOF
)


  tags = {
    Name = "Jenkins-Worker"
  }

}
