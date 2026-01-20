variable "hcloud_token" {
  sensitive = true
  description = "the Hetzner API token"
}
variable "root_ssh_key" {
  description = "the public key of the root user"
}
variable "admin_ssh_key" {
  type = string
  description = "the public key to login to the admin user"
}
variable "ansible_ssh_key" {
  type = string
  description = "the public key to login to the ansible user"
}
