

## Getting Started
Provide the Hetzner API Token through an env variable on the shell
```
export HCLOUD_TOKEN='<the token>'
```
or though the mise.local.toml file
```toml
[env]
HCLOUD_TOKEN = "<the token>"
```

install dependencies
```sh
# download mise based tooling (here just terraform)
mise install

# setup repository
#  1. install ansible tooling (including python deps ...)
#  2. run terraform init
mise run init
```

## Deployment
### Terraform Deployment
Firstly use terraform to create the infrastructure defined in `terraform/main.tf`.
It creates:
- a server (labeled with the key environment)
- an ip address
- firewall rules
- the user admin (for manuall access)
- the recovery-user (for password login though the hetzner cloud console dumped to `terraform/modules/instance/secrets`)
- the ansible user (for automation)

```sh
mise run terraform plan
mise run terraform apply
```
