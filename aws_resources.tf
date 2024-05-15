# VPC - data center:
resource "aws_vpc" "aws-infra" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "aws-infra"
  }
}

# VPC - Subnet:
resource "aws_subnet" "aws-subnet" {
  vpc_id     = aws_vpc.aws-infra.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "us-east-1a"
  map_public_ip_on_launch = "true"

  tags = {
    Name = "aws-subnet"
  }
}

# Internet_gateway:
resource "aws_internet_gateway" "aws-Igw" {
  vpc_id = aws_vpc.aws-infra.id

  tags = {
    Name = "aws-Igw"
  }
}

# Route Table:
resource "aws_route_table" "aws-rt" {
  vpc_id = aws_vpc.aws-infra.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.aws-Igw.id
  }

  tags = {
    Name = "aws-rt"
  }
}

# Route Table - Subnet Association:
resource "aws_route_table_association" "aws-rt-association" {
  subnet_id      = aws_subnet.aws-subnet.id
  route_table_id = aws_route_table.aws-rt.id
}

# Security Group:
resource "aws_security_group" "aws-sg" {
  name        = "allow_tls"
  description = "Allow TLS inbound traffic and all outbound traffic"
  vpc_id      = aws_vpc.aws-infra.id

  ingress {
    description      = "SSH"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  ingress {
    description      = "HTTP"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags = {
    Name = "aws-sg"
  }
}

# AWS Instance:
resource "aws_instance" "Sonar-Qube_nexus-server" {
  ami           = "ami-04b70fa74e45c3917"
  instance_type = "t2.medium"
  key_name = "project"
  subnet_id = aws_subnet.aws-subnet.id
  vpc_security_group_ids = [aws_security_group.aws-sg.id]

  tags = {
    Name = "Sonar-Qube_nexus-server"
  }
}







