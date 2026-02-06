terraform {
  cloud {
    organization = "dhs-ffsued"
    workspaces {
      name = "dhs"
    }
  }
  required_providers {
    hcloud = {
      source  = "hetznercloud/hcloud"
      version = "~> 1.45"
    }
  }
}

provider "hcloud" {
  token = var.hcloud_token
}

# create one ssh key so that hetzer won't generate
# a password for the root user. This is done here
# since we cannot place this in the module given the same
# ssh key is used more than once as it must be unique.
# NOTE: the key cannot be used since ssh login for
#       the root user is disabled.
resource "hcloud_ssh_key" "root" {
  name       = "root"
  public_key = var.root_ssh_key
}

module "prod" {
  source = "./modules/instance"

  # make this the PROD instance
  name = "prod"

  hcloud_token = var.hcloud_token
  root_ssh_key_id = hcloud_ssh_key.root.id
  admin_ssh_key = var.admin_ssh_key
  ansible_ssh_key = var.ansible_ssh_key
}
output "prod_ip" {
  description = "The public IP address of the prod instance"
  value       = module.prod.public_ip
}

# EXAMPLE:
# module "staging" {
#   source = "./modules/instance"
#
#   name = "staging"
#
#   hcloud_token = var.hcloud_token
#   root_ssh_key_id = hcloud_ssh_key.root.id
#   admin_ssh_key = var.admin_ssh_key
#   ansible_ssh_key = var.ansible_ssh_key
# }
