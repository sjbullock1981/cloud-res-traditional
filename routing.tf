#Create RT for Web to IG traffic
resource "aws_route_table" "web-rt" {
  vpc_id = aws_vpc.vpc_master.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "web-rt"
  }
}



#Create RT for DB to IG traffic
resource "aws_route_table" "db-rt" {
  vpc_id = aws_vpc.vpc_master.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "db-rt"
  }
}

