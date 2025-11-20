variable "region" {
  default = "us-east-1"
}

variable "instance_type" {
  default = "t2.micro"
}

variable "grafana_password" {
  default = "admin"
  sensitive = true
  type = string
  
}