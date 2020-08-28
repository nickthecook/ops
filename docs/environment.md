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

- `OPS_YML_DIR`: the directory in which `ops` was run and which contains the `ops.yml` file `ops` has loaded
