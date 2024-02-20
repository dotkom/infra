locals {
  ami = "ami-06ee3ee852a3c990e"

  subnet            = "subnet-6eca3807"
  consul_datacenter = "aws-eu-north-1"
  instance_type     = "t3.small"
  db_address        = "main-db.cxliesrki50e.eu-north-1.rds.amazonaws.com"
}

data "aws_route53_zone" "online" {
  name = "online.ntnu.no"
}

data "aws_subnet" "selected" {
  id = local.subnet
}

data "aws_vpc" "selected" {
  id = data.aws_subnet.selected.vpc_id
}

data "aws_region" "current" {}


resource "aws_kms_key" "auto_unseal" {
  description             = "Vault auto unseal key"
  deletion_window_in_days = 10
  tags = {
    Name = "Hashicorp Vault auto unseal key"
  }

  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_route53_record" "vault" {
  zone_id = data.aws_route53_zone.online.zone_id
  name    = "vault.online.ntnu.no"
  type    = "A"
  ttl     = "60"
  records = toset([aws_eip.server.public_ip])
}

resource "postgresql_database" "vault" {
  name              = "vault"
  allow_connections = true
}

resource "random_password" "db_password" {
  length  = 32
  special = false
}

resource "postgresql_role" "vault" {
  name     = "vault"
  login    = true
  password = random_password.db_password.result
}

resource "postgresql_grant" "permissions" {
  database    = postgresql_database.vault.name
  role        = postgresql_role.vault.name
  schema      = "public"
  object_type = "table"
  privileges  = ["ALL"]
}

resource "consul_acl_token" "agent" {
  description = "Vault server"
  policies    = ["vault-server"]
}

resource "aws_eip" "server" {
  vpc      = true
  instance = aws_instance.vault_server.id
}

resource "aws_instance" "vault_server" {
  ami           = local.ami
  instance_type = local.instance_type

  iam_instance_profile = aws_iam_instance_profile.vault.id

  subnet_id              = local.subnet
  vpc_security_group_ids = [aws_security_group.vault.id]

  user_data_base64 = data.template_cloudinit_config.user_data.rendered

  tags = {
    consul = "client"
    Name   = "vault server"
  }
}

data "template_cloudinit_config" "user_data" {
  gzip          = true
  base64_encode = true

  part {
    content_type = "text/cloud-config"
    content = templatefile("./files/cloud-config.tpl", {
      consul_vars = base64encode(yamlencode({
        datacenter         = local.consul_datacenter
        primary_datacenter = local.consul_datacenter
        retry_join         = ["provider=aws tag_key=consul tag_value=server"]
        acl_token          = data.consul_acl_token_secret_id.agent.secret_id
      }))
      vault_vars = base64encode(yamlencode({
        aws_region  = data.aws_region.current.name
        kms_key_id  = aws_kms_key.auto_unseal.arn
        db_password = random_password.db_password.result
        db_address  = local.db_address
      }))
      }
    )
  }
}

data "consul_acl_token_secret_id" "agent" {
  accessor_id = consul_acl_token.agent.id
}

resource "aws_iam_role" "vault" {
  name               = "vault-server"
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

resource "aws_iam_instance_profile" "vault" {
  name = "vault-server"
  role = aws_iam_role.vault.name
}


resource "aws_iam_role_policy_attachment" "attachment" {
  role       = aws_iam_role.vault.name
  policy_arn = aws_iam_policy.vault.arn
}


resource "aws_iam_policy" "vault" {
  name        = "vault-server"
  description = "vault server policy"
  policy      = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "kms:Encrypt",
        "kms:Decrypt",
        "kms:DescribeKey"
      ],
      "Effect": "Allow",
      "Resource": "${aws_kms_key.auto_unseal.arn}"
    },
    {
      "Action": [
        "ec2:DescribeInstances"
      ],
      "Effect": "Allow",
      "Resource": "*"
    },
    {
      "Action": [
        "secretsmanager:GetSecretValue"
      ],
      "Effect": "Allow",
      "Resource": "arn:aws:secretsmanager:eu-north-1:891459268445:secret:letsencrypt/online.ntnu.no*"
    },
        {
      "Effect": "Allow",
      "Action": [
        "iam:*",
        "sts:*"
      ],
      "Resource": ["*"]
    },
            {
            "Effect": "Allow",
            "Action": [
                "route53:ListHostedZones",
                "route53:GetChange"
            ],
            "Resource": [
                "*"
            ]
        },
        {
            "Effect" : "Allow",
            "Action" : [
                "route53:ChangeResourceRecordSets"
            ],
            "Resource" : [
                "*"
            ]
        }
  ]
}
EOF
}

resource "aws_security_group" "vault" {
  name        = "vault-server"
  description = "Allow Hashicorp Vault traffic"
  vpc_id      = data.aws_vpc.selected.id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Vault API"
    from_port   = 8200
    to_port     = 8200
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Server to server traffic"
    from_port   = 8201
    to_port     = 8201
    protocol    = "tcp"
    cidr_blocks = [data.aws_vpc.selected.cidr_block]
  }

  ingress {
    description = "Consul LAN serf TCP"
    from_port   = 8301
    to_port     = 8301
    protocol    = "tcp"
    cidr_blocks = [data.aws_vpc.selected.cidr_block]
  }

  ingress {
    description = "Consul LAN serf UDP"
    from_port   = 8301
    to_port     = 8301
    protocol    = "udp"
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
