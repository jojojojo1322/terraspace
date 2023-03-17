###################################################################################
# Public Route
###################################################################################
# Route table: attach Internet Gateway 
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
  
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = {
    Name = format("%s-%s", var.svr_nm, "public")
  }
}

# Route Table connect subnets
resource "aws_route_table_association" "public" {
  count = length(aws_subnet.public)
  subnet_id = element([
    for az, subnet in aws_subnet.public: subnet.id
  ], count.index)
  route_table_id = element(aws_route_table.public[*].id, count.index)
}

###################################################################################
# Private Route :: Worker Nodes
###################################################################################
# Route table: attach Internet Gateway 
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id
  
  count = length(aws_nat_gateway.nat)
  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = element([
      for key, value in aws_nat_gateway.nat: value.id
    ], count.index)
  }
  tags = {
    Name = format("%s-%s", var.svr_nm, "private${count.index+1}")
  }
}

# Route Table connect subnets
resource "aws_route_table_association" "private" {
  count = length(aws_subnet.private)
  subnet_id = element([
    for az, subnet in aws_subnet.private: subnet.id
  ], count.index)
  route_table_id = element(aws_route_table.private[*].id, count.index)
}

###################################################################################
# Expand Route :: Kafka
###################################################################################
# Route table: attach Internet Gateway 
# resource "aws_route_table" "expand" {
#   count = length(aws_subnet.expand)

#   vpc_id = aws_vpc.main.id
#   route {
#     cidr_block = "0.0.0.0/0"
#     nat_gateway_id = element([
#       for key, value in aws_nat_gateway.nat: value.id
#     ], count.index)
#   }
#   tags = {
#     Name = format("%s-%s", var.svr_nm, "expand${count.index+1}")
#   }
# }

# # Route Table connect subnets
# resource "aws_route_table_association" "expand" {
#   count = length(aws_subnet.expand)
#   subnet_id = element([
#     for az, subnet in aws_subnet.expand: subnet.id
#   ], count.index)
#   route_table_id = element(aws_route_table.expand[*].id, count.index)
# }

###################################################################################
# Database Route
###################################################################################
# Route table: attach Internet Gateway 
resource "aws_route_table" "rds" {
  count = length(aws_subnet.rds)
  
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = element([
      for key, value in aws_nat_gateway.nat: value.id
    ], count.index)
  }
  tags = {
    Name = format("%s-%s", var.svr_nm, "rds${count.index+1}")
  }
}

# Route Table connect subnets
resource "aws_route_table_association" "rds" {
  count = length(aws_subnet.rds)
  subnet_id = element([
    for az, subnet in aws_subnet.rds: subnet.id
  ], count.index)
  route_table_id = element(aws_route_table.rds[*].id, count.index)
}
