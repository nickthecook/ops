## Actions

Actions are defined in the `actions` section of `ops.yml`. If the first argument to `ops` is not a builtin (see section above), `ops` will look for an action with that name.

```yaml
actions:
  test:
    command: bundle exec rspec
    alias: t
  test-watch:
    command: rerun -x ops test
    alias: tw
```

This snippet shows two actions: `test` and `test-watch`. When `ops test` is run, `ops` will run `bundle exec rspec`.

Note that `test-watch` actually uses rerun to run `ops`; since `ops` is just an executable in your `$PATH`, it can be used in a `command` itself. This technique can be used to avoid duplicating parts of some commands, e.g. the `bundle exec rspec` in `test`.

### Aliases

An action can have one alias. If the first argument to `ops` is not a builtin or an action name, `ops` will look for an alias that matches the argument.

In the above example, the `test` action has the alias `t`. When `ops t` is run, `ops` will execute the `test` action.

### Naming actions

Here are some conventions to follow when naming your actions, so that you end up with common `ops` actions across your projects:

- `ops server` or `ops start` to start your app, if it's a server
- `ops stop` to stop your app
- `ops run` if it's a client, or a program that is expected to exit on its own
- `ops test` to run your local tests
- `ops test-watch` can be handy, using something like the `rerun` gem, to run tests every time a file changes

```yaml
actions:
  server:
    command: docker-compose up # or however you start your service
    alias: s
  stop:
    command: docker-compose down # or however you stop your service
    alias: st
  test:
    command: bundle exec rspec # or whatever runs your unit tests
    alias: t
  test-watch:
    command: rerun -x ops test # runs your tests every time a file changes
    alias: tw
```

## Actions, Config, and Secrets

`ops` loads environment variables defined in `config/$environment/config.json` before running any action.

`ops` has the ability to load secrets from an `ejson` file into environment variables, but it does not do this by default. To have `ops` load secrets before running an action, use the `load_secrets` option:

```yaml
actions:
  start:
    command: rackup
    load_secrets: true
```

For more information on the loading of config and secrets, see [Config and Secrets](docs/config_and_secrets.md).

## Shell expansion

By default, `ops` executes actions with shell expansion, which means variable references are expanded, file globbing is done, and quotes behave as one would expect.

However, this can get in the way sometimes.

```yaml
actions:
  query:
    command: mysql -h some_host -p some_db_name -e
```

In this case, the action is meant to allow the user to execute a query from the command line. If it's run with

`ops query 'select * from table;'`

the single quotes will be stripped by the shell in which the user ran the command. Then the command will be subject to shell expansion when executed by `ops`, resulting in a bare `*`, which is not the desired outcome. To execute this command safely, one would need to double-escape the `*`:

`ops query 'select \* from table;'`

Or put both double- and single-quotes around the query. Which is annoying, and possibly dangerous.

For actions like this, one can disable shell expansion, losing variable and glob interpolation and other shell features but gaining some predictability:

```yaml
actions:
  query:
    command: mysql -h some_host -p some_db_name -e
    shell_expansion: false
```

## Safeguards

Sometimes an action can be destructive when run. This is often fine in environments like `dev`, but not in `production`.

To prevent actions from being used in certain environments, `action` supports `in_envs` and `not_in_envs`.

```yaml
actions:
  force-destroy:
    command: bin/destroy_deployed_infrastructure -f
    not_in_envs:
      - production
      - staging
```

The above configuration will allow the action to be run in all environments except `production` and `staging`. If `in_envs` is defined, the action will only be allowed in environments that are listed.

```yaml
actions:
  force-destroy:
    command: bin/destroy_deployed_infrastructure -f
    in_envs:
      - dev
      - test
```

The above configuration will allow the action to be run only in `dev` and `test`.

If both `in_envs` and `not_in_envs` are defined, they will both be checked. If the action appears in `not_in_envs` or does not appear in `in_envs`, it will not be run.
