# Configure AWS Provider
provider "aws" {
  access_key = var.access_key
  secret_key = var.secret_key
  region     = var.region
}

# Create VPC 
resource "aws_vpc" "deploy5_1_vpc" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name : "deploy5.1_vpc"
    vpc : "deploy_5.1"
  }
}

# Create Public Route Table
resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.deploy5_1_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw_deploy5_1.id
  }

  tags = {
    Name : "deploy5.1_public_rt"
    vpc : "deploy_5.1"
  }
}

# Create Subnets
# Create Public Subnet A
resource "aws_subnet" "public_subnet_a" {
  vpc_id                  = aws_vpc.deploy5_1_vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "${var.region}a"
  map_public_ip_on_launch = true

  tags = {
    Name : "public_subnet_a"
    vpc : "deploy_5.1"
    az : "${var.region}a"
  }
}

# Create Public Subnet B
resource "aws_subnet" "public_subnet_b" {
  vpc_id                  = aws_vpc.deploy5_1_vpc.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "${var.region}b"
  map_public_ip_on_launch = true

  tags = {
    Name : "public_subnet_b"
    vpc : "deploy_5.1"
    az : "${var.region}b"
  }
}

# Create Internet Gateway
resource "aws_internet_gateway" "igw_deploy5_1" {
  vpc_id = aws_vpc.deploy5_1_vpc.id

  tags = {
    Name : "igw_deploy5.1"
    vpc : "deploy_5.1"
  }
}

# Create Association between Route Table & Subnets
resource "aws_route_table_association" "public_a" {
  subnet_id      = aws_subnet.public_subnet_a.id
  route_table_id = aws_route_table.public_route_table.id
}

resource "aws_route_table_association" "public_b" {
  subnet_id      = aws_subnet.public_subnet_b.id
  route_table_id = aws_route_table.public_route_table.id
}

# Create Security Group
resource "aws_security_group" "deploy5_1_sg" {
  vpc_id      = aws_vpc.deploy5_1_vpc.id
  name        = "deploy5.1_sg"
  description = "open ssh jenkins traffic"

  tags = {
    Name : "deploy5.1_sg"
    vpc : "deploy_5.1"
  }


  ingress {
    from_port   = 22
    to_port     = 22
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
    from_port   = 8000
    to_port     = 8000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]

  }

  ingress {
    from_port   = 5000
    to_port     = 5000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]

  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Create Instances
# Create Jenkins Server
resource "aws_instance" "jenkins_server" {
  ami                    = var.ami
  instance_type          = var.instance_type
  vpc_security_group_ids = [aws_security_group.deploy5_1_sg.id]
  key_name               = var.key_name
  subnet_id              = aws_subnet.public_subnet_a.id

  user_data = file("jenkins_server.sh")

  tags = {
    Name : "jenkins_server_5.1"
    vpc : "deploy_5.1"
    az : "${var.region}a"
  }

}

# Create App Server 1
resource "aws_instance" "app_server_1" {
  ami                    = var.ami
  instance_type          = var.instance_type
  vpc_security_group_ids = [aws_security_group.deploy5_1_sg.id]
  key_name               = var.key_name
  subnet_id              = aws_subnet.public_subnet_b.id

  user_data = file("app_server.sh")

  tags = {
    Name : "app_server1_5.1"
    vpc : "deploy_5.1"
    az : "${var.region}b"
  }

}

# Create App Server 2
resource "aws_instance" "app_server_2" {
  ami                    = var.ami
  instance_type          = var.instance_type
  vpc_security_group_ids = [aws_security_group.deploy5_1_sg.id]
  key_name               = var.key_name
  subnet_id              = aws_subnet.public_subnet_b.id

  user_data = file("app_server.sh")

  tags = {
    Name : "app_server2_5.1"
    vpc : "deploy_5.1"
    az : "${var.region}b"
  }

}

# Output data needed for futher configuration
output "jenkins_server_public_ip" {
  value = aws_instance.jenkins_server.public_ip
}

output "app_server_1_public_ip" {
  value = aws_instance.app_server_1.public_ip
}

output "app_server_2_public_ip" {
  value = aws_instance.app_server_2.public_ip
}
