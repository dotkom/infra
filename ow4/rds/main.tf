data "aws_vpc" "default" {
  default = true
}

data "vault_generic_secret" "master_credentials" {
  path = "secret/rds-postgres"
}

data "aws_security_group" "nomad_nodes" {
  name = "nomad-client"
}

data "aws_security_group" "vault_server" {
  name = "vault-server"
}

resource "aws_db_instance" "default" {
  identifier                            = "main-db"
  allocated_storage                     = 100
  iam_database_authentication_enabled   = true
  availability_zone                     = "eu-north-1a"
  backup_retention_period               = 30
  engine                                = "postgres"
  engine_version                        = "13.3"
  instance_class                        = "db.t3.small"
  name                                  = "postgres"
  username                              = data.vault_generic_secret.master_credentials.data["username"]
  password                              = data.vault_generic_secret.master_credentials.data["password"]
  vpc_security_group_ids                = [aws_security_group.sg.id]
  performance_insights_enabled          = true
  performance_insights_retention_period = 7
  port                                  = 5432
  final_snapshot_identifier             = "main-db-final-snapshot"
  publicly_accessible                   = true
  deletion_protection                   = true
  apply_immediately                     = true
}

resource "aws_security_group" "sg" {
  name        = "main-db"
  description = "Allow connections from within VPC"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    description     = "Nomad nodes"
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [data.aws_security_group.nomad_nodes.id]
  }

  ingress {
    description     = "Vault server"
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [data.aws_security_group.vault_server.id]
  }

  ingress {
    description = "Nansen"
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["129.241.106.131/32"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
