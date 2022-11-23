#Create App load balancer
resource "aws_lb" "application-lb" {
  provider           = aws.region
  name               = "cloudres-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.sg.id]
  subnets            = [aws_subnet.web[0].id, aws_subnet.web[1].id]
  tags = {
    Name = "cloudres-LB"
  }
}


#Create app load balancer target group
resource "aws_lb_target_group" "app-lb-tg" {
  provider    = aws.region
  name        = "app-lb-tg"
  port        = var.webserver-port
  target_type = "instance"
  vpc_id      = aws_vpc.vpc_master.id
  protocol    = "HTTP"
  health_check {
    enabled  = true
    interval = 15
    path     = "/"
    port     = var.webserver-port
    protocol = "HTTP"
    matcher  = "200-299"
  }
  tags = {
    Name = "cloudres-target-group"
  }
}

#ALB listener on tcp/443 HTTPS
resource "aws_lb_listener" "cloudres-listener-https" {
  provider          = aws.region
  load_balancer_arn = aws_lb.application-lb.arn
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  port              = "443"
  protocol          = "HTTPS"
  certificate_arn   = aws_acm_certificate.cloudres-lb-https.arn
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app-lb-tg.arn
  }
}

#ALB listener on TCP/80 and redirect to https/443
resource "aws_lb_listener" "cloudres-listener-http" {
  provider          = aws.region
  load_balancer_arn = aws_lb.application-lb.arn
  port              = "80"
  protocol          = "HTTP"
  default_action {
    type = "redirect"
    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}


resource "aws_lb_target_group_attachment" "cloudres-attach" {
  count            = length(aws_instance.web-node.*.id)
  provider         = aws.region
  target_group_arn = aws_lb_target_group.app-lb-tg.arn
  target_id        = aws_instance.web-node[0].id
  port             = var.webserver-port
}