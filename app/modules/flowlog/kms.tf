###################################################################################
# AWS KMS KEY 생성
###################################################################################
resource "aws_kms_key" "eks" {
    description = "EKS Secret Encryption Key"
    deletion_window_in_days = 7
    enable_key_rotation = true
    policy = <<EOF
{
  "Version" : "2012-10-17",
  "Id" : "key-default-1",
  "Statement" : [ {
      "Sid" : "Enable IAM User Permissions",
      "Effect" : "Allow",
      "Principal" : {
        "AWS" : "arn:aws:iam::${var.account}:root"
      },
      "Action" : "kms:*",
      "Resource" : "*"
    },
    {
      "Effect": "Allow",
      "Principal": { "Service": "logs.${var.region}.amazonaws.com" },
      "Action": [ 
        "kms:Encrypt*",
        "kms:Decrypt*",
        "kms:ReEncrypt*",
        "kms:GenerateDataKey*",
        "kms:Describe*"
      ],
      "Resource": "*"
    }  
  ]
}
EOF

    tags = {
        Name = format("%s-%s", local.cluster_nm, "kms")
        Environment = var.env
    }
}
