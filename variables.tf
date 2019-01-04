variable "aws_region" {
  default = "ca-central-1"
}

variable "cidr_block" {
  default = "10.31.3.0/24"
}

variable "subnet_cidr_block" {
  default = "10.31.3.0/28"
}

variable "vpn_cidr" {
  default = "0.0.0.0/0"
}
