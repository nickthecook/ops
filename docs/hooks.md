## Hooks

Sometimes you want to run a command before other commands. Some examples:

- you have a number of ops commands that let a developer run different test suites inside a container, and you want to make sure the container image is built beforehand
- you have some configuration that needs to happen when the software execution environment changes (e.g. going from dev to staging)

In this case, you can use the "hooks feature.

### Before hooks

"Before hooks" run before actions. They do not run before builtins like `up` or `exec`.

```yaml
hooks:
  before:
    - bin/build-container.sh
actions:
  test:
    command: docker run --rm test_container
```

You may have some actions that don't need to run before hooks. For example, an action that removes container images to allow a developer to force a clean build from the latest source, or free up disk space.

In this case, you can configure that action to skip the hooks:

```yaml
hooks:
  before:
    - bin/build-container.sh
actions:
  test:
    command: docker run --rm test_image
  remove-image:
    command: docker rm test_image
    skip_before_hooks: true
```

### Hooks in ops actions called from ops actions

You may have ops actions that call ops actions. For example, an action that calls `terraform apply` and another one that calls that one, adding the `--auto-approve` parameter:

```yaml
hooks:
  before:
    - ln -sf backend/$environment/backend.tf .
    - ops terraform-init
actions:
  apply:
    command: terraform apply
    load_secrets: true
  apply-auto-approve:
    command: ops apply --auto-approve
    alias: aa
  terraform-init:
    command: terraform init --backend-config=...
    load_secrets: true
```

These two hooks ensure that `terraform` can always find the appropriate backend for the current software execution environment (e.g. `dev` vs `staging`) environment. However, you don't want the hooks to be run twice, and it takes a couple of seconds. For this reason, `ops` will run the hooks before executing `ops apply --auto-approve`, but it will not run the hooks again before running `terraform apply`, or before running `terraform init ...`.

### Secrets in hooks

"Before hooks" are always executed before secrets are loaded. If you would like a before hook to have access to secrets, create an action with `load_secrets: true` and call the action from a before hook.
