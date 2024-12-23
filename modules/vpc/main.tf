
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

# Internet Gateway
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

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id             = aws_internet_gateway.igw[0].id
  }
}

resource "aws_route_table" "private_route_table" {
  count = length(aws_subnet.private_subnet)
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = "${var.vpc_name}-private-rt-${count.index + 1}"
  }

  dynamic "route" {
  for_each = length(var.public_subnets) > 0 ? [1] : []
  content {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat[count.index % length(aws_nat_gateway.nat)].id
  }
}


  route {
    cidr_block = "10.0.0.0/8"
    core_network_arn       = var.core_network_arn
  }
}

resource "aws_route_table" "cwan_route_table" {
  count = length(aws_subnet.cwan_subnet)
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = "${var.vpc_name}-cwan-rt-${count.index + 1}"
  }

  route {
    cidr_block = "10.0.0.0/8"
    core_network_arn       = var.core_network_arn
  }

  # route {
  #   cidr_block = "0.0.0.0/0"
  #   network_interface_id   = var.firewall_endpoint_id
  # }
}
resource "aws_route_table" "fw_route_table" {
  count = length(aws_subnet.fw_subnet)
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = "${var.vpc_name}-fw-rt-${count.index + 1}"
  }

  route {
    cidr_block = "10.0.0.0/8"
    core_network_arn       = var.core_network_arn
  }

  # route {
  #   cidr_block = "0.0.0.0/0"
  #   network_interface_id   = var.firewall_endpoint_id
  # }
}

resource "aws_route_table_association" "public_subnet_association" {
  count          = length(aws_subnet.public_subnet)
  subnet_id      = aws_subnet.public_subnet[count.index].id
  route_table_id = aws_route_table.public_route_table[0].id
}

resource "aws_route_table_association" "private_subnet_association" {
  count          = length(aws_subnet.private_subnet)
  subnet_id      = aws_subnet.private_subnet[count.index].id
  route_table_id = aws_route_table.private_route_table[count.index].id
}

resource "aws_route_table_association" "cwan_subnet_association" {
  count          = length(aws_subnet.cwan_subnet)
  subnet_id      = aws_subnet.cwan_subnet[count.index].id
  route_table_id = aws_route_table.cwan_route_table[count.index].id
}

resource "aws_route_table_association" "fw_subnet_association" {
  count          = length(aws_subnet.fw_subnet)
  subnet_id      = aws_subnet.fw_subnet[count.index].id
  route_table_id = aws_route_table.fw_route_table[count.index].id
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

resource "aws_networkmanager_vpc_attachment" "nm_vpc_attachment" {
  core_network_id = var.core_network_id
  subnet_arns     = aws_subnet.cwan_subnet[*].arn
  vpc_arn         = aws_vpc.vpc.arn
  options {
    appliance_mode_support = false
    ipv6_support           = false
  }
  tags = {
    Segment = length(aws_subnet.public_subnet) > 0 ? "inspection" : var.environment
  }
}
