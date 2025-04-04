# LOAD BALANCER
resource "aws_security_group" "lb_sg" {
  name        = "lb_sg"
  description = "Allow all inbound traffic and all outbound traffic"
  vpc_id      = data.aws_vpc.default.id

  tags = {
    # Name        = "lb_sg"
    Tool        = "Terraform" # fix Policy as Code
  }
}
resource "aws_vpc_security_group_ingress_rule" "allow_lb_ipv4" {
  security_group_id = aws_security_group.lb_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80
  ip_protocol       = "tcp"
  to_port           = 80
}
resource "aws_vpc_security_group_egress_rule" "allow_all_lb_ipv4" {
  security_group_id = aws_security_group.lb_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}
resource "aws_vpc_security_group_egress_rule" "allow_all_lb_ipv6" {
  security_group_id = aws_security_group.lb_sg.id
  cidr_ipv6         = "::/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}

# WEB SERVER
resource "aws_security_group" "allow_web" {
  depends_on = [aws_security_group.lb_sg]
  
  name        = "allow_web"
  description = "Allow Web inbound traffic and all outbound traffic"
  vpc_id      = data.aws_vpc.default.id

  tags = {
    Name = "allow_web"
  }
}
resource "aws_vpc_security_group_ingress_rule" "allow_web_ipv4" {
  security_group_id = aws_security_group.allow_web.id

#   cidr_ipv4         = "0.0.0.0/0" # BUG: All IP addresses
  referenced_security_group_id = aws_security_group.lb_sg.id # BUG FIXED

  from_port         = 80
  ip_protocol       = "tcp"
  to_port           = 80
}
# resource "aws_vpc_security_group_ingress_rule" "allow_web_ipv6" {
#   security_group_id = aws_security_group.allow_web.id
#   cidr_ipv6         = data.aws_vpc.default.ipv6_cidr_block
#   from_port         = 80
#   ip_protocol       = "tcp"
#   to_port           = 80
# }
resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv4" {
  security_group_id = aws_security_group.allow_web.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}
resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv6" {
  security_group_id = aws_security_group.allow_web.id
  cidr_ipv6         = "::/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}

