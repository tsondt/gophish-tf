provider "aws" {
  region = "${var.aws_region}"
}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-xenial-16.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

# VPC
resource "aws_vpc" "vpc" {
  cidr_block           = "${var.cidr_block}"
  enable_dns_support   = true
  enable_dns_hostnames = true
}

# Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = "${aws_vpc.vpc.id}"
}

# Grant the VPC internet access
resource "aws_route" "internet_access" {
  route_table_id         = "${aws_vpc.vpc.main_route_table_id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = "${aws_internet_gateway.igw.id}"
}

# Public Subnet
resource "aws_subnet" "public_subnet" {
  vpc_id                  = "${aws_vpc.vpc.id}"
  cidr_block              = "${var.subnet_cidr_block}"
  map_public_ip_on_launch = true
}

# EC2 Security Group
resource "aws_security_group" "sgGophish" {
  name        = "GophishSG"
  description = "Access from VPN"
  vpc_id      = "${aws_vpc.vpc.id}"

  # SSH from VPN
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${var.vpn_cidr}"]
  }

  # HTTPS from VPN
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["${var.vpn_cidr}"]
  }

  ingress {
    from_port   = 4433
    to_port     = 4433
    protocol    = "tcp"
    cidr_blocks = ["${var.vpn_cidr}"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# EC2
resource "random_pet" "ec2" {}

resource "aws_instance" "gophish" {
  ami                    = "${data.aws_ami.ubuntu.id}"
  instance_type          = "t3.micro"
  key_name               = "son"
  vpc_security_group_ids = ["${aws_security_group.sgGophish.id}"]
  subnet_id              = "${aws_subnet.public_subnet.id}"

  tags {
    Name = "${random_pet.ec2.id}"
  }

  connection {
    user = "ubuntu"
  }

  provisioner "file" {
    source      = "scripts/install_gophish.sh"
    destination = "/home/ubuntu/install_gophish.sh"
  }

  provisioner "file" {
    source      = "scripts/start_gophish.sh"
    destination = "/home/ubuntu/start_gophish.sh"
  }

  provisioner "file" {
    source      = "scripts/install_le_cert.sh"
    destination = "/home/ubuntu/install_le_cert.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo bash /home/ubuntu/install_gophish.sh",
    ]

    connection {
      type = "ssh"
      user = "ubuntu"
    }
  }
}
