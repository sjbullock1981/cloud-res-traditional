#DB pwd from aws parameter store
data "aws_ssm_parameter" "dbpwd" {
  name = "/cloudres/db/DBPassword"
}

#DB user from aws parameter store
data "aws_ssm_parameter" "dbuser" {
  name = "/cloudres/db/DBUser"
}

#DB name from aws parameter store
data "aws_ssm_parameter" "dbname" {
  name = "/cloudres/db/DBName"
}

#DB parameter group
resource "aws_db_parameter_group" "db-pg" {
  name   = "cloudres-pg"
  family = "postgres13"

  parameter {
    name  = "log_connections"
    value = "1"
  }
}

#DB subnet group
resource "aws_db_subnet_group" "db-sng" {
  name = "dbsng"

  subnet_ids = [
    aws_subnet.db[0].id,
    aws_subnet.db[1].id
  ]
}

#Security group for Postgres private instance
resource "aws_security_group" "db-sg" {
  vpc_id      = aws_vpc.vpc_master.id
  name        = "dbSG"
  description = "Allow all inbound for Postgres"
  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port       = -1
    to_port         = -1
    protocol        = "icmp"
    security_groups = [aws_security_group.sg.id]
  }
  egress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port       = -1
    to_port         = -1
    protocol        = "icmp"
    security_groups = [aws_security_group.sg.id]
  }

  tags = {
    Name = "dbSG"
  }
}

#Create DB instance
resource "aws_db_instance" "cloudres" {
  identifier             = data.aws_ssm_parameter.dbname.value
  instance_class         = "db.t3.micro"
  db_subnet_group_name   = aws_db_subnet_group.db-sng.name
  parameter_group_name   = aws_db_parameter_group.db-pg.name
  allocated_storage      = 20
  engine                 = "postgres"
  engine_version         = "13.7"
  skip_final_snapshot    = true
  publicly_accessible    = true
  vpc_security_group_ids = [aws_security_group.db-sg.id]
  username               = data.aws_ssm_parameter.dbname.value
  password               = data.aws_ssm_parameter.dbpwd.value
}