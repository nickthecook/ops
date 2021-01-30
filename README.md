# ops

[![Gem Version](https://badge.fury.io/rb/ops_team.svg)](https://badge.fury.io/rb/ops_team)

[View on RubyGems.org](https://rubygems.org/gems/ops_team)

`ops` is like an operations team for your project. It allows you to implement automation for your project in a simple and readable way.

`ops` aims to be:

- **simple**: easy to use even for people who know nothing about how the tool works; no "namespaces" or DSLs
- **self-contained**: no references to external resources, just run `git clone` and `ops up` to use an `ops`-enabled project
- **self-documenting**: your `ops` configuration documents how to use your project as you automate tasks; no documentation drift

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

## Why ops?

### Discoverability

Has anyone ever asked you how to connect to the database in a project you worked on? Where to find config files? What arguments to provide to `bin/do_the_thing`?

On a team that uses `ops`, you would put this information in `ops.yml` inside the repo. Other developers would know to look in that file for info about the project. If they just wanted to run your app, they would know that if they ran `ops up && ops start` that dependencies would be satisfied and the app would start up, without knowing a thing about how it worked.

```yaml
actions:
  connect-to-db:
    command: psql ssl_mode=verify-full -h $DB_HOST -U $DB_USER -d $DB_DATABASE
    alias: db
    load_secrets: true
```

Now other developers can run `ops help` and see that there is a command to connect to the database. If this simple bit of automation doesn't work for them, `ops.yml` _gives them a command they can adapt to fit their needs_. It allows you to make things "magic", but makes it easy for others to learn how the magic works, if they want to.

### Simplicity

Have you ever tried to run `rake` or `mvn` task, had it fail, and struggled to find the definition of the failed task? Have you ever had to dig through the code to remember the `namespace:of:the:task:you:want`?

There are several automation and dependency-management tools for your repo. However, they often require learning a DSL and using complex features like namespaces or files distributed throughout the repo. Also few (if any) of them have built-in support for the many dependency types supported by `ops`.)

With `ops`, all the info you need to see what command was run with what arguments is in `ops.yml` in the current directory. It's plain `YAML`; no DSLs here. It's completely self-contained: your `ops.yml` file _will_ include the action you ran that failed, and it will be easy to see exactly what command it ran.

### Encapsulation

Do you have to set up a bunch of dependencies when you want to run a new project? Do you ever have to reach out to other developers because when you want to run a project they wrote you get a cryptic error about a missing dependency?

`ops.yml` allows a developer to record dependency info inside a project, including what operating system packages are required, and even what custom commands must be run to get a newly-cloned repo into a usable state.

```yaml
dependencies:
  brew:
    - docker
    - docker-compose
    - libpq
  apt:
    - docker.io
    - docker-compose
    - postgresql-client-common
    - postgresql-client-10
  gem:
    - ejson
  custom:
    - git submodule update --init
```

With this configuration in `ops.yml`, all you need to do is `ops up`, and ops will install those dependencies. This project would even have its dependencies satisfied on both MacOS and a Debian-based distribution of Linux.

`ops` allows a project repo to include all the information required to run it. `ops` needs no information besides the `ops.yml` file in your current directory to do its job. This makes the `git clone ... && ops up` workflow simple and reliable.

`ops` supports many more types of dependency. For a complete list, see [Dependencies](docs/dependencies.md).

### Language-independence

`ops` is written in Ruby and distributed as a gem, but it can manage projects written in any language. (Many automation frameworks can technically do this, even if written primarily for one language. However, they do tend to show their biases, some more heavily than others.)

Since its config file is plain ol' `YAML`, and you automate things with shell commands, `ops` assumes nothing about the language in which your project is written.

### Simple secrets management

Do you do devops? Does your team run the services they build? Do you have to jump through hoops to provide your production services with secrets?

With an `ops.yml` like this:

```yaml
dependencies:
  sshkey:
    - keys/me@some_server
actions:
  ssh_to_server:
    command: ssh -i keys/me@some_server me@hostname
    load_secrets: true
    alias: ssh
options:
  sshkey:
    passphrase_var: SSH_KEY_PASS
```

and a `config/dev/secrets.ejson` like this:

```yaml
{
  "_public_key": "ee44b78aee3f164d49618bb954bd4551418ee4a0397c32bc5f8708295277bc0f",
  "environment": {
    "SSH_KEY_PASS": "EJ[1:cHQTD2/i6eAbGV9oVkcuz8GcMrwR1fbRky0u4ckVcnY=:uW8w3TAruReLoLFYe1ok2W89e/qPXTEG:aU5sc+Jvmh7meBgP77+Watk8rihaPKpXzTDDjd7tbFxuGqA3wXosC4SDlQ==]"
  }
}
```

when you run `ops up`, ops will generate a passphrase-protected SSH key for you _and add it to your SSH agent_. You can authorize that key on your server (or provide your own authorized key - if the key exists ops won't overwrite it) and then `ops ssh` will take you to the server. Also, because the key is passphrase-protected, _you can check it in_. With your `$SSH_KEY_PASS` set in your `secrets.ejson` file, anyone with the private EJSON key will have the above key automatically decrypted and added to their SSH agent, but it will be impossible to use the key otherwise.

Ops uses [`ejson`](https://github.com/Shopify/ejson) to make it easy to check in and protect secrets. You only need to provide one secret (the `ejson` private key) and all your other secrets are unlocked.

If you have an encrypted `secrets.ejson` file at `config/dev/secrets.ejson`, and the private key is available to `ejson`, ops will automatically load secrets from that file into environment variables for any action in which you specify `load_secrets: true`. (Secrets are not loaded by default for every action to avoid accidental secret leakage.)

If you set `$environment` to `staging`, `ops` will look for secrets in `config/staging/secrets.ejson`. Give everyone the ejson private key to the `dev` and `staging` secrets files, and guard the key to the `production` ejson file with your life.

For more information on how ops uses config and secrets, see [Config and Secrets](docs/config_and_secrets.md).

### Support for environments

`ops` has the concept of software execution environment built right in. If the `$environment` variable is not set, `ops` will set it to `dev` for any commands it runs. Use the `$environment` variable in commands and paths in your `ops.yml` to have separate SSH keys, config, and secrets for each environment.

To switch to another environment, just `export environment=staging`, and you've switched from dev config and secrets to staging.

If you chose not to use environment-aware features like automatic config and secret loading, `ops` will not bother you.

With environment-awareness, you can write your `ops.yml` file like this:

```yaml
actions:
  echo "$REGISTRY_PUSH_PASSWORD" | docker login "$REGISTRY_FQDN" --username "$REGISTRY_PUSH_USERNAME" --password-stdin
    alias: dl
    load_secrets: true
```

You can define `REGISTRY_PUSH_PASSWORD` for your `dev` environment in `config/dev/secrets.ejson`, and define the production variables in `config/production/secrets.ejson`. `ops` will use the correct config depending on the value of your `$environment` variable.

To see more of how to use the concept of software execution environment with `ops`, see [Environment](docs/environments.md).

### Support for running actions in the background

`ops bg my_action` will run an action in the background, saving its output to a file in `/tmp`. If you run this command from a directory called `myproject`, the file will be named `/tmp/ops-bglog-myproject`. You can override the path to this file with the `options.background.log_filename`, e.g.:

```yaml
options:
  background:
    log_filename: /some/other/path
```

You can run `ops bglog` to have ops `cat` the file to your terminal. If you provide arguments to `ops bglog`, `ops` will run `tail` instead of `cat` and pass your arguments to `tail`. E.g., to follow the file, run `ops bglog -f`. To follow it and show 100 lines of output instead of the default 10, run `ops bglog -f -n 100`. `ops bglog` just saves you the trouble of telling `cat` or `tail` where the file is.

The log file will have permissions set to `600`, so only your current user will be able to read the file, even if it's created in `/tmp`. This ensures that any sensitive output such as passwords are not shared with other users.

### Version-checking

If you want to use a recent `ops` feature or ensure that a particular bug fix is present before `ops` runs actions from your `ops.yml`, you can use the `min_version` setting:

```yaml
min_version: 0.12.2
dependencies:
  ...
actions:
  ...
```

If an older version of `ops` (v0.12.0 or later) encounters this file, it will print a message like this and exit:

`ops.yml specifies minimum version of 0.12.2, but ops version is 0.12.0`

### Hooks

`ops` can be configured to run commands before executing any action. For example, if you want to ensure a container is built before any action is run, because the actions depend on the container, you could define a before hook like this:

```yaml
hooks:
  before:
    - cd test-container && docker build -t my_app .
actions:
  test:
    command: docker run -it my_app
```

With this configuration, when a user checks out the repo and runs `ops test`, the container will automatically be built.

For more information on hooks, see [Hooks](docs/hooks.md).

### Forwards

Sometimes a project is complex enough to split up into multiple directories. In this case, you may have `ops.yml` files in several places, but still want to provide easy access to these actions from the top-level directory.

```yaml
forwards:
  app: app
  inf: infrastructure
```

With this config, `ops app test` will have the same effect as running `ops test` from the `app` directory. `ops inf deploy` will be the same as `cd infrastructure && ops deploy`.

When a command is forwarded to another directory, no config, secrets, or environment variables are set based on the current directory's `ops.yml`, and no hooks are run from the current directory's `ops.yml`.

If you want access to the top-level directory's config or secrets from the subdirectory, link it in the subdirectory's `ops.yml`:

```yaml
dependencies:
  custom:
    - ln -sf ../config config
```


### Terraform

`ops` provides a number of features that make working with `terraform` easier. For details, see [Terraform](docs/terraform.md).

## Getting started

### Installing

##### With a normal Ruby installation

Manually:

`gem install ops_team`

With `bundler`:

`gem 'ops_team'`

You can install the `ops_team` gem with bundler, but more likely `ops` will be installing and running bundler; not the other way around.

##### On a Mac with built-in Ruby

You can install the gem with `sudo`, using the default MacOS Ruby interpreter:

```shell
sudo gem i ops_team
```

Or you can install `ops_team` to your user-gem directory:

```shell
gem i --user-install ops_team
```

In this case, you may need to add your gems' `bin/` directory to your `$PATH` variable. To find the path to the right `bin/` directory:

```shell
$ gem environment | grep "EXECUTABLE DIRECTORY"
  - EXECUTABLE DIRECTORY: /Users/nick/.gem/ruby/2.6.6/bin
```

To add it to your path, append this to your `.bashrc` or `.zshrc` (or equivalent for your shell):

```shell
export PATH="$PATH:/Users/yourusernamehere/.gem/ruby/2.6.6/bin"
```

If you get an error like:

```
ERROR:  Error installing ops_team:
    ERROR: Failed to build gem native extension.
```

then you need to install the XCode command line tools on a Mac, the `build-essential` package on a Debian-based distro, or the equivalent package on your Linux distro.

If you're using it on another platform, take a look at the test container Dockerfile for your platform in the `platforms/` directory to see what packages it installs.

### Testing

To make sure the gem is installed and the `ops` executable is in your `$PATH`:

```shell
$ ops version
0.6.0
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
  ops [options] <action> [<action_args>]
  ops help

    -f, --file FILE                  Load given file instead of loading ops.yml from the current directory
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

`ops up` is **idempotent**, so if you're not sure what your local state is, or you've just added one dependency, you can run `ops up` and `ops` will only try to satisfy unsatisfied dependencies.

This feature allows developers that are new to a project to get up and running **without knowing anything about the app itself**. Your `ops.yml` should allow a developer to `ops up && ops start` to run an application.

For more details on dependencies, see [Dependencies](docs/dependencies.md).

## Builtins

Built-in commands are:

```
  bg                    runs the given command in a background session
  bglog                 displays the log from the current or most recent background task from this project
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
