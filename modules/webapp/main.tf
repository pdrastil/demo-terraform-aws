#######################
# Packer - Golden AMI #
#######################
resource "null_resource" "packer" {
  triggers = {
    app_version = var.app_version
    json_sha    = filesha256("aws_ami.json")
  }

  provisioner "local-exec" {
    command = <<EOD
packer build \
  -var version=${var.app_version} \
  -var aws_region=${var.region} \
  -var vpc_id=${var.vpc.id} \
  aws_ami.json
EOD
  }

  provisioner "local-exec" {
    when    = destroy
    command = <<EOD
AMI_ID=$(
  aws ec2 describe-images \
    --owners "self" \
    --filters "Name=name,Values=demo" \
    --query "sort_by(Images, &CreationDate)[-1].[ImageId]" \
    --output "text"
)

aws ec2 deregister-image --image-id $AMI_ID
EOD
  }
}

#################
# EC 2 resource #
#################
resource "aws_key_pair" "auth" {
  key_name   = "webapp"
  public_key = file(var.public_key_path)
}

data "aws_ami" "golden_ami" {
  depends_on  = [null_resource.packer]
  owners      = ["self"]
  most_recent = true

  filter {
    name   = "name"
    values = ["demo"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

###################
# Security Groups #
###################

# Public
resource "aws_security_group" "public_sg" {
  name        = "webapp_public_sg"
  description = "Used for elastic load balancer for public access"
  vpc_id      = var.vpc.id

  # HTTP
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Private
resource "aws_security_group" "private_sg" {
  name        = "webapp_private_sg"
  description = "Used for private instances"
  vpc_id      = var.vpc.id

  # Access from VPC
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.vpc.cidr_block]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

##################
# Load balancers #
##################
resource "aws_elb" "elb" {
  name                      = "webapp-elb"
  idle_timeout              = 400
  cross_zone_load_balancing = true
  subnets                   = [for s in var.public_subnets : s.id]

  # Finish receiving traffic before ELB is destroyed
  connection_draining         = true
  connection_draining_timeout = 400

  security_groups = [
    aws_security_group.public_sg.id
  ]

  listener {
    instance_port     = 80
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }

  health_check {
    target              = "TCP:80"
    timeout             = var.elb_timeout
    interval            = var.elb_interval
    healthy_threshold   = var.elb_healthy_threshold
    unhealthy_threshold = var.elb_unhealthy_threshold
  }

  tags = {
    Application = "webapp"
  }
}

#####################
# Autoscaling group #
#####################
resource "aws_launch_configuration" "webapp" {
  name_prefix     = "webapp_lc-"
  image_id        = data.aws_ami.golden_ami.image_id
  instance_type   = var.app_instance_type
  security_groups = [aws_security_group.private_sg.id]
  key_name        = aws_key_pair.auth.id

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "asg" {
  name                 = "asg-${aws_launch_configuration.webapp.id}"
  launch_configuration = aws_launch_configuration.webapp.name
  load_balancers       = [aws_elb.elb.id]
  vpc_zone_identifier  = [for s in var.private_subnets : s.id]

  # Desired state
  min_size                  = var.asg_min
  max_size                  = var.asg_max
  health_check_grace_period = var.asg_grace
  health_check_type         = var.asg_hct
  desired_capacity          = var.asg_cap

  tag {
    key                 = "Name"
    value               = "webapp_asg-instance"
    propagate_at_launch = true
  }

  lifecycle {
    create_before_destroy = true
  }

  force_delete = true
}
