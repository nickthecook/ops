# ops

**This gem is still quite new; if you encounter an issue, please open an Issue in this project.**

[![Gem Version](https://badge.fury.io/rb/ops_team.svg)](https://badge.fury.io/rb/ops_team) 

[View on RubyGems.org](https://rubygems.org/gems/ops_team)

`ops` is like an operations team for your dev environment. It:

- reduces the cognitive load of getting up and running as a new developer on a project
- saves time by allowing command-line shortcuts for common tasks
- can be used in CI, to install dependencies, start services, and run tests, exactly as you do on your dev machine

The typical workflow is:

```
ops init   # to create the ops.yml file so you can edit
ops up     # to install dependencies and start services your app depends on
ops start  # to start your app
ops test   # to test your app
ops stop   # to stop your app
```

![ops up in action](ops.png)

## Getting started

### Installing

##### With a normal Ruby installation

Manually:

`gem install ops_team`

With Bundler:

`gem 'ops_team'`

##### On a Mac with built-in Ruby

```shell
gem i --user-install ops_team
```

In this case, you may need to add your gems' `bin/` directory to your `$PATH` variable in order to be. To find the path to the right `bin/` directory:

```
$ gem environment | grep "EXECUTABLE DIRECTORY"
  - EXECUTABLE DIRECTORY: /Users/nick/.gem/ruby/2.6.6/bin
```

To add it to your path, append this to your `.bashrc` or `.zshrc` (or equivalent for your shell):

```
export PATH="$PATH:/Users/yourusernamehere/.gem/ruby/2.6.6/bin"
```

### Testing it

To make sure the gem is installed and the `ops` executable is in your `$PATH`:

```
$ ops
File 'ops.yml' does not exist.
Usage: ops <action>
$
```

### Running

```shell
# from the repo where you wish to use ops
ops init
```

There are some specialized templates for terraform and ruby projects. You can run:

```shell
ops init terraform  # to get a template pre-populated with some common terraform commands
ops init ruby       # to get a template pre-populated with some common ruby commands
```

Edit `ops.yml` to suit your needs. There will be some examples in there that you will want to change.

Add an action like:

```yaml
actions:
  hello-world:
    command: "echo hello world"
    alias: h
```

Then run `ops h` (to use the alias) or `ops hello-world` to use the full command name.

The `ops.yml` for `ops` looks something ike:

```yaml
dependencies:
  brew:
    - docker
  apt:
    - curl
  docker:
    - pebble
  custom:
    - bundle install --quiet
    - echo "this is stdout"
actions:
  test:
    command: "bundle exec rspec"
    alias: t
  test-watch:
    command: "bundle exec rerun -x rspec"
    alias: tw
  tag:
    command: "bin/tag"
  build:
    command: gem build ops.gemspec
    alias: b
  install:
    command: gem i `ls -t *.gem | head -n 1`
    alias: i
```

## Dependencies

A few types of dependency are supported:

### `brew`

- specifies that a particular `brew` package is needed
- will only run if you're on a Mac

### `apt`

- specifies that a particular package from `apt` is needed
- will only run if you're on Linux

### `apk`

- specifies that a particular package from `apk` is needed
- will only run if the `apk` command is available (usually only on Alpine linux)

### `docker`

E.g.:

```yaml
depdendencies:
  docker:
    deps/mysql
```

- specifies that this repo includes a directory with the given name (e.g. `deps/mysql`) that includes a `docker-compose.yml` file
- `ops` will change to the given directory and use `docker-compose` to start, stop, and check the status of this service as needed

### `terraform`

- specifies that this repo includes a directory with the given name containing a terraform configuration
- `ops` will change to the given directory and use `terraform` to create or destroy resources

**Note:** To avoid prompting the user for input on every `ops up` and `ops down`, `ops` will pass the `--auto-approve` flag to `terraform` on both `apply` and `destroy` operations. You should only use `ops` to manage development resources, and *not* any resources you care about in the least.

### `custom`

E.g.:

```yaml
custom:
  - bundle install --quiet
```

- runs the given command
- can't tell if the command needs to be run or not, so always runs it on `ops up`
- therefore, the command should be idempotent
- it's also a good idea to prevent it from printing output unless it encounters an error, to keep the ops output clean

### `gem`

E.g.:

```yaml
gem:
  - ejson
```

- installs the gem with the given name
- by default, runs "gem install ...", but can be configured to use "sudo gem install" or "gem install --user-install" (see below)

The behaviour of the `gem` dependency type is affected by some options you can put in your `ops.yml` file. E.g.:

```yaml
dependencies:
  gem:
    - ejson
options:
  gem:
    use_sudo: false
    user_install: false
```

With this config, `ops up` will run `gem install ejson` to install the `ejson` gem. This is the default behaviour, and is used if the `options` section is not present in the file.

`use_sudo: true` causes `ops up` to run `sudo gem install ejson`.

`user_install: true` causes `ops up` to run `gem install --user-install ejson`.

### `dir`

E.g.:

```yaml
dependencies:
  dir:
    - container_data
    - logs
```

This dependency will ensure the given directory is created when you run `ops up`. This is handy for directories your app needs, but which contain no checked-in files, since `git` won't save empty directories.

## Builtins

Built-in commands are:

```
  init                  creates an ops.yml file from a template
  version               prints the version of ops that is running
  down                  stops dependent services listed in ops.yml
  env                   prints the current environment, e.g. 'dev', 'production', 'staging', etc.
  exec                  executes the given command in the `ops` environment, i.e. with environment variables set
  help                  displays available builtins and actions
  up                    attempts to meet dependencies listed in ops.yml
```

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

## Environment variables in `ops.yml`

`ops` will set any environment variables you define in the `options` section of `ops.yml` before running any built-in or action.

E.g.:

```json
options:
  environment:
    EJSON_KEYDIR: "./spec/ejson_keys"
```

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

Unlike environment variables defined in the `options.environment` section of `ops.yml`, these variables can be different for dev, production, or staging, since `ops` will load a different file depending on the value of `$environment`.

You can override the path to the config file in `options`. E.g.:

```json
options:
  config:
    path: config/$environment.json
```

## Secrets

`ops` will optionally load secrets from [`.ejson`](https://github.com/Shopify/ejson) files into environment variables before running actions.

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

## Contributing

Submit a PR that meets the following super-strict criteria:

- tests have been added or updated for your code changes
- `rspec` passes
- `rubocop` passes
