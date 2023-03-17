###################################################################################
# Internet Gateway
###################################################################################
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
  
  tags = {
    Name = format("%s-%s", var.svr_nm, "igw")
    Environments = var.env
  }
}

###################################################################################
# NAT Gateway
###################################################################################
resource "aws_nat_gateway" "nat" {
  count = length(aws_subnet.public)
  
  allocation_id = element(aws_eip.eip[*].id, count.index)
  subnet_id = element([
    for az, subnet in aws_subnet.public: subnet.id
  ], count.index)
  
  tags = {
    Name = format("%s-%s", var.svr_nm, "nat${count.index + 1}")
    Environments = var.env
  }
}

###################################################################################
# EIP for NAT
###################################################################################
resource "aws_eip" "eip" {
  count = length(aws_subnet.public)
  vpc = true
  
  lifecycle {
    create_before_destroy = true
  }
  tags = {
    Name = format("%s-%s", var.svr_nm, "eip${count.index + 1}")
    Environments = var.env
  }
}
