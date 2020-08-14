## Config

`ops` will load the config file `config/$environment/config.json` and set environment variables for any values found in the "environment" section of the file.

```json
{
  "environment": {
    "KEY": "VALUE"
  }
}
```

`ops` will load these config variables every time it runs; prior to all builtins and actions.

If a variable is set to a hash or an array, `ops` will JSON-encode the value. E.g. the following JSON:

```json
{
  "environment": {
    "KEY": {
      "OTHER_KEY": "VALUE"
    }
  }
}
```

will result in `$KEY` being set to `{\"OTHER_KEY\":\"VALUE\"}`.

Unlike environment variables defined in the `options.environment` section of `ops.yml`, these variables can be different for dev, production, or staging, since `ops` will load a different file depending on the value of `$environment`.

You can override the path to the config file in `options`. E.g.:

```yaml
options:
  config:
    path: config/$environment.json
```

`ops` can also load YAML config files:

```yaml
options:
  config:
   path: config/$environment/config.yml
```

## Secrets

`ops` will optionally load secrets from [`.ejson`](https://github.com/Shopify/ejson) files into environment variables before running actions.

`ops` _will not_ load secrets by default, to help a user avoid leaking secrets unintentionally. An `action` can be configured to load secrets by setting `load_secrets: true` in the `action` definition.

By default secrets are loaded from `config/$environment/secrets.ejson`, where `$environment` is set to the current environment, like `dev`, `prod`, `staging`, or any other string. If the variable is not set, `ops` assumes the `dev` environment.

For example, given this secrets file at `config/dev/secrets.ejson`:

```json
  "_public_key": "740ec2a8a5ace01055b682326c437bb3d976c1d35ad7e6434f72bf0334023e15",
  "environment": {
    "API_TOKEN": "EJ[1:VNdUPtGzDAN+LYexKTR1cVzbE397Jnl6oxV7dqCbETA=:OBey+AO8/K/CG37BzU7BLW+vSsvnFCBN:lmj5L4ipt4YGYABlk+peePrgs5ZMY/kmRystcC+pJdk=]"
  }
}
```

the environment variable `API_TOKEN` can be set automatically when an action is run by specifying `load_secrets: true` in that action definition:

```yaml
actions:
  post:
    command: curl -X POST "https://example.com/api?token=$API_TOKEN"
    load_secrets: true
```

The secret remains encrypted by `ejson` in your repo, but if you have the private key to decrypt that file available to `ejson` at runtime, the secrets will be decrypted and loaded into your environment, available to actions that need them.

If you want to keep the secrets file in a different location, you can configure the location with the following option in your `ops.yml` file:

```yaml
options:
  secrets:
    path: "secrets/$environment.ejson"
```

Environment variables are expanded by `ops` when loading this path, due to the high likelihood of the environment name being somewhere in the path.

If `ops` looks for an `ejson` secrets file and cannot find it, it will fall back to the equivalent `.json` file. This allows you to keep a secrets file for your development environment that is not encrypted, for easier editing and debugging.

### Secrets and the `exec` builtin

The `exec` builtin executes a shell command from within the `ops` environment; that is, with `$environment` and any environment variables defined in config and options set. This can be useful for testing that config and secrets are being loaded correctly.

By default, `exec` does not load secrets. This can be overridden with the following option:

```yaml
options:
  exec:
    load_secrets: true
```

