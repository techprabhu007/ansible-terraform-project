

provider "aws" {
  region = var.aws_region
}

# 1. Create a VPC
resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr
  tags = {
    Name = "swarm-vpc"
  }
}

# 2. Create an Internet Gateway and attach it to the VPC
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "swarm-igw"
  }
}

# 3. Create a Route Table
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "swarm-public-rt"
  }
}

# 4. Create a Subnet
resource "aws_subnet" "main" {
  vpc_id     = aws_vpc.main.id
  cidr_block = var.public_subnet_cidr
  map_public_ip_on_launch = true
  tags = {
    Name = "swarm-subnet"
  }
}

# 5. Associate the Route Table with our Subnet
resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.main.id
  route_table_id = aws_route_table.public_rt.id
}

# Create a Security Group to allow SSH, Docker Swarm, and web traffic
resource "aws_security_group" "swarm_sg" {
  name        = "swarm-sg"
  vpc_id      = aws_vpc.main.id

  # Allow SSH access
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow traffic between nodes in the Swarm
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    self        = true
  }
  
  # Allow web traffic
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  # Allow traffic to the visualizer app
  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Create the Swarm Manager EC2 instance
resource "aws_instance" "swarm_manager" {
  ami           = "ami-03aa99ddf5498ceb9" 
  instance_type = var.instance_type
  key_name      = var.key_name
  subnet_id     = aws_subnet.main.id
  vpc_security_group_ids = [aws_security_group.swarm_sg.id]

  tags = {
    Name = "Swarm-Manager"
    Role = "manager"
  }
}

# Create 3 Swarm Worker EC2 instances
resource "aws_instance" "swarm_worker" {
  count         = 3
  ami           = "ami-03aa99ddf5498ceb9"
  instance_type = "t2.micro"
  key_name      = var.key_name
  subnet_id     = aws_subnet.main.id
  vpc_security_group_ids = [aws_security_group.swarm_sg.id]

  tags = {
    Name = "Swarm-Worker-${count.index + 1}"
    Role = "worker"
  }
}