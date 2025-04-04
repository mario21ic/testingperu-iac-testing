module "web_server_sg" {
  # source = "terraform-aws-modules/security-group/aws//modules/http-80"
  source = "terraform-aws-modules/security-group/aws"

  name        = "web-server"
  description = "Security group for web-server with HTTP ports open within VPC"
  vpc_id      = data.aws_vpc.default.id

  # ingress_cidr_blocks = ["10.10.0.0/16"]

  egress_rules = [ "all-all" ]
  ingress_cidr_blocks      = ["10.10.0.0/16"]
    # ingress_rules            = ["https-443-tcp"]

    ingress_with_cidr_blocks = [
      {
          from_port   = 80
          to_port     = 80
          protocol    = "tcp"
          description = "Web-service ports"
          # cidr_blocks = "10.10.0.0/16"
          cidr_blocks = "0.0.0.0/0"
      },
      # {
      #     rule        = "postgresql-tcp"
      #     # cidr_blocks = "0.0.0.0/0"
      #     cidr_blocks = "181.224.236.154/32"
      # },
    ]
}

module "ec2_instance" {
  source  = "terraform-aws-modules/ec2-instance/aws"

  name = "single-instance"

  instance_type          = var.instance_type
  ami                    = data.aws_ami.amazonlinux.id
  # key_name               = "user1"
  monitoring             = false

  vpc_security_group_ids = [module.web_server_sg.security_group_id]
  subnet_id              = slice(data.aws_subnets.example.ids, 0, 2)[0]
  associate_public_ip_address = false

  create_iam_instance_profile = true
  iam_role_description        = "IAM role for EC2 instance"
  iam_role_policies = {
    # AmazonSSMManagedInstanceCore = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
    AmazonEC2FullAccess = "arn:aws:iam::aws:policy/AmazonEC2FullAccess"
  }

  tags = {
    Terraform   = "true"
    Environment = "dev"
  }
}


module "s3_bucket" {
  source = "terraform-aws-modules/s3-bucket/aws"

  bucket = "mario21ic-mys3-alb-logs"
  acl    = "private"

  control_object_ownership = true
  object_ownership         = "ObjectWriter"

  versioning = {
    enabled = false
  }
}

module "alb" {
  source = "terraform-aws-modules/alb/aws"

  name    = "my-alb"
  vpc_id  = data.aws_vpc.default.id
  subnets = slice(data.aws_subnets.example.ids, 0, 2)

  # Security Group
  security_group_ingress_rules = {
    all_http = {
      from_port   = 80
      to_port     = 80
      ip_protocol = "tcp"
      description = "HTTP web traffic"
      cidr_ipv4   = "0.0.0.0/0"
    }
    # all_https = {
    #   from_port   = 443
    #   to_port     = 443
    #   ip_protocol = "tcp"
    #   description = "HTTPS web traffic"
    #   cidr_ipv4   = "0.0.0.0/0"
    # }
  }
  security_group_egress_rules = {
    all = {
      ip_protocol = "-1"
      cidr_ipv4   = "10.0.0.0/16"
    }
  }

  # access_logs = {
  #   bucket = module.s3_bucket.s3_bucket_id
  # }


  target_groups = {
    ex-instance = {
      name_prefix      = "h1"
      protocol         = "HTTP"
      port             = 80
      target_type      = "instance"
      target_id        = module.ec2_instance.id
    }
  }

  listeners = {
    http = {
      port     = 80
      protocol = "HTTP"
      forward = {
        target_group_key = "ex-instance"
      }
    }

    # ex-http-https-redirect = {
    #   port     = 80
    #   protocol = "HTTP"
    #   redirect = {
    #     port        = "443"
    #     protocol    = "HTTPS"
    #     status_code = "HTTP_301"
    #   }
    # }
    # ex-https = {
    #   port            = 443
    #   protocol        = "HTTPS"
    #   certificate_arn = "arn:aws:iam::123456789012:server-certificate/test_cert-123456789012"

    #   forward = {
    #     target_group_key = "ex-instance"
    #   }
    # }
  }

  tags = {
    Environment = "Development"
    Project     = "Example"
  }
}