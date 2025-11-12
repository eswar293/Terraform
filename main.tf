provider "aws" {
  region     = "ap-south-2"
}

# ________________ Variables ________________

variable "Test_app_vpc_cidr_block" {
    description = "Test app vpc cidr block"
    type = string
}

variable "Test_app_subnet_cidr_block" {
    description = "Test app subnet cidr block"
    type = string
}

variable "Test_app_subnet1_cidr_block" {
    description = "Test app subnet1 cidr block"
    type = string
}

variable "environment" {
    description = "Test environment"
    type = string
}

# ________________ VPC ________________
resource "aws_vpc" "Test_app_vpc" {
  cidr_block = var.Test_app_vpc_cidr_block
    
    tags = {
        Name = "Test_app_vpc"
        Environment = var.environment
    }
}

output "Test_app_vpc_id" {
    value = aws_vpc.Test_app_vpc.id
}

# ________________ Subnet in Created VPC ________________
resource "aws_subnet" "Test_app_subnet" {
    vpc_id  = aws_vpc.Test_app_vpc.id
    cidr_block = var.Test_app_subnet_cidr_block

    tags = {
        Name = "Test_app_subnet"
    }

}

output "Test_app_subnet_id" {
    value = aws_subnet.Test_app_subnet.id
}

# ________________ Subnet1 in Default VPC ________________
data "aws_vpc" "Default_vpc" {
    default = true
}

resource "aws_subnet" "Test_app_subnet1" {
    vpc_id  = data.aws_vpc.Default_vpc.id
    cidr_block = var.Test_app_subnet1_cidr_block

    tags = {
        Name = "Test_app_subnet1"
    }
}

output "Test_app_subnet1_id" {
    value = aws_subnet.Test_app_subnet1.id
}


