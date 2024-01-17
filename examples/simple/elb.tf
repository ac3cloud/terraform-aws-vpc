

resource "aws_instance" "default" {
  count = 2
  ami           = "ami-083327d0fe6d65178" # Use an appropriate Linux AMI ID
  instance_type = "t3.nano"
  subnet_id     = module.vpc.private_subnets[1]

  tags = {
    Name           = "example-instance-${count.index + 1}"
    #Create a tag first for all exisitng EC2 instances.
    elb_attachable = "true"
  }

  # After apply terraform tag , adding lifecycle. Then apply again. This will disable terraform to detect the changes of this tag value in the future.
  lifecycle {
    ignore_changes = [tags["elb_attachable"]]
  }
}

# This is mock target group.
resource "aws_alb_target_group" "TestTargetGroup" {

  health_check {
    interval            = 20
    path                = "/health-check/"
    port                = "traffic-port"
    protocol            = "HTTP"
    timeout             = 19
    unhealthy_threshold = 5
    healthy_threshold   = 5
    matcher             = "200"
  }
  port        = 80
  protocol    = "HTTP"
  target_type = "instance"
  vpc_id      = module.vpc.vpc_id
  name        = "test-target-group"

  stickiness {
    type            = "lb_cookie"
    enabled         = true
    cookie_duration = 300
  }

}


# Important! Create a data object to get the ids from the instances list. and filter the tag value of elb_attachable=true. 
# You can manually update the instances that you dont want to join ELB target by setting this value to false on each instance

data "aws_instances" "elb_attachable" {
  instance_tags = {
    elb_attachable = "true"
  }
  filter{
    name ="instance-id"
    values= aws_instance.default[*].id
  }
}

# Attachement
resource "aws_lb_target_group_attachment" "http" {
  count            = length(data.aws_instances.elb_attachable.ids)
  target_group_arn = aws_alb_target_group.TestTargetGroup.arn
  target_id        = data.aws_instances.elb_attachable.ids[count.index]
  port             = 80
}
