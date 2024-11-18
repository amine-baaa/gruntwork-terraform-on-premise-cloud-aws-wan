resource "aws_vpc" "vpc" {
  cidr_block           = var.vpc_cidr_block
  enable_dns_support   = true
  enable_dns_hostnames = true
 tags = {
    Terraform   = "true"
    Environment = var.environment
  }
}

resource "aws_subnet" "public_subnet" {
  count                   = length(var.public_subnets)
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = var.public_subnets[count.index]
  availability_zone       = var.availability_zones[count.index]
  map_public_ip_on_launch = true
  tags = {
    Name = "${var.vpc_name}-public-${count.index + 1}"
  }
}


resource "aws_subnet" "private_subnet" {
  count                   = length(var.private_subnets)
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = var.private_subnets[count.index]
  availability_zone       = var.availability_zones[count.index]
  map_public_ip_on_launch = false
  tags = {
    Name = "${var.vpc_name}-private-${count.index + 1}"
  }
}

resource "aws_subnet" "cwan_subnet" {
  count                   = length(var.cwan_subnets)
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = var.cwan_subnets[count.index]
  availability_zone       = var.availability_zones[count.index]
  map_public_ip_on_launch = false
  tags = {
    Name = "${var.vpc_name}-cwan-${count.index + 1}"
  }
}
resource "aws_subnet" "fw_subnet" {
  count                   = length(var.fw_subnets)
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = var.fw_subnets[count.index]
  availability_zone       = var.availability_zones[count.index]
  map_public_ip_on_launch = false
  tags = {
    Name = "${var.vpc_name}-fw-${count.index + 1}"
  }
}

resource "aws_internet_gateway" "igw" {
  count = length(var.public_subnets) > 0 ? 1 : 0
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = "${var.vpc_name}-igw"
  }
}


resource "aws_route_table" "public_route_table" {
  count = length(var.public_subnets) > 0 ? 1 : 0
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = "${var.vpc_name}-public-rt"
  }
}


resource "aws_route" "public_route" {
  count = length(var.public_subnets) > 0 ? 1 : 0
  route_table_id         = aws_route_table.public_route_table[0].id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw[0].id
}


resource "aws_route_table_association" "public_subnet_association" {
  count          = length(aws_subnet.public_subnet)
  subnet_id      = aws_subnet.public_subnet[count.index].id
  route_table_id = aws_route_table.public_route_table[0].id
}
resource "aws_eip" "nat_eip" {
  count = length(aws_subnet.public_subnet)
}
resource "aws_nat_gateway" "nat" {
  count        = length(aws_subnet.public_subnet)
  allocation_id = aws_eip.nat_eip[count.index].id
  subnet_id     = aws_subnet.public_subnet[count.index].id
  tags = {
    Name = "${var.vpc_name}-nat-${count.index + 1}"
  }
}
resource "aws_route_table" "private_route_table" {
  count = length(aws_subnet.private_subnet)
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = "${var.vpc_name}-private-rt-${count.index + 1}"
  }
}
resource "aws_route" "private_route" {
  count = length(aws_subnet.private_subnet) > 0 && length(aws_nat_gateway.nat) > 0 ? length(aws_subnet.private_subnet) : 0
  route_table_id         = aws_route_table.private_route_table[count.index].id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat[count.index % length(aws_nat_gateway.nat)].id
}
resource "aws_route_table_association" "private_subnet_association" {
  count          = length(aws_subnet.private_subnet)
  subnet_id      = aws_subnet.private_subnet[count.index].id
  route_table_id = aws_route_table.private_route_table[count.index].id
}

resource "aws_networkmanager_vpc_attachment" "nm_vpc_attachment" {
  core_network_id = var.core_network_id
  subnet_arns     = aws_subnet.cwan_subnet[*].arn
  vpc_arn         = aws_vpc.vpc.arn
  options {
    appliance_mode_support = false
    ipv6_support           = false

  }
  tags = {
    Segment = length(aws_subnet.public_subnet)> 0 ? "inspection" : var.environment
  }
}


output "vpc_id" {
  value = aws_vpc.vpc.id
}

output "public_subnet_ids" {
  value = aws_subnet.public_subnet[*].id
}

output "private_subnet_ids" {
  value = aws_subnet.private_subnet[*].id
}

output "cwan_subnet_ids" {
  value = aws_subnet.cwan_subnet[*].id
}

output "fw_subnet_ids" {
  value = aws_subnet.fw_subnet[*].id
}

output "nat_gateway_ids" {
  value = aws_nat_gateway.nat[*].id
}

output "vpc_attachment_id" {
  value = aws_networkmanager_vpc_attachment.nm_vpc_attachment.id
}

variable "vpc_name" {
  description = "Name of the VPC"
  type        = string
}

variable "vpc_cidr_block" {
  description = "CIDR block for the VPC"
  type        = string
}

variable "availability_zones" {
  description = "List of availability zones for the VPC"
  type        = list(string)
}

variable "public_subnets" {
  description = "List of public subnet CIDR blocks"
  type        = list(string)
  default     = []
}

variable "private_subnets" {
  description = "List of private subnet CIDR blocks"
  type        = list(string)
  default     = []
}

variable "cwan_subnets" {
  description = "List of CWAN subnet CIDR blocks"
  type        = list(string)
  default     = []
}

variable "fw_subnets" {
  description = "List of Firewall (FW) subnet CIDR blocks"
  type        = list(string)
  default     = []
}

variable "environment" {
  description = "Environment name"
  type        = string

}

variable "core_network_id" {
  description = "The ID of the core network to attach the VPC"
  type        = string

}