
module "ec2_instance" {
  source  = "terraform-aws-modules/ec2-instance/aws"

  name = "single-instance"

  instance_type          = var.instance_type
  ami                    = data.aws_ami.amazonlinux.id
  key_name               = "mario21ic-virginia"
  monitoring             = false

  vpc_security_group_ids = [aws_security_group.allow_web.id]
  subnet_id              = slice(data.aws_subnets.example.ids, 0, 2)[0]
  associate_public_ip_address = true

  create_iam_instance_profile = true
  iam_role_description        = "IAM role for EC2 instance"
  iam_role_policies = {
    AmazonSSMManagedInstanceCore = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  }

  tags = {
    Project     = "Example"
    Environment = "Development"
    Tool        = "Terraform" # fix Policy as Code
  }
}

resource "aws_lb_target_group" "http" {
  name     = "http-target-group"
  port     = 80
  protocol = "HTTP"
  target_type = "instance"
  vpc_id = data.aws_vpc.default.id

  health_check {
    path = "/" # AQUI estaba el bug, estaba como "/health_check"
    port = "traffic-port"
    protocol = "HTTP"
  }
}
resource "aws_lb_target_group_attachment" "http" {
  target_group_arn = aws_lb_target_group.http.arn
  target_id        = module.ec2_instance.id
  port             = 80
}

resource "aws_lb" "my_alb" {
  name               = "new-alb"
  internal           = false
  load_balancer_type = "application"

  drop_invalid_header_fields = true
  
  security_groups    = [aws_security_group.lb_sg.id]
  subnets            = slice(data.aws_subnets.example.ids, 0, 2)

  enable_deletion_protection = false
  idle_timeout               = 60

  tags = {
    Project     = "Example"
    Environment = "Development"
    Tool        = "Terraform" # fix Policy as Code
  }
}

resource "aws_lb_listener" "listener_http" {
  load_balancer_arn = aws_lb.my_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.http.arn
  }
}



module "s3_bucket" {
  source = "terraform-aws-modules/s3-bucket/aws"

  bucket = "${var.bucket_prefix}-mys3-alb-logs"
  acl    = "private"
  # acl    = "public-read" # BUG: bucket cannot be public

  control_object_ownership = true
  object_ownership         = "ObjectWriter"

  versioning = {
    enabled = false
  }
}

# # Test bucket
# resource "aws_s3_bucket" "bucket_demo" {
#   bucket = "${var.bucket_prefix}-mybucket"
# }

# output "bucket_name" {
#   value = aws_s3_bucket.bucket_demo.bucket
# }
