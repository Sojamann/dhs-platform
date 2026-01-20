output "public_ip" {
  description = "The public IP address of the server"
  value       = hcloud_primary_ip.ip.ip_address
}

