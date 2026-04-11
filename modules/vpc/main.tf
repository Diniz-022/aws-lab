# ===========================
# VPC - Rede
# Rede isolada na AWS com
# subnets publica e privada
# ===========================
resource "aws_vpc" "main" {
  cidr_block           = var.cidr_block
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name    = "${var.project_name}-vpc"
    Project = var.project_name
  }
}

resource "aws_subnet" "publica" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.subnet_publica_cidr
  availability_zone       = "${var.region}a"
  map_public_ip_on_launch = true

  tags = {
    Name    = "${var.project_name}-subnet-publica"
    Project = var.project_name
  }
}

resource "aws_subnet" "privada" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.subnet_privada_cidr
  availability_zone = "${var.region}a"

  tags = {
    Name    = "${var.project_name}-subnet-privada"
    Project = var.project_name
  }
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name    = "${var.project_name}-igw"
    Project = var.project_name
  }
}

resource "aws_route_table" "publica" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name    = "${var.project_name}-rt-publica"
    Project = var.project_name
  }
}

resource "aws_route_table_association" "publica" {
  subnet_id      = aws_subnet.publica.id
  route_table_id = aws_route_table.publica.id
}
