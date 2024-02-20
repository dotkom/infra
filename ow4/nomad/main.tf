locals {
  server_ami = "ami-0dadf2e6f7b9397fc"
  client_ami = "ami-0e713f687e54ceca4"

  subnets              = ["subnet-6eca3807", "subnet-85457acf", "subnet-4bfbe633"]
  consul_datacenter    = "aws-eu-north-1"
  nomad_datacenter     = "aws-eu-north-1"
  server_static_ip     = "172.31.25.63"
  spot_price_max       = "0.03"
  server_instance_type = "t3.micro"
}

data "aws_route53_zone" "online" {
  name = "online.ntnu.no"
}

data "aws_subnet" "selected" {
  id = local.subnets[0]
}

data "aws_vpc" "selected" {
  id = data.aws_subnet.selected.vpc_id
}

data "aws_region" "current" {}

data "consul_acl_token_secret_id" "client" {
  accessor_id = consul_acl_token.client.id
}

data "consul_acl_token_secret_id" "server" {
  accessor_id = consul_acl_token.server.id
}

data "template_cloudinit_config" "server" {
  gzip          = true
  base64_encode = true

  part {
    content_type = "text/cloud-config"
    content = templatefile("./files/cloud-config-server.tpl", {
      consul_vars = base64encode(yamlencode({
        datacenter         = local.consul_datacenter
        primary_datacenter = local.consul_datacenter
        retry_join         = ["provider=aws tag_key=consul tag_value=server"]
        acl_token          = data.consul_acl_token_secret_id.server.secret_id
      }))
      nomad_vars = base64encode(yamlencode({
        datacenter = local.nomad_datacenter
      }))
      }
    )
  }

  part {
    content_type = "text/x-shellscript"
    content      = file("./files/mount-ebs-volume.sh")
  }
}

data "template_cloudinit_config" "client" {
  gzip = true

  part {
    content_type = "text/cloud-config"
    content = templatefile("./files/cloud-config-client.tpl", {
      consul_vars = base64encode(yamlencode({
        datacenter         = "aws-eu-north-1"
        primary_datacenter = "aws-eu-north-1"
        retry_join         = ["provider=aws tag_key=consul tag_value=server"]
        acl_token          = data.consul_acl_token_secret_id.client.secret_id
      }))
      nomad_vars = base64encode(yamlencode({
        datacenter = "aws-eu-north-1"
      }))
      }
    )
  }
}


resource "aws_acm_certificate" "cert" {
  domain_name               = "online.ntnu.no"
  subject_alternative_names = ["*.online.ntnu.no"]
  validation_method         = "DNS"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_lb_target_group" "http_ingress" {
  name        = "http-ingress"
  port        = 80
  protocol    = "HTTP"
  target_type = "instance"
  vpc_id      = data.aws_vpc.selected.id

  health_check {
    path     = "/ping"
    interval = 300
    port     = 81
  }
}

resource "aws_lb_listener" "https" {
  load_balancer_arn = aws_lb.main.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = aws_acm_certificate.cert.arn
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.http_ingress.arn
  }
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.main.arn
  port              = "80"

  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

resource "aws_lb" "main" {
  name                       = "main-lb"
  internal                   = false
  load_balancer_type         = "application"
  security_groups            = [aws_security_group.lb.id]
  subnets                    = local.subnets
  enable_deletion_protection = true

}

resource "aws_route53_record" "nomad" {
  zone_id = data.aws_route53_zone.online.zone_id
  name    = "nomad.online.ntnu.no"
  type    = "A"
  ttl     = "60"
  records = toset([aws_eip.server.public_ip])
}

resource "aws_route53_record" "lb" {
  zone_id = data.aws_route53_zone.online.zone_id
  name    = "lb.online.ntnu.no"
  type    = "A"
  alias {
    name                   = aws_lb.main.dns_name
    zone_id                = aws_lb.main.zone_id
    evaluate_target_health = false
  }
}

resource "consul_acl_token" "client" {
  description = "Nomad client"
  policies    = ["nomad-client"]
}

resource "consul_acl_token" "server" {
  description = "Nomad server"
  policies    = ["nomad-server"]
}


resource "aws_iam_role" "server" {
  name               = "nomad-server"
  path               = "/"
  assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": "sts:AssumeRole",
            "Principal": {
               "Service": "ec2.amazonaws.com"
            },
            "Effect": "Allow",
            "Sid": ""
        }
    ]
}
EOF
}

