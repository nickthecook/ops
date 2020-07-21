# Using ops with terraform

Terraform is an Infrastructure-as-Code (IaC) tool that can be used to automate the deployment and maintenance of complex systems in the cloud.

Terraform is a command-line tool, written in Go. One puts the terraform binary for their platform somewhere in their `$PATH`, changes to a directory containing `.tf` files, and runs `terraform plan` or `terraform apply`.

Terraform is strong in:

- cloud provider compatibilty: AWS, GCP, Azure, etc. are all usable through terraform
- idepmotence: terraform will scan your existing infrastructure and only change the things that differ from what you've declared in your `.tf` files
- secure shared backends: terraform can store its state in S3 or other cloud-based storage systems, making it possible to use terraform to maintain your production infrastructure without copying state files around

Terraform does not provide:

- environment-awareness: terraform has no built-in mechanism for defining different variables for different environments
- secrets management: terraform has no built-in mechanism for storing variables securely and decrypting them on-the-fly

`ops` provides these things.

## Sample

Here is a sample `ops.yml` file from a terraform project, with comments added:

```yaml
dependencies:
  custom:
    # these custom dependencies allow the use of multiple backends, one for each environment
    #   - backend/dev/backend.tf is an empty file, since we keep local state for that env
    #   - backend/$environment/backend.tf for other envs just defines the backend config
    # by linking the appropriate backend before running `terraform init`, we make sure terraform
    #   initializes the proper backend for our environment during `ops up`
    - ln -sf backend/$environment/backend.tf backend.tf
    - ops terraform-init
hooks:
  before:
    # this hoook will run before any action, so once the backend is initilized you automatically get the
    #   correct backend for your current $environment
    - ln -sf backend/$environment/backend.tf backend.tf
actions:
  terraform-init:
    # this allows a local state file for dev env, and a remote state for all other envs
    command: |
      if [ "$environment" == "dev" ]; then
        terraform13 init
      else
        terraform13 init -backend=true $backend_config_params
      fi
    load_secrets: true
  apply:
    # creating ops actions for terraform commands lets us define $TF_VAR_* variables in config and secrets and
    #   have them automatically defined when terraform is run
    command: terraform13 apply
    alias: a
    description: runs 'terraform apply'
    load_secrets: true
  apply-auto-approve:
    # this is for convenience: don't require user to enter 'yes' when running `terraform apply`
    command: ops apply --auto-approve
    alias: aa
    description: runs 'terraform apply' with auto-approve
    # not safe in production, so we disallow it here
    not_in_envs:
      - production
  destroy:
    command: terraform13 destroy
    alias: d
    description: runs 'terraform destroy'
    # if load_secrets is not specified, ops will not set environment variables defined in `config/$environment/secrets.ejson`
    #   to help avoid accidental leakage of secrets
    load_secrets: true
  destroy-auto-approve:
    command: ops destroy --auto-approve
    alias: dd
    description: runs 'terraform destroy' with auto-approve
    not_in_envs:
      - production
  plan:
    command: terraform13 plan
    alias: p
    description: runs 'terraform plan'
    load_secrets: true
  graph:
    command: terraform13 graph | dot -T pdf -o resource_graph.pdf
    alias: g
    description: runs 'terraform graph'
  open-graph:
    command: ops graph && open resource_graph.pdf
    alias: og
    description: opens the terraform graph with the OS 'open' command
  output:
    command: terraform13 output
    alias: o
options:
  environment:
    # ops sets environment variables defined in this section before every run; this variable
    #   make terraform store data for each environment separately.
    # with this and the `ln` commands above, we can now run terraform commands in multiple envs
    #   at the same time, safely; e.g. `terraform plan` in staging while waiting for `dev` to
    #   deploy
    TF_DATA_DIR: config/$environment/.terraform
  exec:
    load_secrets: true
```

With this `ops.yml` in the directory that holds your terraform code:

