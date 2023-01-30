locals {
  aws_region = "us-east-1"
}

inputs = {
  aws_region  = local.aws_region
  s3_endpoint = "com.amazonaws.${local.aws_region}.s3"
}

locals {
  x = 2
  y = 40
  answer = local.x + local.y
}