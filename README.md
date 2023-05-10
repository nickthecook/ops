# ops

[![Gem Version](https://badge.fury.io/rb/ops_team.svg)](https://badge.fury.io/rb/ops_team)

[View on RubyGems.org](https://rubygems.org/gems/ops_team)

> If you're on `ops` >= 2.0.0, you're running code from the [`crops`](https://github.com/nickthecook/crops) repo.

`ops` is like an operations team for your project. It allows you to implement automation for your project in a simple and readable way.

`ops` aims to be:

- **simple**: easy to use even for people who know nothing about how the tool works; no "namespaces" or DSLs
- **self-contained**: no references to external resources, just run `git clone` and `ops up` to use an `ops`-enabled project
- **self-documenting**: your `ops` configuration documents how to use your project as you automate tasks; no documentation drift
- **environment-aware**: support different configurations for different environments without implementing support in your code

With this `ops.yml` in your repo root:

```yaml
dependencies:
  brew:
    - docker-compose
    - tmux
  cask:
    - font-anonymice-powerline
  apt:
    - sl
  custom:
    - bundle install --quiet
actions:
  test:
    command: environment=test bundle exec rspec --exclude-pattern 'spec/e2e/**/*_spec.rb'
    alias: t
    description: runs unit tests
  lint:
    command: bundle exec rubocop --safe-auto-correct
    alias: l
    description: runs rubocop with safe autocorrect
  build:
    command: gem build ops_team.gemspec
    alias: b
    description: builds the ops_team gem
  install:
    command: gem i `ls -t ops_team-*.gem | head -n 1`
    alias: i
    description: installs the ops_team gem from a local gemfile
```

You can do this:

![ops in action](ops.png)

`ops` works on MacOS and Linux.

(If you're at Shopify, `ops` is like `dev` but focuses on managing things inside a repo, not your whole computer's dev environment.)

There are a number of features in `ops` beyond basic automation. See details here:

- [environment](docs/environment.md)
- [config and secrets](docs/config_and_secrets.md)
- [dependencies](docs/dependencies.md)
- [hooks](docs/hooks.md)
- [actions](docs/actions.md)
- [use with terraform](docs/terraform.md)

## Why `ops`?

For some good reasons to use `ops` for your projects, see [Why ops?](docs/why.md).

## Getting started

### Installing

##### With a normal Ruby installation

Manually:

`gem install ops_team`

With `bundler`:

`gem 'ops_team'`

You can install the `ops_team` gem with bundler, but more likely `ops` will be installing and running bundler; not the other way around.

### Testing

To make sure the gem is installed and the `ops` executable is in your `$PATH`:

```shell
$ ops version
1.3.0
$
```

### Running

```shell
# from the repo where you wish to use ops
$ ops init
```

There are some specialized templates for terraform and ruby projects. You can run:

```shell
$ ops init terraform  # template pre-populated with common terraform configuration
$ ops init ruby       # template pre-populated with common ruby configuration
```

*(If you'd like to see a template for another language, please submit a PR or create an issue.)*

You can also use your own ops templates, or copy one from another project, by passing a filename:

```shell
$ ops init ~/src/templates/python.yml
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

```shell
$ ops h
Running 'echo hello world ' from ops.yml in environment 'dev'...
hello world
```

### Command-line options

```
Usage:
Usage: ops [-f|--file <ops_yml>] action [<action args>
  ops_yml:      the config file to load instead of './ops.yml'
  action_args:  arguments to the action loaded from the config file; depends on the action
```

### Sample `ops.yml`

The ruby template for `ops.yml` looks something like:

```yaml
dependencies:
  gem:
    - bundler
    - rerun
  custom:
    - bundle
actions:
  start:
    command: echo update me
    description: starts the app
  stop:
    command: echo update me too
    description: stops the app
  test:
    command: rspec
    alias: t
    description: runs unit tests
  test-watch:
    command: rerun -x ops test
    alias: tw
    description: runs unit tests every time a file changes
  lint:
    command: bundle exec rubocop --safe-auto-correct
    alias: l
    description: runs rubocop with safe autocorrect
  build:
    command: gem build *.gemspec
    alias: b
    description: builds the gem
  install:
    command: gem install `ls -t *.gem | head -n1`
    alias: i
    description: installs the gem
  build-and-install:
    command: ops build && ops install
    alias: bi
    description: builds and installs the gem
options:
  exec:
    load_secrets: true
```

## Dependencies

In the above sample file, the `dependencies` section lists things that this project depends on in order to run. These dependencies are satisfied when the `ops up` command is run.

The following dependency types are supported:

- `brew`: installs a package using [Homebrew](https://brew.sh/) if running on a Mac
- `cask`: installs a Homebrew cask if running on a Mac
- `apt`: installs a package using `apt` if running on debian-based linux
- `apk`: installs a package using `apk` if running on alpine linux
- `gem`: installs a gem
- `docker`: uses `docker-compose` to start and stop a service in a subdirectory of your project
- `custom`: runs a custom shell command
- `dir`: creates a local directory (for when your app needs a directory, but there are no checked-in files in it)
- `sshkey`: creates an SSH key at the given path, if it doesn't already exist; can be configured to encrypt the private key with a passphrase

`ops up` is **idempotent**, so if you're not sure what your local state is, or you've just added one dependency, you can run `ops up` and `ops` will only try to satisfy unsatisfied dependencies. (You can also run, for example, `ops up custom`, or `ops up brew cask` to have `ops` just satisfy dependencies of certain types. `ops up sshkey` is handy to have `ops` add an SSH key to your agent when you don't want to satisfy all your configured dependencies.)

This feature allows developers that are new to a project to get up and running **without knowing anything about the app itself**. Your `ops.yml` should allow a developer to `ops up && ops start` to run an application.

For more details on dependencies, see [Dependencies](docs/dependencies.md).

## Builtins

Built-in commands are:

```
  bg                    runs the given command in a background session
  bglog                 displays the log from the current or most recent background task from this project
  countdown             Like `sleep`, but displays time remaining in terminal.
  down                  stops dependent services listed in ops.yml
  env                   prints the current environment, e.g. 'dev', 'production', 'staging', etc.
  envdiff               compares keys present in config and secrets between different environments
  exec                  executes the given command in the `ops` environment, i.e. with environment variables set
  help                  displays available builtins and actions
  init                  creates an ops.yml file from a template
  up                    attempts to meet dependencies listed in ops.yml
  version               prints the version of ops that is running
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

For more information on actions, see [Actions](docs/actions.md).

## Environments

One of the goals of `ops` is to make things easy in `dev` while allowing it to co-exist with `production`. `ops` uses the concept of "software execution environment" to do this.

By default, `ops` runs actions and builtins in the environment `dev`; that is, if `$environment` is not set, `ops` sets it to `dev`.

Actions and builtins can refer to this variable to do different things in different environments. For example, an app might log to a different directory in `production` than in `dev`:

```yaml
dependencies:
  dir:
    - log/$environment
actions:
  start:
    command: run-the-app &> "log/$environment/app.log"
```

In addition, `ops` will attempt to load other environment variables from the config file `config/$environment/config.json` and secrets from `config/$environment/secrets.ejson`. This allows your repo to support different configurations for different environments without implementing support in your code. For more information about this feature, see [Config and Secrets](docs/config_and_secrets.md).

For more information about `ops` and environment variables, see [Environment Variables](docs/environment.md).

## Contributing

See [Developing Ops](docs/developing.md).