```shell
$ ops up  # initializes terraform and the backend
$ ops aa  # deploys infrastructure, no prompt
$ ops dd  # destroys infrastructure, no prompt, not allowed in production
$ ops p   # runs `terraform` plan
```

## Config

Your `config/$environment/config.json` may look something like this:

```json
{
  "environment": {
    "TF_VAR_environment": "dev",
    "TF_VAR_namespace": "nick",
    "TF_VAR_registry_resource_group_name": "registry-dev",
    "TF_VAR_registry_name": "myregistry",
    "TF_VAR_influx_db_host": "influxdb-dev-nick.example.com",
    "TF_VAR_influx_db_verify_cert": false
  }
}
```

# Secrets

Your `config/$environment/secrets.ejson` may look like this:

```json
{
  "_public_key": "cf94ac086f59ea4f6cc58f5728574e8030c639e78a9a7cd682902ab4a2615143",
  "environment": {
    "ARM_CLIENT_ID": "EJ[1:dzn8n2jyVhEwV1+yLRbXrtuzT5LZURb14jZVH1TOBAA=:YLD9wP0TJwzQWJNz39Jwb7JJDkdO9ooa]",
    "ARM_CLIENT_SECRET": "EJ[1:dzn8n2jyVhEwV1+yLRbXrtuzT5LZURb14jZVH1TOBAA=:D6peWZsM3CAg1rpJGpm0X10xzhO1M63O]",
    "ARM_SUBSCRIPTION_ID": "EJ[1:dzn8n2jyVhEwV1+yLRbXrtuzT5LZURb14jZVH1TOBAA=:iIjQ1ki+9sQXuRarZVxV6Qe4M3nmZljH]",
    "ARM_TENANT_ID": "EJ[1:dzn8n2jyVhEwV1+yLRbXrtuzT5LZURb14jZVH1TOBAA=:dKvS7LKWcHoCXXoYQRC7dUr22Hba9P82]",
    "TF_VAR_app_ejson_public_key": "EJ[1:dzn8n2jyVhEwV1+yLRbXrtuzT5LZURb14jZVH1TOBAA=:3iocTA7PaRowjlWQ+CO3ABB1RVQsptHG]",
    "TF_VAR_app_ejson_private_key": "EJ[1:dzn8n2jyVhEwV1+yLRbXrtuzT5LZURb14jZVH1TOBAA=:PnzL0AE0RLRAl/JyUGnRVOi0JbulndGA]",
    "TF_VAR_registry_pull_username": "EJ[1:5U82qQa7EM0qplSwznpSiTg5y2WL2hPt4EuMJSlk0FY=:1dNCcBmaQnta9Ve0oHjzthXx9J2QU0xE]",
    "TF_VAR_registry_pull_password": "EJ[1:5U82qQa7EM0qplSwznpSiTg5y2WL2hPt4EuMJSlk0FY=:sPS3BeWHxQzRpoJQMiyp5kUXyJib423g]",
    "TF_VAR_influx_db_username": "EJ[1:a3fisK/nTlzwyhCL18vWKTH6ncr/tJkGGt2kbK260yA=:QN8OAZlUobW6NcoRKG0GuGOjdvjdowel]",
    "TF_VAR_influx_db_password": "EJ[1:/QZ5Qhiy+dC4Y1I3Wo2vNin4d4EcSf43gyDO23MPdm4=:vRI7hOY7AoDOn//tQFFxMO5ngoPN83wj]",
  }
}
```

The `$ARM_*` varables are what the Azure Resource Manager provider looks for to authenticate with Azure. With these variables defined and encrypted in the secrets file and the `ejson` private key on disk (outside your repo), `ops` will set these environment variables every time you run an action with `load_secrets: true` set. You will automatically use the correct credentials for your current environment.

Environment-specific config and secrets mean it's easy to define separate variables for different environments. You could also keep different `tfvars` files for each environment, and pass `-var config/$environment/terraform.tfvars` in the `ops` commands that run terraform.
