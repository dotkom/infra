
resource "aws_efs_file_system" "storage" {
  creation_token = "nomad_volume_${var.volume_id}"
  tags = {
    Name = "nomad_volume_${var.volume_id}"
  }
}

resource "aws_efs_mount_target" "storage" {
  for_each = data.aws_subnet_ids.subnets.ids

  file_system_id  = aws_efs_file_system.storage.id
  subnet_id       = each.value
  security_groups = [aws_security_group.storage.id]
}

resource "nomad_volume" "storage" {
  depends_on  = [data.nomad_plugin.efs]
  type        = "csi"
  plugin_id   = "aws-efs"
  volume_id   = var.volume_id
  name        = "${var.volume_id} volume"
  external_id = aws_efs_file_system.storage.id

  capability {
    access_mode     = "multi-node-multi-writer"
    attachment_mode = "file-system"
  }
}

resource "aws_security_group" "storage" {
  name        = "nomad_volume_${var.volume_id}"
  description = "Allow NFS connections to storage"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    description = "NFS"
    from_port   = 2049
    to_port     = 2049
    protocol    = "tcp"
    cidr_blocks = [data.aws_vpc.default.cidr_block]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}