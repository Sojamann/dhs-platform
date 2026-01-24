
## Getting Started
```
export HCLOUD_TOKEN='<the token>'

mise r install
uv venv
source .venv/bin/activate
uv pip install -r requirements.txt

ansible-galaxy collection install -r ansible/collections/requirements.yam

mise run terraform init --upgrade
```
