provider "hcloud" {
  token = var.hcloud_token
}
provider "local" {}
provider "random" {}
provider "cloudinit" {}

