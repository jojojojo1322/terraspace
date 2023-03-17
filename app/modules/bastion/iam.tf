###################################################################################
# IAM Role for Bastion Host
###################################################################################
data "aws_iam_policy_document" "bastion" {
  statement {
    effect = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

# IAM role for bastion host
resource "aws_iam_role" "bastion" {
  name = format("%s-%s", var.svr_nm, "bastion")
  assume_role_policy = data.aws_iam_policy_document.bastion.json
}

# IAM role attachment AmazonEC2RoleforSSM policy
resource "aws_iam_role_policy_attachment" "bastion_AmazonEC2RoleforSSM" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2RoleforSSM"
  role = aws_iam_role.bastion.name
}

# IAM role attachment AmazonSSMManagedInstanceCore policy
resource "aws_iam_role_policy_attachment" "bastion_AmazonSSMManagedInstanceCore" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  role = aws_iam_role.bastion.name
}

# IAM instance profile 생성
resource "aws_iam_instance_profile" "bastion" {
  name = format("%s-%s", var.svr_nm, "bastion")
  role = aws_iam_role.bastion.name
}