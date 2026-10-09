output "url" {
  description = "Vaultwarden URL; wait for cloud-init and DNS propagation after apply."
  value       = "https://${local.domain}"
}

output "floating_ip" {
  description = "Public IPv4 address for SSH and DNS."
  value       = openstack_networking_floatingip_v2.vaultwarden.address
}

output "admin_tunnel" {
  description = "SSH tunnel for the private admin panel at http://localhost:8080/admin."
  value       = "ssh -L 8080:127.0.0.1:8080 ubuntu@${openstack_networking_floatingip_v2.vaultwarden.address}"
}
