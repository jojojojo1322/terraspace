###################################################################################
# Public Subnet :: Bastion Host & NAT Gateway
###################################################################################
resource "aws_subnet" "public" {
  vpc_id = aws_vpc.main.id
  
  for_each = var.subnets.public
  availability_zone = each.value
  cidr_block = each.key
  map_public_ip_on_launch = true

  tags = {
    Name = format("%s-%s", var.svr_nm, "public${split(".", each.key)[2]}")
    Environments = var.env
    "kubernetes.io/cluster/${local.cluster_nm}" = "shared"
    "kubernetes.io/role/elb" = 1
  }
}

###################################################################################
# Private Subnet :: Worker Nodes on Cluster or Web Server
###################################################################################
resource "aws_subnet" "private" {
    vpc_id = aws_vpc.main.id

    for_each = var.subnets.private
    availability_zone = each.value
    cidr_block = each.key
    
    tags = {
        Name = format("%s-%s", var.svr_nm, "private${substr(each.key, 9, 1)}")
        Environments = var.env
        "kubernetes.io/cluster/${local.cluster_nm}" = "shared"
        "kubernetes.io/role/internal-elb" = 1
        "karpenter.sh/discovery" = local.cluster_nm
    }
}



###################################################################################
# Database Private Subnet
###################################################################################
resource "aws_subnet" "rds" {
  vpc_id = aws_vpc.main.id
  
  for_each = var.enable_rds_subnet ? var.subnets.rds : {}
  availability_zone = each.value
  cidr_block = each.key
  
  tags = {
    Name = format("%s-%s", var.svr_nm, "rds${substr(each.key, 10, 1)}")
    Environments = var.env
  }
}
