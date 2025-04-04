data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "example" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

data "aws_ami" "amazonlinux" {
    most_recent = true
    owners      = ["137112412989"] # amazon

    filter {
        name   = "architecture"
        values = ["x86_64"]
    }
    filter {
        name   = "name"
        values = ["al2023-ami-2023.*-kernel-*-x86_64"]
    }
    filter {
        name   = "root-device-type"
        values = ["ebs"]
    }
    
}