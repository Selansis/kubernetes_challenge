resource "tls_private_key" "grafana_key" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

resource "aws_key_pair" "grafana_key" {
  key_name   = "grafana-key"
  public_key = tls_private_key.grafana_key.public_key_openssh
}

resource "aws_instance" "grafana_instance" {
  ami           = "ami-00a929b66ed6e0de6"
  instance_type = "t2.medium"
  subnet_id     = aws_subnet.k8s_subnet.id
  key_name      = aws_key_pair.grafana_key.key_name
  vpc_security_group_ids = [aws_security_group.k8s_sg.id]
  user_data = file("${path.module}/startup_grafana.sh")
   
  tags = {
      Name = "grafana-instance"
    }
  }
  output "ssh_to_grafana_connection_command" {
    value = "ssh -i ${local_file.private_key_grafana.filename} ec2-user@${aws_instance.grafana_instance.public_ip} -o StrictHostKeyChecking=no"
  }

    output "grafana_url" {
    value = "http://${aws_instance.grafana_instance.public_ip}:3000/"
    
  }

resource "local_file" "private_key_grafana" {
  filename = "${path.module}/grafana-key.pem"
  content  = tls_private_key.grafana_key.private_key_pem
  file_permission = 0400
}