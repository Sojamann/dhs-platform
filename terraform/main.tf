terraform {
  required_providers {
    hcloud = {
      source  = "hetznercloud/hcloud"
      version = "~> 1.45"
    }
    random = {
      source = "hashicorp/random"
      version = "~>3.8"
    }
    local = {
      source = "hashicorp/local"
      version = "~>2.6"
    }
    cloudinit = {
      source = "hashicorp/cloudinit"
      version = "~>2.3"
    }
  }
}

resource "random_password" "console_admin_pw" {
  length           = 16
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

resource "local_sensitive_file" "backup_password" {
  content  = "console-admin:${random_password.console_admin_pw.result}"
  filename = "${path.module}/secrets/console_password.txt"
}

data "cloudinit_config" "config" {
  gzip          = false
  base64_encode = false

  part {
    filename     = "cloud-config.yaml"
    content_type = "text/cloud-config"

    content = templatefile("${path.module}/cloud-init.tftpl.yaml", {
      admin_ssh_key = var.admin_ssh_key
      dhs_ssh_key  = var.dhs_ssh_key
      console_admin_password_hash = random_password.console_admin_pw.bcrypt_hash
    })
  }
}

resource "hcloud_primary_ip" "ip" {
  name          = "server_ip"
  location      = "nbg1"
  type          = "ipv4"
  assignee_type = "server"
  auto_delete   = false
}

resource "hcloud_ssh_key" "root" {
  name       = "root"
  public_key = var.root_ssh_key
}

resource "hcloud_server" "server" {
  name        = "server"
  image       = "ubuntu-24.04"
  server_type = "cx23"
  location    = hcloud_primary_ip.ip.location

  user_data = data.cloudinit_config.config.rendered
  shutdown_before_deletion = true
  ssh_keys = [hcloud_ssh_key.root.id] # not used but we don't want a email from hetzner

  public_net {
    ipv4_enabled = true
    ipv4 = hcloud_primary_ip.ip.id
    ipv6_enabled = false
  }

  # no automatic destruction of the server given changes:
  lifecycle {
    ignore_changes = [ssh_keys, user_data]
  }
}
