# Options

Options allow the user to change some aspects of `ops` behaviour. For example, if the `options` section of an `ops.yml` file looked like:

```yaml
options:
  exec:
    load_secrets: true
  apt:
    use_sudo: false
```

then `ops` would not prefix `apt install` commands with `sudo`, and it would load secrets from an ejson file before running a command passed to `ops exec`.

## Setting options with environment variables

Options can also be set using environment variables. This is because, for some options, it's not convenient to hard-code them in `ops.yml` because they need to be set differently on different machines.

For the above YAML options, the equivalent environment variables would be:

```
OPS__APT__USE_SUDO=false
OPS__EXEC__LOAD_SECRETS=true
```

All option variable names are prefixed with `OPS` and each level of nesting in the YAML option translates to two underscores.

Any time you find documentation about an option you can set in `ops.yml`, you can set that option via an environment variable. Even the `environment` options, although that would be silly.