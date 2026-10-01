locals {
  domain = "vault.online.ntnu.no"
  compose = templatefile("${path.module}/templates/compose.yaml.tftpl", {
    domain                = local.domain
    organization_creators = join(",", sort(tolist(var.organization_creator_emails)))
    google_sso_enabled    = var.google_sso_enabled
  })
  cloud_config = {
    package_update      = true
    packages            = ["docker.io", "docker-compose-v2", "python3-argon2", "unattended-upgrades", "restic"]
    ssh_pwauth          = false
    disable_root        = true
    ssh_authorized_keys = var.deployment_ssh_public_key == "" ? [] : [var.deployment_ssh_public_key]
    write_files = [
      for name, file in {
        "compose.yaml" = { path = "/opt/vaultwarden/compose.yaml", permissions = "0644", content = local.compose }
        "Caddyfile"    = { path = "/opt/vaultwarden/Caddyfile", permissions = "0644", content = templatefile("${path.module}/templates/Caddyfile.tftpl", { domain = local.domain }) }
        "setup.sh"     = { path = "/usr/local/sbin/vaultwarden-setup", permissions = "0700", content = templatefile("${path.module}/templates/setup.sh.tftpl", { volume_serial = substr(openstack_blockstorage_volume_v3.data.id, 0, 20) }) }
        "admin.py"     = { path = "/opt/vaultwarden/admin.py", permissions = "0600", content = file("${path.module}/templates/admin.py") }
        "backup.sh"    = { path = "/usr/local/sbin/vaultwarden-backup", permissions = "0700", content = file("${path.module}/templates/backup.sh") }
        "service"      = { path = "/etc/systemd/system/vaultwarden.service", permissions = "0644", content = file("${path.module}/templates/vaultwarden.service") }
        "backup"       = { path = "/etc/systemd/system/vaultwarden-backup.service", permissions = "0644", content = "[Unit]\nDescription=Vaultwarden consistent local backup\nRequires=vaultwarden.service\nAfter=vaultwarden.service\n\n[Service]\nType=oneshot\nExecStart=/usr/local/sbin/vaultwarden-backup\n" }
        "timer"        = { path = "/etc/systemd/system/vaultwarden-backup.timer", permissions = "0644", content = "[Unit]\nDescription=Daily Vaultwarden backup\n\n[Timer]\nOnCalendar=*-*-* 03:00:00\nRandomizedDelaySec=300\nPersistent=true\n\n[Install]\nWantedBy=timers.target\n" }
      } : merge(file, { owner = "root:root" })
    ]
    runcmd = [["/usr/local/sbin/vaultwarden-setup"]]
  }
}

resource "openstack_networking_secgroup_v2" "vaultwarden" {
  name        = "vaultwarden"
  description = "Public HTTPS and HTTP for ACME; SSH only from administrator networks."
}

resource "openstack_networking_secgroup_rule_v2" "web" {
  for_each          = toset(["80", "443"])
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = tonumber(each.value)
  port_range_max    = tonumber(each.value)
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = openstack_networking_secgroup_v2.vaultwarden.id
}

resource "openstack_networking_secgroup_rule_v2" "ssh" {
  for_each          = var.ssh_allowed_cidrs
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 22
  port_range_max    = 22
  remote_ip_prefix  = each.value
  security_group_id = openstack_networking_secgroup_v2.vaultwarden.id
}

resource "openstack_networking_port_v2" "vaultwarden" {
  name               = "vaultwarden"
  network_id         = var.network_id
  security_group_ids = [openstack_networking_secgroup_v2.vaultwarden.id]
}

resource "openstack_networking_floatingip_v2" "vaultwarden" {
  pool      = var.floating_ip_pool
  subnet_id = var.floating_ip_subnet_id
}

resource "openstack_networking_floatingip_associate_v2" "vaultwarden" {
  floating_ip = openstack_networking_floatingip_v2.vaultwarden.address
  port_id     = openstack_networking_port_v2.vaultwarden.id
}

resource "openstack_blockstorage_volume_v3" "data" {
  name = "vaultwarden-data"
  size = var.data_volume_size

  lifecycle {
    prevent_destroy = true
  }
}

resource "terraform_data" "configuration" {
  triggers_replace = [
    openstack_compute_instance_v2.vaultwarden.id,
    sha256(local.compose),
    filesha256("${path.module}/scripts/deploy.py"),
    filesha256("${path.module}/scripts/runtime.py"),
  ]

  provisioner "local-exec" {
    command     = "python scripts/deploy.py"
    working_dir = path.module
    environment = {
      VAULTWARDEN_HOST           = openstack_networking_floatingip_v2.vaultwarden.address
      VAULTWARDEN_COMPOSE_BASE64 = base64encode(local.compose)
      VAULTWARDEN_SSO_ENABLED    = tostring(var.google_sso_enabled)
    }
  }
}

resource "openstack_compute_instance_v2" "vaultwarden" {
  name        = "vaultwarden"
  image_id    = var.image_id
  flavor_name = var.flavor_name
  key_pair    = var.key_pair_name
  user_data   = "#cloud-config\n${yamlencode(local.cloud_config)}"

  network {
    port = openstack_networking_port_v2.vaultwarden.id
  }

  # Nova requires an explicit root mapping when an additional disk is supplied.
  block_device {
    uuid                  = var.image_id
    source_type           = "image"
    destination_type      = "local"
    boot_index            = 0
    delete_on_termination = true
  }

  block_device {
    uuid                  = openstack_blockstorage_volume_v3.data.id
    source_type           = "volume"
    destination_type      = "volume"
    boot_index            = -1
    delete_on_termination = false
  }

  lifecycle {
    prevent_destroy = true
    # Runtime application configuration is updated over SSH below.
    ignore_changes = [user_data]
  }
}

data "aws_route53_zone" "online" {
  name         = "online.ntnu.no"
  private_zone = false
}

resource "aws_route53_record" "vaultwarden" {
  zone_id = data.aws_route53_zone.online.zone_id
  name    = local.domain
  type    = "A"
  ttl     = 300
  records = [openstack_networking_floatingip_v2.vaultwarden.address]
}
