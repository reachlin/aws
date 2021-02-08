variable "server_port" {
  description = "The port the server will use for HTTP requests"
  type        = number
  default = 80
}


provider "aws" {
  region = "us-west-2"
}

resource "aws_vpc" "vpc" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "test0202"
  }
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "test0202"
  }
}

resource "aws_route_table" "rt" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  route {
    ipv6_cidr_block        = "::/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = {
    Name = "test0202"
  }
}

resource "aws_subnet" "subnet1" {
  vpc_id     = aws_vpc.vpc.id
  cidr_block = "10.0.1.0/24"

  tags = {
    Name = "test0202"
  }
}

resource "aws_route_table_association" "assoc" {
  subnet_id      = aws_subnet.subnet1.id
  route_table_id = aws_route_table.rt.id
}

resource "aws_security_group" "allow_web" {
  name        = "allow_web"
  description = "Allow web inbound traffic"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

 ingress {
    description = "HTTP"
    from_port   = var.server_port
    to_port     = var.server_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

 ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "test0202"
  }
}

resource "aws_network_interface" "nic" {
  subnet_id       = aws_subnet.subnet1.id
  private_ips     = ["10.0.1.80"]
  security_groups = [aws_security_group.allow_web.id]

  tags = {
    Name = "test0202"
  } 
}

resource "aws_eip" "lb" {
  vpc                       = true
  network_interface         = aws_network_interface.nic.id
  associate_with_private_ip = "10.0.1.80"
  depends_on = [aws_internet_gateway.gw]
}

resource "aws_instance" "web_server" {
    ami = "ami-0ac73f33a1888c64a"
    instance_type = "t2.micro"
    availability_zone = aws_subnet.subnet1.availability_zone
    key_name = "aws_test"
    network_interface {
        device_index = 0
        network_interface_id = aws_network_interface.nic.id
    }
    user_data = <<-EOF
              #!/bin/bash
              sudo apt-get update
              sudo apt-get install -y apache2
              sudo echo "Hello, AWS and terraform" > /var/www/html/index.html
              sudo systemctl start apache2
              EOF

    tags = {
        Name = "test0202"
    }  
}