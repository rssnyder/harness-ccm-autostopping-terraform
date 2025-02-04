# create a security group to allow inbound access to our applcation, and ssh
resource "aws_security_group" "application" {
  name        = "${var.name}-application"
  description = "Allow HTTP/SSH inbound traffic"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description = "Open HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [module.vpc.vpc_cidr_block]
  }

  ingress {
    description = "Open SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [module.vpc.vpc_cidr_block]
  }

  tags = {
    Name = "${var.name}-application"
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

# create a vm and start a web server
resource "aws_instance" "application" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t3.micro"
  user_data     = <<EOF
#!/bin/bash
sudo apt-get update -y &&
sudo apt-get install -y nginx
EOF
  subnet_id     = module.vpc.private_subnets[0]
  vpc_security_group_ids = [
    module.vpc.default_security_group_id,
    aws_security_group.application.id,
  ]
  associate_public_ip_address = false
  key_name                    = var.key
  tags = {
    Name = "${var.name}-application"
  }
}