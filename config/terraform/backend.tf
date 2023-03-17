terraform {
  backend "s3" {
    bucket         = "<%= expansion('topas-state-:ENV') %>"
    key            = "<%= expansion(':PROJECT/:TYPE_DIR/:MOD_NAME/:ENV/topas.tfstate') %>"
    region         = "<%= expansion(':REGION') %>"
    encrypt        = true
    dynamodb_table = "topas-locks-hjcho"
  }
}
