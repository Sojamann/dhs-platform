

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
# download the terraform tooling
mise install

# install ansible tooling (including python deps ...)
mise run init
```
