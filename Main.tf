

# VPC Creation

resource "aws_vpc" "Website" {
  cidr_block                       = var.vpc_cidr_block
  instance_tenancy                 = "default"
  enable_dns_support               = true
  enable_dns_hostnames             = true
  assign_generated_ipv6_cidr_block = true
  tags = {
    Name = "Website VPC"
  }
}

#Creating Public Subnets
resource "aws_subnet" "web-public-subnet" {
  count             = var.subnet_count.web-public-subnets
  vpc_id            = aws_vpc.Website.id
  cidr_block        = var.web-public-subnets[count.index]
  availability_zone = data.aws_availability_zones.available.names[count.index]
  tags = {
    Name = "web-public-subnet"
  }
}

#Creating Private Subnets
resource "aws_subnet" "app-private-subnet" {
  count             = var.subnet_count.app-private-subnets
  vpc_id            = aws_vpc.Website.id
  cidr_block        = var.app-private-subnets[count.index]
  availability_zone = data.aws_availability_zones.available.names[count.index]
  tags = {
    Name = "app-private-subnet_${count.index}"
  }
}



# Creating Internet Gatway
resource "aws_internet_gateway" "Website-IG" {
  vpc_id = aws_vpc.Website.id
  tags = {
    Name = " Internet Gateway"
  }
}


# Creating Private Route Table 
resource "aws_route_table" "Private-RT" {
  vpc_id = aws_vpc.Website.id
  tags = {
    Name = "Private-route-table"
  }
}

# Private route Table Association
resource "aws_route_table_association" "Private1" {
  count          = var.subnet_count.app-private-subnets
  route_table_id = aws_route_table.Private-RT.id
  subnet_id      = aws_subnet.app-private-subnet[count.index].id

}

# Creating Public Route Table 
resource "aws_route_table" "Public_RT" {
  vpc_id = aws_vpc.Website.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.Website-IG.id
  }
  route {
    ipv6_cidr_block = "::/0"
    gateway_id      = aws_internet_gateway.Website-IG.id
  }
  tags = {
    Name = "Public Route Table"
  }
}


# Public route Table Association
resource "aws_route_table_association" "Public1" {
  count          = var.subnet_count.web-public-subnets
  subnet_id      = aws_subnet.web-public-subnet[count.index].id
  route_table_id = aws_route_table.Public_RT.id
}


# Creating the EC2 Security Groups
resource "aws_security_group" "Website-SG" {
  name        = "Website-SG"
  description = "HTTP and SSH"
  vpc_id      = aws_vpc.Website.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "Website-SG"
  }
}

# Creating RDS Security Group
resource "aws_security_group" "Website-DS-SG" {
  name        = "website-db-sg"
  description = "Security Group for Website Database"
  vpc_id      = aws_vpc.Website.id

ingress {
  description     = "Allowing MySQL traffic from website sg"
  from_port       = 3306
  to_port         = 3306
  protocol        = "tcp"
  security_groups = [aws_security_group.Website-SG.id]
}
tags = {
  name = "website-db-sg"
}
}

# Creating the DB Subnet Group
resource "aws_db_subnet_group" "website-ds-subnet_group" {
  name        = "website-ds-subnet_group"
  description = "DB subnet group for Website"
  subnet_ids  = [for subnet in aws_subnet.app-private-subnet : subnet.id]

}

# MySQL RDS Database Creation
resource "aws_db_instance" "Web" {
  allocated_storage      = var.settings.database.allocated_storage
  engine                 = var.settings.database.engine
  engine_version         = var.settings.database.engine_version
  instance_class         = var.settings.database.instance_class
  db_name                = var.settings.database.db_name
  username               = var.db_username
  password               = var.db_password
  db_subnet_group_name   = aws_db_subnet_group.website-ds-subnet_group.id
  vpc_security_group_ids = [aws_security_group.Website-DS-SG.id]
  skip_final_snapshot    = var.settings.database.skip_final_snapshot
}

# Creating Key-pair and my EC2 instances
resource "aws_key_pair" "rock-key-pair" {
  public_key = file ("rock-key-pair.pub")

}


resource "aws_instance" "ec2" {  
  ami                    = "ami-0cd8ad123effa531a"
  count                  = var.settings.web_app.count
  instance_type          = var.settings.web_app.instance_type
  subnet_id              = aws_subnet.web-public-subnet[count.index].id
  key_name               = aws_key_pair.rock-key-pair.key_name
  vpc_security_group_ids = [aws_security_group.Website-DS-SG.id]

  tags = {
    name = "Website_${count.index}"
  }

}

# Creating the Elastic IP and attaching it to the EC2 instance
resource "aws_eip" "Website-EIP" {
  count    = var.settings.web_app.count
  instance = aws_instance.ec2[count.index].id
  vpc      = true

  tags = {
    name = "Website-EIP_${count.index}"

  }
}


