# create vpc
resource "aws_vpc" "Prod-rock-vpc" {
  cidr_block       = var.cidr_block
  instance_tenancy = "default"

  tags = {
    Name = "Prod-rock-vpc"
  }
}

#create public subnet 1
resource "aws_subnet" "test-public-sub1" {
  vpc_id     = aws_vpc.Prod-rock-vpc.id
  cidr_block = var.test-public-sub1-cidr_block

  tags = {
    Name = "test-public-sub1"
  }
}

#create public subnet 2
resource "aws_subnet" "test-public-sub2" {
  vpc_id     = aws_vpc.Prod-rock-vpc.id
  cidr_block = var.test-public-sub2-cidr_block

  tags = {
    Name = "test-public-sub2"
  }
}

#create private subnet 1
resource "aws_subnet" "test-private-sub1" {
  vpc_id     = aws_vpc.Prod-rock-vpc.id
  cidr_block = var.test-private-sub1-cidr_block

  tags = {
    Name = "test-private-sub1"
  }
}

#create private subnet 2
resource "aws_subnet" "test-private-sub2" {
  vpc_id     = aws_vpc.Prod-rock-vpc.id
  cidr_block = var.test-private-sub2-cidr_block

  tags = {
    Name = "test-private-sub2"
  }
}

# create public route table 
resource "aws_route_table" "test-pub-route-table" {
  vpc_id = aws_vpc.Prod-rock-vpc.id

  tags = {
    Name = "test-pub-route-table"
  }
}

# create private route table 
resource "aws_route_table" "test-priv-route-table" {
  vpc_id = aws_vpc.Prod-rock-vpc.id

  tags = {
    Name = "test-priv-route-table"
  }
}

# associate public route table with public subnet 1
resource "aws_route_table_association" "test-pub-route-table-association1" {
  subnet_id      = aws_subnet.test-public-sub1.id
  route_table_id = aws_route_table.test-pub-route-table.id
}

# associate public route table with public subnet 2
resource "aws_route_table_association" "test-pub-route-table-association2" {
  subnet_id      = aws_subnet.test-public-sub2.id
  route_table_id = aws_route_table.test-pub-route-table.id
}

# associate private route table with private subnet 1
resource "aws_route_table_association" "test-priv-route-table-association1" {
  subnet_id      = aws_subnet.test-private-sub1.id
  route_table_id = aws_route_table.test-priv-route-table.id
}

# associate private route table with private subnet 2
resource "aws_route_table_association" "test-priv-route-table-association2" {
  subnet_id      = aws_subnet.test-private-sub2.id
  route_table_id = aws_route_table.test-priv-route-table.id
}

# internet gateway
resource "aws_internet_gateway" "test-igw" {
  vpc_id = aws_vpc.Prod-rock-vpc.id

  tags = {
    Name = "test-igw"
  }
}

# internet gateway association with public route
resource "aws_route" "test-igw-association" {
  route_table_id            = aws_route_table.test-pub-route-table.id
  destination_cidr_block    = "0.0.0.0/0"
  gateway_id                = aws_internet_gateway.test-igw.id
}

# create nat gateway in private subnet 1
resource "aws_nat_gateway" "test-nat-gateway" {
  connectivity_type = "private"
  subnet_id         = aws_subnet.test-private-sub1.id
}

# nat gateway association with private route table
resource "aws_route" "test-nat-association" {
    route_table_id            = aws_route_table.test-priv-route-table.id
    destination_cidr_block    = "0.0.0.0/0"
    gateway_id                = aws_nat_gateway.test-nat-gateway.id
}

## create security group for ec2 instance in public subnet1
resource "aws_security_group" "test-sec-group1" {
  name        = "allow_http"
  description = var.test-sec-group1-aws_security_group
  vpc_id      = aws_vpc.Prod-rock-vpc.id

  ingress {
    description      = "http access"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    
  }

  ingress {
    description      = "ssh access"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    
  }

  tags = {
    Name = "test-sec-group1"
  }
}

## create security group for ec2 instance in private subnet1
resource "aws_security_group" "test-sec-group2" {
  name        = "allow_ssh"
  description = var.test-sec-group2-aws_security_group
  vpc_id      = aws_vpc.Prod-rock-vpc.id

ingress {
    description      = "http access"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    
  }

  ingress {
    description      = "ssh access"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    
  }

  tags = {
    Name = "test-sec-group2"
  }
}

# launch the ec2 instance in public sub1
resource "aws_instance" "test-serve-1" {
  ami               = var.test-serve-1-aws_instance   #ubuntu server 18.04 LTS
  instance_type     = "t2.micro"
  key_name          = "dee-kp"
  subnet_id         = aws_subnet.test-public-sub1.id 
  security_groups   = [aws_security_group.test-sec-group1.id]

  tags = {
    Name = "test-server-1"
  }
}

# launch the ec2 instance in private sub1
resource "aws_instance" "test-serve-2" {
  ami               = var.test-serve-2-aws_instance #ubuntu server 18.04 LTS
  instance_type     = "t2.micro"
  key_name          = "dee-kp"
  subnet_id         = aws_subnet.test-private-sub1.id 
  security_groups   = [aws_security_group.test-sec-group2.id]

  tags = {
    Name = "test-server-2"
  }
}

