###############################################################
# 생성된 VPC ID
###############################################################
output "vpc_id" {
  value = aws_vpc.main.id
  sensitive = false
}

###############################################################
# 생성된 서브넷 ID 목록
###############################################################
# 1. public 서브넷
output "public_subnet_ids" {
  value = [
    for az, subnet in aws_subnet.public: subnet.id
  ]
}

# 2. private 서브넷
output "private_subnet_ids" {
  value = [
    for az, subnet in aws_subnet.private: subnet.id
  ]
}

# # 3. expand 서브넷
# output "expand_subnet_ids" {
#   value = [
#     for az, subnet in aws_subnet.expand: subnet.id
#   ]
# }

# 4. rds(private) 서브넷
output "rds_subnet_ids" {
  value = [
    for az, subnet in aws_subnet.rds: subnet.id
  ]
}

###############################################################
# 생성된 Gateway ID
###############################################################
# 1. Internet Gateway ID
output "gateway_id" {
  value = aws_internet_gateway.igw.id
}

# 2. NAT Gateway ID
output "nat_ids" {
  value = [
    for key, value in aws_nat_gateway.nat: value.id
  ]
}

###############################################################
# 생성된 public route id
###############################################################
output "public_route_id" {
  value = aws_route_table.public.id
}

###############################################################
# 생성된 private route id
###############################################################
output "private_route_ids" {
  value = [aws_route_table.private.*.id]
}

###############################################################
# 생성된 rds route id
###############################################################
output "rds_route_ids" {
  value = [aws_route_table.rds.*.id]
}
