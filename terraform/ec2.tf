data "aws_vpc" "default" {
  default = true
}

data "aws_subnet_ids" "default" {
  vpc_id = data.aws_vpc.default.id
}

data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"]
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }
}

resource "aws_security_group" "k3s_sg" {
  name        = "k3s-sg"
  description = "Allow SSH + ArgoCD"
  vpc_id      = data.aws_vpc.default.id

  ingress { from_port = 22 to_port = 22 protocol = "tcp" cidr_blocks = ["0.0.0.0/0"] }
  ingress { from_port = 30080 to_port = 30080 protocol = "tcp" cidr_blocks = ["0.0.0.0/0"] }
  ingress { from_port = 30443 to_port = 30443 protocol = "tcp" cidr_blocks = ["0.0.0.0/0"] }
  egress { from_port = 0 to_port = 0 protocol = "-1" cidr_blocks = ["0.0.0.0/0"] }
}

resource "aws_key_pair" "deployer" {
  key_name   = "k3s-deployer-key"
  public_key = var.ssh_pub_key
}

resource "aws_instance" "k3s_server" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.instance_type
  subnet_id              = element(data.aws_subnet_ids.default.ids, 0)
  vpc_security_group_ids = [aws_security_group.k3s_sg.id]
  associate_public_ip_address = true
  key_name = aws_key_pair.deployer.key_name
  user_data = file("${path.module}/cloud_init_k3s_server.sh")
}
