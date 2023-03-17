###################################################################################
# Bastion Host
###################################################################################
resource "aws_instance" "bastion" {
  ami = var.ami
  instance_type = var.instance_type
  iam_instance_profile = aws_iam_instance_profile.bastion.name

  count = length(var.public_subnet_ids)
  subnet_id = element(var.public_subnet_ids, count.index)
  key_name = aws_key_pair.bastion.key_name
  vpc_security_group_ids = [aws_security_group.bastion.id]

  tags = {
    Name = format("%s-%s", var.svr_nm, "bastion${count.index+1}")
    Environments = var.env
  }

  # SSM::System Management 설치
  connection {
    type = "ssh"
    host = self.public_ip
    user = "ec2-user"
    private_key = tls_private_key.bastion.private_key_pem
    timeout = "2m"
  }

  provisioner "remote-exec" {
    inline = [
      "cd /tmp",
      "sudo yum install -y https://s3.amazonaws.com/ec2-downloads-windows/SSMAgent/latest/linux_amd64/amazon-ssm-agent.rpm",
      "sudo systemctl enable amazon-ssm-agent",
      "sudo systemctl start amazon-ssm-agent",
      "sudo amazon-linux-extras install -y postgresql11"
    ]
  }
}