resource "aws_iam_policy" "server" {
  name        = "nomad-server"
  description = "nomad server policy to enable cloud auto join for consul agent"
  policy      = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "ec2:DescribeInstances",
        "ec2:DescribeTags",
        "ec2:DescribeVolumes",
        "ec2:AttachVolume",
        "ec2:DetachVolume"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "server" {
  role       = aws_iam_role.server.name
  policy_arn = aws_iam_policy.server.arn
}

resource "aws_iam_instance_profile" "server" {
  name = "nomad-server"
  role = aws_iam_role.server.name
}



resource "aws_eip" "server" {
  vpc      = true
  instance = aws_instance.server.id
}
resource "aws_instance" "server" {
  ami           = local.server_ami
  instance_type = local.server_instance_type

  iam_instance_profile   = aws_iam_instance_profile.server.id
  private_ip             = local.server_static_ip
  subnet_id              = local.subnets[0]
  vpc_security_group_ids = [aws_security_group.server.id]

  root_block_device {
    volume_size = 20
  }

  user_data_base64 = data.template_cloudinit_config.server.rendered
  tags = {
    consul = "client"
    Name   = "nomad server"
  }
}

resource "aws_ebs_volume" "data" {
  availability_zone = data.aws_subnet.selected.availability_zone
  size              = 20

  tags = {
    Name = "nomad server storage"
  }
}

resource "aws_volume_attachment" "data_attachment" {
  device_name = "/dev/sdh"
  volume_id   = aws_ebs_volume.data.id
  instance_id = aws_instance.server.id
}


resource "aws_autoscaling_group" "clients" {
  name                = "nomad-clients"
  capacity_rebalance  = true
  vpc_zone_identifier = local.subnets
  desired_capacity    = 4
  max_size            = 5
  min_size            = 1

  target_group_arns = [aws_lb_target_group.http_ingress.arn]

  mixed_instances_policy {
    instances_distribution {
      spot_allocation_strategy = "capacity-optimized-prioritized"
      spot_max_price           = local.spot_price_max
    }
    launch_template {

      launch_template_specification {
        launch_template_id   = aws_launch_template.clients.id
        launch_template_name = aws_launch_template.clients.latest_version
      }

      override {
        instance_type = "m5.large"
      }
      override {
        instance_type = "m5d.large"
      }
      override {
        instance_type = "c5.large"
      }
      override {
        instance_type = "t3.large"
      }
    }
  }

}

resource "aws_placement_group" "clients" {
  name     = "nomad-clients-"
  strategy = "cluster"
}

resource "aws_iam_role" "client" {
  name               = "nomad-client"
  path               = "/"
  assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": "sts:AssumeRole",
            "Principal": {
               "Service": "ec2.amazonaws.com"
            },
            "Effect": "Allow",
            "Sid": ""
        }
    ]
}
EOF
}


resource "aws_iam_policy" "client" {
  name        = "nomad-client"
  description = "nomad client policy to enable cloud auto join for consul agent"
  policy      = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "ec2:CreateSnapshot",
        "ec2:AttachVolume",
        "ec2:DetachVolume",
        "ec2:ModifyVolume",
        "ec2:DescribeAvailabilityZones",
        "ec2:DescribeInstances",
        "ec2:DescribeSnapshots",
        "ec2:DescribeTags",
        "ec2:DescribeVolumes",
        "ec2:DescribeVolumesModifications",
        "ec2:DeleteVolume",
        "ec2:DeleteSnapshot",
        "ec2:CreateVolume"
      ],
      "Effect": "Allow",
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "ec2:DeleteTags",
        "ec2:CreateTags"
      ],
      "Resource": [
        "arn:aws:ec2:*:*:volume/*",
        "arn:aws:ec2:*:*:snapshot/*"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "elasticfilesystem:DescribeAccessPoints",
        "elasticfilesystem:DescribeFileSystems",
        "elasticfilesystem:CreateAccessPoint",
        "elasticfilesystem:DeleteAccessPoint",
        "elasticfilesystem:DescribeMountTargets"
      ],
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "client" {
  role       = aws_iam_role.client.name
  policy_arn = aws_iam_policy.client.arn
}

resource "aws_iam_instance_profile" "client" {
  name = "nomad-client"
  role = aws_iam_role.client.name
}

resource "aws_launch_template" "clients" {
  name        = "nomad-client"
  description = "Launch template for nomad clients"
  image_id    = local.client_ami

  instance_type          = "t3.large"
  update_default_version = true



  vpc_security_group_ids = [aws_security_group.client.id]

  instance_initiated_shutdown_behavior = "terminate"

  user_data = data.template_cloudinit_config.client.rendered

  block_device_mappings {
    device_name = "/dev/sda1"
    ebs {
      delete_on_termination = true
      volume_size           = 40
    }
  }

  tag_specifications {
    resource_type = "instance"
    tags = {
      consul = "client"
      Name   = "nomad client"
    }
  }
  tag_specifications {
    resource_type = "volume"
    tags = {
      Name = "nomad client storage"
    }

  }

  iam_instance_profile {
    arn = aws_iam_instance_profile.client.arn
  }

  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "optional"
  }
}

