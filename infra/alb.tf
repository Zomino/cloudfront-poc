resource "aws_lb" "cf_poc" {
  name               = "cf-poc"
  load_balancer_type = "application"
  internal           = true
  subnets            = data.aws_subnets.default.ids
  security_groups    = [aws_security_group.cf_poc_alb.id]
}

resource "aws_security_group" "cf_poc_alb" {
  name   = "cf-poc-alb"
  vpc_id = data.aws_vpc.default.id
}

# AWS-managed IP range for CloudFront
# See https://docs.aws.amazon.com/vpc/latest/userguide/working-with-aws-managed-prefix-lists.html
data "aws_ec2_managed_prefix_list" "cloudfront" {
  name = "com.amazonaws.global.cloudfront.origin-facing"
}

resource "aws_vpc_security_group_ingress_rule" "cf_poc_cf_to_alb" {
  security_group_id = aws_security_group.cf_poc_alb.id
  from_port         = 80
  to_port           = 80
  ip_protocol       = "tcp"
  prefix_list_id    = data.aws_ec2_managed_prefix_list.cloudfront.id
}

resource "aws_vpc_security_group_egress_rule" "cf_poc_alb_to_all" {
  security_group_id = aws_security_group.cf_poc_alb.id
  ip_protocol       = "-1"
  cidr_ipv4         = "0.0.0.0/0"
}

resource "aws_lb_target_group" "cf_poc_lambda" {
  name        = "cf-poc-lambda"
  target_type = "lambda"
}

resource "aws_lb_target_group_attachment" "cf_poc_lambda" {
  target_group_arn = aws_lb_target_group.cf_poc_lambda.arn
  target_id        = aws_lambda_function.cf_poc.arn

  depends_on = [aws_lambda_permission.cf_poc_lambda_allow_alb]
}

resource "aws_lb_listener" "cf_poc_lambda" {
  load_balancer_arn = aws_lb.cf_poc.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.cf_poc_lambda.arn
  }
}
