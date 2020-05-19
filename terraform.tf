##################################################################################
# VARIABLES
##################################################################################

variable "private_key_path" {
default = "/home/patcloud/north-virginia.pem"
}

variable "key_name" {
default = "north-virginia"
}

variable "ami" {
  default = "ami-0323c3dd2da7fb37d"
}

variable "instancetype" {
  default = "t2.micro"
}

##################################################################################
# PROVIDERS
##################################################################################

provider "aws" {}


##################################################################################
# RESOURCES
################################################## ################################

#This uses the default VPC.  It WILL NOT delete it on destroy.
resource "aws_default_vpc" "default" {

}

resource "aws_security_group" "Terraform" {
  name        = "Tomcat"
  description = "Allow ports for Tomcat demo"
  vpc_id      = aws_default_vpc.default.id

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
  
  ingress {
    from_port   = 81
    to_port     = 81
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "Terraform" {
  ami                    = var.ami
  instance_type          = var.instancetype
  key_name               = var.key_name
  vpc_security_group_ids = [aws_security_group.Terraform.id]

  connection {
    type        = "ssh"
    host        = self.public_ip
    user        = "ec2-user"
    private_key = file(var.private_key_path)

  }
  provisioner "remote-exec" {
    inline = [
      "sudo yum install java -y",
      "sleep 10s",
      "cd /opt/",
      "sleep 5s",
      "sudo wget http://apachemirror.wuchna.com/tomcat/tomcat-8/v8.5.55/bin/apache-tomcat-8.5.55.tar.gz",
      "sleep 20s",    
      "sudo tar -xvzf apache-tomcat-8.5.55.tar.gz",
      "sleep 5s",
      "sudo mv apache-tomcat-8.5.55 tomcat/",
      "sudo /opt/tomcat/bin/startup.sh"
      
    ]
  }

}


##################################################################################
# OUTPUT
##################################################################################

output "aws_instance_public_dns" {
  value = aws_instance.Terraform.public_dns
}
