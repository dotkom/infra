
locals {
  ami = "ami-09b0e0f29b10e1e9b"

  subnet            = "subnet-6eca3807"
  consul_datacenter = "aws-eu-north-1"
  instance_type     = "t3.small"
  db_address        = "main-db.cxliesrki50e.eu-north-1.rds.amazonaws.com"
}

resource "aws_iam_instance_profile" "consul" {
  name = "consul-server"
  role = aws_iam_role.consul.name
}

resource "aws_iam_role" "consul" {
  name               = "consul-server"
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

resource "aws_iam_policy" "consul" {
  name        = "consul-server"
  description = "consul server policy to enable cloud auto join"
  policy      = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": ["ec2:DescribeInstances"],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "attachment" {
  role       = aws_iam_role.consul.name
  policy_arn = aws_iam_policy.consul.arn
}

data "template_cloudinit_config" "user_data" {
  gzip          = true
  base64_encode = true

  part {
    content_type = "text/cloud-config"
    content = templatefile("./files/cloud-config.tpl", {
      consul_vars = base64encode(yamlencode({
        bootstrap_expect   = 1
        datacenter         = local.consul_datacenter
        primary_datacenter = local.consul_datacenter
        retry_join         = ["provider=aws tag_key=consul tag_value=server"]
        retry_join_wan     = []
        acl_token          = data.vault_generic_secret.consul_server_token.data.token
      })) }
    )
  }

  part {
    content_type = "text/x-shellscript"
    content      = file("./files/mount-ebs-volume.sh")
  }
}

resource "aws_eip" "server" {
  vpc      = true
  instance = aws_instance.consul_servers.id
}

resource "aws_instance" "consul_servers" {
  ami           = local.ami
  instance_type = local.instance_type

  iam_instance_profile = aws_iam_instance_profile.consul.id

  subnet_id              = local.subnet
  vpc_security_group_ids = [aws_security_group.consul.id]

  credit_specification {
    cpu_credits = "standard"
  }

  tags = {
    consul = "server"
    Name   = "Consul server"
  }

  user_data_base64 = data.template_cloudinit_config.user_data.rendered
}

resource "aws_ebs_volume" "data" {
  availability_zone = data.aws_subnet.selected.availability_zone
  size              = 10

  tags = {
    Name = "Consul data"
  }
}

resource "aws_volume_attachment" "ebs_att" {
  device_name = "/dev/sdh"
  volume_id   = aws_ebs_volume.data.id
  instance_id = aws_instance.consul_servers.id
}

resource "aws_route53_record" "consul" {
  zone_id = data.aws_route53_zone.online.zone_id
  name    = "consul.online.ntnu.no"
  type    = "A"
  ttl     = "60"
  records = toset([aws_eip.server.public_ip])
}

resource "aws_security_group" "consul" {
  name        = "consul-server"
  description = "Allow Hashicorp consul traffic"
  vpc_id      = data.aws_vpc.selected.id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Consul CNS"
    from_port   = 8600
    to_port     = 8600
    protocol    = "tcp"
    cidr_blocks = [data.aws_vpc.selected.cidr_block]
  }

  ingress {
    description = "Consul HTTP API"
    from_port   = 8500
    to_port     = 8500
    protocol    = "tcp"
    cidr_blocks = [data.aws_vpc.selected.cidr_block]
  }

  ingress {
    description = "Consul HTTPS API"
    from_port   = 8501
    to_port     = 8501
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
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
    description = "Consul WAN Serf TCP"
    from_port   = 8302
    to_port     = 8302
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Consul WAN Serf UDP"
    from_port   = 8302
    to_port     = 8302
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Consul server rpc"
    from_port   = 8300
    to_port     = 8300
    protocol    = "tcp"
    cidr_blocks = [data.aws_vpc.selected.cidr_block]
  }

  ingress {
    description = "Node metrics"
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

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
