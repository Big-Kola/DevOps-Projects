terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = "us-east-2"
}

resource "aws_security_group" "bridge_sg" {
  name        = "bridge-sensor-sg"
  description = "Allow HTTP and SSH"

  ingress {
    from_port   = 80 # HTTP
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] #Allow HTTP from anywhere
  }

  ingress {
    from_port   = 22 #SSH
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] #From Anywhere
  }

  egress {
    from_port   = 0 # Using 0 because protocol -1 does not go with any port
    to_port     = 0
    protocol    = "-1" # My instance can reach anything
    cidr_blocks = ["0.0.0.0/0"]
  }
}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

data "aws_subnet" "existing" {
  id = "subnet-0b98c9bbf02ae0d52"
}

resource "aws_instance" "bridge_sensor" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t3.micro"
  vpc_security_group_ids = [aws_security_group.bridge_sg.id]
  subnet_id              = data.aws_subnet.existing.id
  key_name               = "Bridge-Sensor-KP"
  tags = {
    Name = "bridge-sensor"
  }
}

resource "aws_eip" "bridge_sensor" {
  instance = aws_instance.bridge_sensor.id
  domain   = "vpc"
}


output "instance_id" {
  description = "ID of the EC2 instance"
  value       = aws_instance.bridge_sensor.id
}

output "public_ip" {
  description = "Public IP address of the bridge sensor EC2"
  value       = aws_eip.bridge_sensor.public_ip
}