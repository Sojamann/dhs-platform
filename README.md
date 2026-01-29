

## Getting Started
The project needs two secrets to work:
1. a hetzner api token
2. the ansible vault password

which can be provided using a shell variable
```
export HCLOUD_TOKEN='<the token>'
export ANSIBLE_VAULT_PASSWORD='<the password>'
```
or though the mise.local.toml file
```toml
[env]
HCLOUD_TOKEN = "<the token>"
ANSIBLE_VAULT_PASSWORD = "<the password>"
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

### Initialize Server
Ansible is used to initialize the server which incluides:
- create the dhs user
- install docker

```sh
ansible-playbook \
    --inventory ansible/inventories/prod/ \
    ./ansible/playbooks/1.init.yaml
```

TODO: explain other files
