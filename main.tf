provider "aws" {
  region                   = "ap-south-1"
  shared_credentials_files = ["~/.aws/credentials"]
}
resource "aws_vpc" "my_vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "my_vpc"
  }
}
resource "aws_subnet" "my_public_subnet1" {
  vpc_id                  = aws_vpc.my_vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "ap-south-1a"
  map_public_ip_on_launch = true
}
resource "aws_subnet" "my_public_subnet2" {
  vpc_id                  = aws_vpc.my_vpc.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "ap-south-1b"
  map_public_ip_on_launch = true
}
resource "aws_subnet" "my_private_subnet1" {
  vpc_id            = aws_vpc.my_vpc.id
  cidr_block        = "10.0.3.0/24"
  availability_zone = "ap-south-1a"
}
resource "aws_subnet" "my_private_subnet2" {
  vpc_id            = aws_vpc.my_vpc.id
  cidr_block        = "10.0.4.0/24"
  availability_zone = "ap-south-1b"
}
resource "aws_internet_gateway" "my_igw" {
  vpc_id = aws_vpc.my_vpc.id
}
resource "aws_route_table" "my_private_route_table" {
  vpc_id = aws_vpc.my_vpc.id
}
resource "aws_route_table" "my_public_route_table" {
  vpc_id = aws_vpc.my_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.my_igw.id
  }
}
resource "aws_route_table_association" "my_public_subnet1_association" {
  subnet_id      = aws_subnet.my_public_subnet1.id
  route_table_id = aws_route_table.my_public_route_table.id
}
resource "aws_route_table_association" "my_public_subnet2_association" {
  subnet_id      = aws_subnet.my_public_subnet2.id
  route_table_id = aws_route_table.my_public_route_table.id
}
resource "aws_route_table_association" "my_private_subnet1_association" {
  subnet_id      = aws_subnet.my_private_subnet1.id
  route_table_id = aws_route_table.my_private_route_table.id
}
resource "aws_route_table_association" "my_private_subnet2_association" {
  subnet_id      = aws_subnet.my_private_subnet2.id
  route_table_id = aws_route_table.my_private_route_table.id
}
resource "aws_security_group" "my_security_group" {
  name        = "my_security_group"
  description = "Allow SSH and HTTP"
  vpc_id      = aws_vpc.my_vpc.id
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 8
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
resource "aws_instance" "my_ec2_instance" {
  ami                    = "ami-0f19324397f53458f"
  instance_type          = "t3.micro"
  subnet_id              = aws_subnet.my_public_subnet1.id
  vpc_security_group_ids = [aws_security_group.my_security_group.id]
  tags = {
    Name = "my_ec2_instance"
  }
}
resource "aws_instance" "my_ec2_instance2" {
  ami                    = "ami-0f19324397f53458f"
  instance_type          = "t3.micro"
  subnet_id              = aws_subnet.my_public_subnet2.id
  vpc_security_group_ids = [aws_security_group.my_security_group.id]
  tags = {
    Name = "my_ec2_instance2"
  }
}
resource "aws_lb" "my_load_balancer" {
  name               = "my-load-balancer"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.my_security_group.id]
  subnets            = [aws_subnet.my_public_subnet1.id, aws_subnet.my_public_subnet2.id]
  tags = {
    name = "my_application_load_balancer"
  }
}
resource "aws_lb_target_group" "my_target_group" {
  name     = "my-target-group"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.my_vpc.id
}
resource "aws_lb_listener" "my_listener" {
  load_balancer_arn = aws_lb.my_load_balancer.arn
  port              = 80
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.my_target_group.arn
  }
}
resource "aws_lb_target_group_attachment" "my_target_group_attachment1" {
  target_group_arn = aws_lb_target_group.my_target_group.arn
  target_id        = aws_instance.my_ec2_instance.id
  port             = 80
}
resource "aws_lb_target_group_attachment" "my_target_group_attachment2" {
  target_group_arn = aws_lb_target_group.my_target_group.arn
  target_id        = aws_instance.my_ec2_instance2.id
  port             = 80
}
resource "aws_launch_template" "dilu_template" {
  name          = "dilu_template"
  image_id      = "ami-0f19324397f53458f"
  instance_type = "t3.micro"
  vpc_security_group_ids = [
    aws_security_group.my_security_group.id
  ]
  tag_specifications {
    resource_type = "instance"              
  tags = {
    name = "Asg_instance"
  }
  }
}

resource "aws_autoscaling_group" "dilu_scaling" {
  name             = "dilu_scaling"
  min_size         = 2
  max_size         = 4
  desired_capacity = 2
  vpc_zone_identifier = [
    aws_subnet.my_public_subnet1.id,
    aws_subnet.my_public_subnet2.id
  ]
  target_group_arns = [
    aws_lb_target_group.my_target_group.arn
  ]
  launch_template {
    id      = aws_launch_template.dilu_template.id
    version = "$Latest"
  }
  health_check_type         = "ELB"
  health_check_grace_period = 300
  tag {
    key                 = "name"
    value               = "dilu_scaling"
    propagate_at_launch = true
  }
}
