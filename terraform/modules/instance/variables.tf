variable "hcloud_token" {
  sensitive = true
  description = "the Hetzner API token"
}
variable "root_ssh_key_id" {
  description = "the id of the hetzner ssh key object used as root ssh key"
}
variable "admin_ssh_key" {
  type = string
  description = "the public key to login to the admin user"
}
variable "ansible_ssh_key" {
  type = string
  description = "the public key to login to the ansible user"
}
variable "name" {
  type = string
  description = "name of the instance to deploy e.g. prod"
}
