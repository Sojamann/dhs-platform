# DHS - Platform

## Getting Started
The project needs three secrets to work:
1. a hetzner api token (to deploy the infrastructure)
2. the ansible vault password (to decode secrets)
3. github credentials (to pull the images from the registry)

only two of which must be provided as environment variables. Export
the variables:
```sh
export HCLOUD_TOKEN='<the token>'
export ANSIBLE_VAULT_PASSWORD='<the password>'
```
or put them into the mise.local.toml file:
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
- a server (labeled with the key *environment*)
- an ip address
- firewall rules
- the user admin (for manual access)
- the recovery-user (for password login though the hetzner cloud console dumped to `terraform/modules/instance/secrets`)
- the ansible user (for automation)

per environment when running:

```sh
mise run terraform plan
mise run terraform apply
```

> the terraform state will be stored only locally!

### DNS Configuration
DNS configuration must be done manually and is expected to be setup like so:

| Type  |   Name   | Content |
|-------|----------|---------|
|   A   |  domain  |   IP    |
| CNAME | *.domain | domain  |

which allows the reverse proxy to also take care of subdomains.

### Ansible Configuration
Ansible is used to configure the server through playbooks defined in `ansible/playbooks` and
is executed as follows:

```sh
ansible-playbook \
    --inventory ansible/inventory/<environment>/ \
    ./ansible/playbooks/<playbook>.yaml
```
> **IMPORTANT**: add the trailing slash to the inventory directory


Some configurations are stored in ansible's vault:
```sh
ansible-vault view ansible/inventory/<environment>/group_vars/all/secrets.yaml

# the domain the application is being rolled out for
vault_domain: ""
# the credentials with which docker images can be pulled from github
vault_docker_registry_user: ""
vault_docker_registry_password: ""
```

the host variables in the inventory path also hold some configuration
options of which only the application version should be changed:
```sh
head -n 2 ansible/inventory/<environment>/group_vars/all/all.yaml

# do change those
version: latest         # software version to use (latest or tag of backend and frontend)
```

#### Initialization
The `1-init` playbook must only be run once on a server and:

- installs apt packages (including docker for exucution)
- generates secrets needed for the application stored under `/opt/app/secrets`
- setup backups stored in the directory `/var/lib/dhs-backup`

#### Starting The Application
The `2-start` playbook is used to *install* the application by:
- copying the docker compose file
- copying the gatus config for monitoring
- starting the applications using docker compose
- activating the cron job doing db backups

updates can also be performed using the `2-start` playbook but it is recommended
to make a db backup first (`5-backup`).

#### Making (manual) Backups
The `5-backup` playbook is used perform a manual backup of the
database to the backup directory `/var/lib/dhs-backup`.

#### Updating SSH Public Keys
The `5-distribute-ssh-keys` playbook is used to update trusted
ssh keys of the users *ansible* and *admin*.

#### Updating Packages
The `5-update-server` playbook is used to update system packages
which should regulary be performed.

#### Updating Docker Credentials
The `5-update-docker-secret` playbook is used to update the username and
password with which the application docker images are pulled with.

#### Stopping The Application
The `9-stop` playbook is used stop execution of the docker containers
together with the the cron job responsible for making backups.
