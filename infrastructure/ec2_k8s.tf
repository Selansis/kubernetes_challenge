## This Terraform configuration file sets up an EC2 instance with minikube cluster
resource "tls_private_key" "k8s_key" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

resource "aws_key_pair" "k8s_key" {
  key_name   = "k8s-key"
  public_key = tls_private_key.k8s_key.public_key_openssh
}

resource "aws_instance" "k8s_instance" {
  ami           = "ami-00a929b66ed6e0de6" # Amazon Linux 2023 AMI (ARM64)
  instance_type = "t2.medium"
  subnet_id     = aws_subnet.k8s_subnet.id
  key_name      = aws_key_pair.k8s_key.key_name
  vpc_security_group_ids = [aws_security_group.k8s_sg.id]
  user_data = file("${path.module}/startup.sh")
   
  tags = {
      Name = "k8s-instance"
    }
  }
  output "ssh_to_k8s_connection_command" {
    value = "ssh -i ${local_file.private_key.filename} ec2-user@${aws_instance.k8s_instance.public_ip} -o StrictHostKeyChecking=no"
  }
  output "website_url" {
    value = "http://${aws_instance.k8s_instance.public_ip}:30007/"
    
  }
resource "local_file" "private_key" {
  filename = "${path.module}/k8s-key.pem"
  content  = tls_private_key.k8s_key.private_key_pem
  file_permission = 0400
}