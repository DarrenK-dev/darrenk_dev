
data "aws_lb" "alb" {
  name = "alb"
  depends_on = [
    aws_lb.alb
  ]
}

output "alb_public_ip" {
  value = data.aws_lb.alb.dns_name
}