resource "aws_security_group" "server" {
  name        = "nomad-server"
  description = "Allow Hashicorp nomad traffic"
  vpc_id      = data.aws_vpc.selected.id


  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Consul LAN Serf TCP"
    from_port   = 8301
    to_port     = 8301
    protocol    = "tcp"
    cidr_blocks = [data.aws_vpc.selected.cidr_block]
  }

  ingress {
    description = "Consul LAN Serf UDP"
    from_port   = 8301
    to_port     = 8301
    protocol    = "udp"
    cidr_blocks = [data.aws_vpc.selected.cidr_block]
  }

  ingress {
    description = "Consul gRPC API"
    from_port   = 8502
    to_port     = 8502
    protocol    = "tcp"
    cidr_blocks = [data.aws_vpc.selected.cidr_block]
  }

  ingress {
    description = "Promtail stats"
    from_port   = 9080
    to_port     = 9080
    protocol    = "tcp"
    cidr_blocks = [data.aws_vpc.selected.cidr_block]
  }

  ingress {
    description = "Node exporter"
    from_port   = 9100
    to_port     = 9100
    protocol    = "tcp"
    cidr_blocks = [data.aws_vpc.selected.cidr_block]
  }

  ingress {
    description = "Nomad RPC"
    from_port   = 4647
    to_port     = 4647
    protocol    = "tcp"
    cidr_blocks = [data.aws_vpc.selected.cidr_block]
  }

  ingress {
    description = "Nomad HTTP API"
    from_port   = 4646
    to_port     = 4646
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Nomad Serf WAN TCP"
    from_port   = 4648
    to_port     = 4648
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Nomad Serf WAN UDP"
    from_port   = 4648
    to_port     = 4648
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "client" {
  name        = "nomad-client"
  description = "Allow Hashicorp nomad traffic"
  vpc_id      = data.aws_vpc.selected.id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Consul HTTP API"
    from_port   = 8500
    to_port     = 8500
    protocol    = "tcp"
    cidr_blocks = [data.aws_vpc.selected.cidr_block]
  }

  ingress {
    description = "Consul gRPC API"
    from_port   = 8502
    to_port     = 8502
    protocol    = "tcp"
    cidr_blocks = [data.aws_vpc.selected.cidr_block]
  }

  ingress {
    description = "Consul LAN Serf TCP"
    from_port   = 8301
    to_port     = 8301
    protocol    = "tcp"
    cidr_blocks = [data.aws_vpc.selected.cidr_block]
  }

  ingress {
    description = "Consul LAN Serf UDP"
    from_port   = 8301
    to_port     = 8301
    protocol    = "udp"
    cidr_blocks = [data.aws_vpc.selected.cidr_block]
  }

  ingress {
    description = "Envoy proxy metrics"
    from_port   = 9102
    to_port     = 9102
    protocol    = "tcp"
    cidr_blocks = [data.aws_vpc.selected.cidr_block]
  }

  ingress {
    description = "Node exporter"
    from_port   = 9100
    to_port     = 9100
    protocol    = "tcp"
    cidr_blocks = [data.aws_vpc.selected.cidr_block]
  }

  ingress {
    description = "Promtail stats"
    from_port   = 9080
    to_port     = 9080
    protocol    = "tcp"
    cidr_blocks = [data.aws_vpc.selected.cidr_block]
  }

  ingress {
    description = "Nomad RPC"
    from_port   = 4647
    to_port     = 4647
    protocol    = "tcp"
    cidr_blocks = [data.aws_vpc.selected.cidr_block]
  }

  ingress {
    description = "Nomad HTTP api"
    from_port   = 4646
    to_port     = 4646
    protocol    = "tcp"
    cidr_blocks = [data.aws_vpc.selected.cidr_block]
  }

  ingress {
    description = "Nomad dynamic ports"
    from_port   = 20000
    to_port     = 32000
    protocol    = "tcp"
    cidr_blocks = [data.aws_vpc.selected.cidr_block]
  }
  ingress {
    description = "Loki ingress"
    from_port   = 3100
    to_port     = 3100
    protocol    = "tcp"
    cidr_blocks = [data.aws_vpc.selected.cidr_block]
  }

  ingress {
    description = "http ingress and traefik health check"
    from_port   = 80
    to_port     = 81
    protocol    = "tcp"
    cidr_blocks = [data.aws_vpc.selected.cidr_block]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


resource "aws_security_group" "lb" {
  name        = "main-lb"
  description = "Allow traffic to main lb"
  vpc_id      = data.aws_vpc.selected.id

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
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