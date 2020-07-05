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

