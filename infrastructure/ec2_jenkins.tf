resource "tls_private_key" "jenkins_key" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

resource "aws_key_pair" "jenkins_key" {
  key_name   = "jenkins-key"
  public_key = tls_private_key.jenkins_key.public_key_openssh
}

resource "aws_instance" "jenkins_instance" {
  ami           = "ami-00a929b66ed6e0de6"
  instance_type = "t2.medium"
  subnet_id     = aws_subnet.k8s_subnet.id
  key_name      = aws_key_pair.jenkins_key.key_name
  vpc_security_group_ids = [aws_security_group.k8s_sg.id]
  user_data = file("${path.module}/startup_jenkins.sh")
   
  tags = {
      Name = "jenkins-instance"
    }
  }
  output "ssh_to_jenkins_connection_command" {
    value = "ssh -i ${local_file.private_key_jenkins.filename} ec2-user@${aws_instance.jenkins_instance.public_ip} -o StrictHostKeyChecking=no"
  }

resource "local_file" "private_key_jenkins" {
  filename = "${path.module}/jenkins-key.pem"
  content  = tls_private_key.jenkins_key.private_key_pem
  file_permission = 0400
}