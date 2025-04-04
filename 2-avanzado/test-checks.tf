check "response" {
  data "http" "alb_health_check" {
    url      = "http://${aws_lb.my_alb.dns_name}/"
    insecure = true
  }

  assert {
    condition     = data.http.alb_health_check.status_code == 202
    error_message = "ALB responses is ${data.http.alb_health_check.status_code}"
  }
}
