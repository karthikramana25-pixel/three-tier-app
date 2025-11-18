############################################
# Get Default VPC
############################################
data "aws_vpc" "default" {
  default = true
}

############################################
# Get Subnets in Default VPC
############################################
data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

############################################
# Get Latest Ubuntu 20.04 AMI
############################################
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }
}

############################################
# Security Group for K3s Server
############################################
resource "aws_security_group" "k3s_sg" {
  name        = "k3s-sg"
  description = "Allow SSH + ArgoCD"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 30080
    to_port     = 30080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 30443
    to_port     = 30443
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

############################################
# EC2 Key Pair
############################################
resource "aws_key_pair" "deployer" {
  key_name   = "k3s-deployer-key"
  public_key = var.ssh_pub_key
}

############################################
# K3s Server EC2 Instance
############################################
resource "aws_instance" "k3s_server" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = var.instance_type
  subnet_id                   = data.aws_subnets.default.ids[0]
  vpc_security_group_ids      = [aws_security_group.k3s_sg.id]
  associate_public_ip_address = true
  key_name                    = aws_key_pair.deployer.key_name

  user_data = file("${path.module}/cloud_init_k3s_server.sh")

  tags = {
    Name = "k3s-server"
  }
}

