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

resource "random_password" "recovery_user" {
  length           = 16
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

resource "local_sensitive_file" "backup_password" {
  content  = "recovery-user:${random_password.recovery_user.result}"
  filename = "${path.module}/secrets/${var.name}-password.txt"
}

data "cloudinit_config" "config" {
  gzip          = false
  base64_encode = false

  part {
    filename     = "cloud-config.yaml"
    content_type = "text/cloud-config"

    content = templatefile("${path.module}/cloud-init.tftpl.yaml", {
      admin_ssh_key = var.admin_ssh_key
      ansible_ssh_key  = var.ansible_ssh_key
      recovery_user_password_hash = random_password.recovery_user.bcrypt_hash
    })
  }
}

resource "hcloud_primary_ip" "ip" {
  name          = var.name
  location      = "nbg1"
  type          = "ipv4"
  assignee_type = "server"
  auto_delete   = false

  labels = {
    environment : var.name
  }
}

resource "hcloud_firewall" "server" {
  name = var.name

  labels = {
    environment : var.name
  }

  rule {
    description = "allow ICMP (ping)"
    direction = "in"
    protocol  = "icmp"
    source_ips = [
      "0.0.0.0/0",
      "::/0"
    ]
  }

  rule {
    description = "allow SSH access"
    direction = "in"
    protocol  = "tcp"
    port      = "22"
    source_ips = [
      "0.0.0.0/0",
      "::/0"
    ]
  }

  rule {
    description = "allow standard UDP traffic on port 80"
    direction = "in"
    protocol  = "udp"
    port      = "80"
    source_ips = [
      "0.0.0.0/0",
      "::/0"
    ]
  }

  rule {
    description = "allow standard TCP traffic on port 80"
    direction = "in"
    protocol  = "tcp"
    port      = "80"
    source_ips = [
      "0.0.0.0/0",
      "::/0"
    ]
  }

  rule {
    description = "allow standard UDP traffic on port 443"
    direction = "in"
    protocol  = "udp"
    port      = "443"
    source_ips = [
      "0.0.0.0/0",
      "::/0"
    ]
  }

  rule {
    description = "allow standard TCP traffic on port 443"
    direction = "in"
    protocol  = "tcp"
    port      = "443"
    source_ips = [
      "0.0.0.0/0",
      "::/0"
    ]
  }
}

resource "hcloud_server" "server" {
  name        = var.name
  image       = "ubuntu-24.04"
  server_type = "cx23"
  location    = hcloud_primary_ip.ip.location

  user_data = data.cloudinit_config.config.rendered
  shutdown_before_deletion = true
  ssh_keys = [var.root_ssh_key_id] # not used but we don't want a email from hetzner
  firewall_ids = [hcloud_firewall.server.id]

  public_net {
    ipv4_enabled = true
    ipv4 = hcloud_primary_ip.ip.id
    ipv6_enabled = false
  }

  labels = {
    environment : var.name
  }

  # no automatic destruction of the server given changes:
  lifecycle {
    ignore_changes = [ssh_keys, user_data]
  }
}
