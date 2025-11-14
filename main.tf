provider "aws" {
  region = "ap-south-2"
}

#===== Variables =======
variable my_app_vpc_cidr_block {}
variable my_app_subnet_cidr_block {}
variable env_prefix {}
variable my_ip {}
variable instance_type {}
variable avail_zone {}
variable public_key_location {}

#===== Resources =====
resource "aws_vpc" "my_app_vpc" {
  cidr_block = var.my_app_vpc_cidr_block
  tags = {
    Name: "${var.env_prefix }-vpc"
  }
}

output "my_app_vpc" {
    value = aws_vpc.my_app_vpc.id
}

resource "aws_subnet" "my_app_subnet-1" {
  vpc_id     = aws_vpc.my_app_vpc.id
  cidr_block = var.my_app_subnet_cidr_block
  availability_zone = var.avail_zone
  tags = {
    Name: "${var.env_prefix}-subnet-1"
  }
}

output "my_app_subnet-1" {
    value = aws_subnet.my_app_subnet-1.id
}

/*resource "aws_route_table" "my_app_route_table" {
  vpc_id = aws_vpc.my_app_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.my_app_igw.id
  }

  tags = {
    Name: "${var.env_prefix}-my_app_rtb"
  }

}
output "my_app_route_table" {
    value = aws_route_table.my_app_route_table.id
}*/


resource "aws_internet_gateway" "my_app_igw" {
  vpc_id = aws_vpc.my_app_vpc.id

  tags = {
    Name: "${var.env_prefix}-my_app_igw"
  }
}
output "my_app_igw" {
    value = aws_internet_gateway.my_app_igw.id
}

/*resource "aws_route_table_association" "my_app_rtb_subnet_1" {
  subnet_id      = aws_subnet.my_app_subnet-1.id
  route_table_id = aws_route_table.my_app_route_table.id
}
output "my_app_rtb_subnet_1" {
    value = aws_route_table_association.my_app_rtb_subnet_1.id
}*/


resource "aws_default_route_table" "my_app_route_table" {
  default_route_table_id = aws_vpc.my_app_vpc.default_route_table_id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.my_app_igw.id
  }
  tags = {
    Name: "${var.env_prefix}-drt"
  }
}
output "my_app_default_rtb" {
    value = aws_default_route_table.my_app_route_table.id
}

/*resource "aws_security_group" "my_app_sg" {
  name   = "my_app_sg"
  vpc_id = aws_vpc.my_app_vpc.id

  ingress {
    from_port = 22
    protocol = "TCP"
    to_port = 22
    cidr_blocks = [var.my_ip]
  }
  ingress {
    from_port = 8080
    protocol = "TCP"
    to_port = 8080
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port = 0
    protocol = -1
    to_port = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name: "${var.env_prefix}-sg"
  }
}
output "my_app_sg" {
    value = aws_security_group.my_app_sg.id
}*/

resource "aws_default_security_group" "my_app_default_sg" {
  vpc_id = aws_vpc.my_app_vpc.id

  ingress {
    from_port = 22
    protocol = "TCP"
    to_port = 22
    cidr_blocks = [var.my_ip]
  }
  ingress {
    from_port = 8080
    protocol = "TCP"
    to_port = 8080
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port = 0
    protocol = -1
    to_port = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name: "${var.env_prefix}-sg"
  }
}
output "my_app_default_sg" {
    value = aws_default_security_group.my_app_default_sg.id
}

resource "aws_key_pair" "ssh_key" {
  key_name = "aws_key"
  public_key = file(var.public_key_location)
}

data "aws_ami" "ubuntu_latest_image" {
  most_recent = true
  owners      = ["099720109477"]
  
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/*-20251022"]
  }
  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
}
output "aws_ami_id" {
  value = data.aws_ami.ubuntu_latest_image.id
}
output "ec2_public_ip" {
  value = aws_instance.my_app_server.public_ip
}

resource "aws_instance" "my_app_server" {
  ami = data.aws_ami.ubuntu_latest_image.id
  instance_type = "${var.instance_type}"
  subnet_id = aws_subnet.my_app_subnet-1.id
  vpc_security_group_ids = [aws_default_security_group.my_app_default_sg.id]
  availability_zone = var.avail_zone
  associate_public_ip_address = true
  key_name = aws_key_pair.ssh_key.key_name

  user_data = file("endpoint.sh")
  user_data_replace_on_change = true

  tags = {
    Name = "${var.env_prefix}-server"
  }
}
output "my_app_server" {
  value = aws_instance.my_app_server.id
}
