# ops
A config-driven agent to set up development environments.

## Getting started

```
# from this repo
gem build ops.gemspec
gem i ops-<version>.gem
# from the repo where you wish to use ops
ops init
```

Edit `ops.yml` to suit your needs.

## Dependencies

The only dependencies supported at the moment are `brew` packages.

## Commands

Supported commands are:

- `up`: installs dependencies
- `init`: creates `ops.yml` for your project
- any actions you define

E.g. `ops up`, `ops init`, or `ops start` (if you've defined a `start` action in `ops.yml`).

Some common actions are:

```yaml
actions:
  start:
    command: docker-compose up # or however you start your service
  stop:
    command: docker-compose down # or however you stop your service
  test:
    command: bundle exec rspec # or whatever runs your unit tests
  test-watch:
    command: bundle exec rerun -x rspec # runs your tests every time the
```

## Next feature

The next planned feature is `alias`:

```yaml
actions:
  test:
    alias: t
    command: "..."
```

You would be able to run `ops t` and it would be like running `ops test`.

There are also some basic output messages the app needs, so you know what it's doing.
