#Create VPC in us-east-1
resource "aws_vpc" "vpc_master" {
  provider             = aws.region
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "master-vpc-cloudresume"
  }
}

#Create IGW in us-east-1
resource "aws_internet_gateway" "igw" {
  provider = aws.region
  vpc_id   = aws_vpc.vpc_master.id
}

#Get all available AZ's in VPC for master region
data "aws_availability_zones" "azs" {
  provider = aws.region
  state    = "available"
}

#Create Public web subnet
resource "aws_subnet" "web" {
  count = length(var.subnet_cidrs_web)

  vpc_id                  = aws_vpc.vpc_master.id
  cidr_block              = var.subnet_cidrs_web[count.index]
  map_public_ip_on_launch = true
  availability_zone       = var.availability_zones[count.index]
}

#Subnet association for Public web sn
resource "aws_route_table_association" "web-rt" {
  count = length(var.subnet_cidrs_web)

  subnet_id      = element(aws_subnet.web.*.id, count.index)
  route_table_id = aws_route_table.web-rt.id
}

#Create private database subnet
resource "aws_subnet" "db" {
  count = length(var.subnet_cidrs_db)

  vpc_id            = aws_vpc.vpc_master.id
  cidr_block        = var.subnet_cidrs_db[count.index]
  availability_zone = var.availability_zones[count.index]
}

#Subnet association for Private DB sn
resource "aws_route_table_association" "db-rt" {
  count = length(var.subnet_cidrs_db)

  subnet_id      = element(aws_subnet.db.*.id, count.index)
  route_table_id = aws_route_table.db-rt.id
}







