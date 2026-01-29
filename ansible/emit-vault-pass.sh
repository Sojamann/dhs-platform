#!/usr/bin/env bash

# NOTE: this 'trick' allows us to store the vault password
#       in an environment variable like the hetzner token
#       and let ansible read it using this fake password file

echo "$ANSIBLE_VAULT_PASSWORD"
