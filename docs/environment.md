# Environment Variables

## Software execution environment

`ops` will set the environment variable `$environment` to `dev` if it's not already set. This variable will be available to all actions run by `ops`. To specify a different software execution environment, set the `$environment` environment variable:

```
$ export environment=production
$ ops env
production
$ ops some_action  # this action will see `$environment` set to `production`
```

Different software systems use different environment variables to determine the software execution environment. E.g. Ruby on Rails uses `RAILS_ENV`. Thus, `ops` allows the user to specify which variables should also be set to the name of the software environment.

```yaml
options:
  environment_aliases:
    - RAILS_ENV
    - RACK_ENV
```

In the above example, if the `$environment` environment variable is not set, `ops` will set `RAILS_ENV` and `RACK_ENV` to `dev`. If `$environment` is set, `ops` will set `$RAILS_ENV` and `RACK_ENV` to the same value as `$environment`.

If any `environment_aliases` are specified in `ops.yml`, `ops` will not change the value of `$environment` unless it is listed as well.

*(`ops` will always use `$environment` to detect the software execution environment; `environment_aliases` just makes `ops` set other variables to match it.)*

## Environment variables in `ops.yml`

`ops` will set any environment variables you define in the `options` section of `ops.yml` before running any built-in or action.

E.g.:

```json
options:
  environment:
    EJSON_KEYDIR: "./spec/ejson_keys"
```

The values of these variables are not interpreted by the shell before being set, so variable references like `$environment` will appear literally in the value of the variable.

## Built-in environment variables

`ops` will set the following variables when executing any action or builtin:

- `OPS_YML_DIR`: the directory which contains the `ops.yml` file `ops` has loaded
- `OPS_VERSION`: the version of `ops` that is running
- `OPS_SECRETS_FILE`: the secrets file that ops will use, if it loads secrets
- `OPS_CONFIG_FILE`: the config file that ops will load

`OPS_YML_DIR` will be the current working directory, unless `ops` was invoked with the `-f|--file` option, telling it to load a different file than `./ops.yml`.

## Comparing environments

While your `staging` and `production` config and secrets files should be checked in, your `dev` config and secrets files should not. This is because each developer wants to have their own dev system, and any changes to that system (URLs, usernames, passwords, etc.) don't warrant a checkin: they shouldn't affect other developers.

When you add new environment variables to checked-in config or secrets, other developers probably need to add those to their `dev` environment in order to use your feature. It can be a bit of a pain to manually compare `dev` secrets to `production` secrets and find the keys that are different, and then to do that for config as well.

That's why `ops` has the `envdiff` builtin:

```shell
$ ops envdiff dev staging
Environment 'dev' defines keys that 'staging' does not:

   - [CONFIG] REGISTRY_FQDN
   - [CONFIG] CONTAINER_TAG
   - [CONFIG] TF_VAR_container_tag
   - [CONFIG] TF_VAR_registry_fqdn
   - [SECRET] REGISTRY_PUSH_USERNAME
   - [SECRET] REGISTRY_PUSH_PASSWORD
   - [SECRET] TF_VAR_registry_pull_username
   - [SECRET] TF_VAR_registry_pull_password

Environment'staging' defines keys that 'dev' does not:

   - backend_config_params

$
```

This makes it easy for a developer to see what environment variables they need to add to their `dev` config and secrets.

If there's a key you know should be in some environments and not in others, put it in the `envdiff.ignored_keys` option and `ops envdiff` won't mention it again.

```yaml
options:
  envdiff:
    ignored_keys:
      - backend_config_params
```

```shell
$ ops envdiff dev staging
Environment 'dev' defines keys that 'staging' does not:

   - [CONFIG] REGISTRY_FQDN
   - [CONFIG] CONTAINER_TAG
   - [CONFIG] TF_VAR_container_tag
   - [CONFIG] TF_VAR_registry_fqdn
   - [SECRET] REGISTRY_PUSH_USERNAME
   - [SECRET] REGISTRY_PUSH_PASSWORD
   - [SECRET] TF_VAR_registry_pull_username
   - [SECRET] TF_VAR_registry_pull_password

$
```