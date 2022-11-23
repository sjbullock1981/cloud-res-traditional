data "aws_ssm_parameter" "ami" {
  name = "/cloudres/web-server/ami"
}

resource "aws_key_pair" "webkey" {
  key_name   = "webkey"
  public_key = file("~/.ssh/webkey.pub")
}

resource "aws_instance" "web-node" {
  count                  = var.instance_count
  ami                    = data.aws_ssm_parameter.ami.value
  instance_type          = "t2.micro"
  key_name               = "webkey"
  vpc_security_group_ids = [aws_security_group.sg.id]
  subnet_id              = element(aws_subnet.web.*.id, count.index)

  user_data = <<-EOF
                #!/bin/bash

                DBPassword=$(aws ssm get-parameters --region us-east-1 --names /cloudres/db/DBPassword --with-decryption --query Parameters[0].Value)
                DBPassword=`echo $DBPassword | sed -e 's/^"//' -e 's/"$//'`

                DBUser=$(aws ssm get-parameters --region us-east-1 --names /cloudres/db/DBUser --query Parameters[0].Value)
                DBUser=`echo $DBUser | sed -e 's/^"//' -e 's/"$//'`

                DBName=$(aws ssm get-parameters --region us-east-1 --names /cloudres/db/DBName --query Parameters[0].Value)
                DBName=`echo $DBName | sed -e 's/^"//' -e 's/"$//'`

                sudo systemctl enable httpd
                systemctl start httpd
                usermod -a -G apache ec2-user   
                chown -R ec2-user:apache /var/www
                chmod 2775 /var/www
                find /var/www -type d -exec chmod 2775 {} \;
                find /var/www -type f -exec chmod 0664 {} \;
                echo "Hello, World" > /var/www/html/index.html
                EOF

  tags = {
    Name = "web-node"
  }
}

# Creating 2 Elastic IPs:

resource "aws_eip" "eip" {
  count            = length(aws_instance.web-node.*.id)
  instance         = element(aws_instance.web-node.*.id, count.index)
  public_ipv4_pool = "amazon"
  vpc              = true

  tags = {
    "Name" = "EIP-${count.index}"
  }
}

# Creating EIP association with EC2 Instances:

resource "aws_eip_association" "eip_association" {
  count         = length(aws_eip.eip)
  instance_id   = element(aws_instance.web-node.*.id, count.index)
  allocation_id = element(aws_eip.eip.*.id, count.index)
}