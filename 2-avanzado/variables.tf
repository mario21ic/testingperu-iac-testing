variable "region" {
  type    = string
  default = "us-east-1"
}

variable "instance_type" {
  type    = string
  default = "t2.micro"
}

variable "bucket_prefix" {
  type    = string
#   default = "test"
}
