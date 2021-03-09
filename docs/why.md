# Why ops?

## Discoverability

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

## Simplicity

Have you ever tried to run `rake` or `mvn` task, had it fail, and struggled to find the definition of the failed task? Have you ever had to dig through the code to remember the `namespace:of:the:task:you:want`?

There are several automation and dependency-management tools for your repo. However, they often require learning a DSL and using complex features like namespaces or files distributed throughout the repo. Also few (if any) of them have built-in support for the many dependency types supported by `ops`.)

With `ops`, all the info you need to see what command was run with what arguments is in `ops.yml` in the current directory. It's plain `YAML`; no DSLs here. It's completely self-contained: your `ops.yml` file _will_ include the action you ran that failed, and it will be easy to see exactly what command it ran.

## Encapsulation

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

## Language-independence

`ops` is written in Ruby and distributed as a gem, but it can manage projects written in any language. (Many automation frameworks can technically do this, even if written primarily for one language. However, they do tend to show their biases, some more heavily than others.)

Since its config file is plain ol' `YAML`, and you automate things with shell commands, `ops` assumes nothing about the language in which your project is written.

## Simple secrets management

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

## Support for environments

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

## Support for running actions in the background

`ops bg my_action` will run an action in the background, saving its output to a file in `/tmp`. If you run this command from a directory called `myproject`, the file will be named `/tmp/ops-bglog-myproject`. You can override the path to this file with the `options.background.log_filename`, e.g.:

```yaml
options:
  background:
    log_filename: /some/other/path
```

You can run `ops bglog` to have ops `cat` the file to your terminal. If you provide arguments to `ops bglog`, `ops` will run `tail` instead of `cat` and pass your arguments to `tail`. E.g., to follow the file, run `ops bglog -f`. To follow it and show 100 lines of output instead of the default 10, run `ops bglog -f -n 100`. `ops bglog` just saves you the trouble of telling `cat` or `tail` where the file is.

The log file will have permissions set to `600`, so only your current user will be able to read the file, even if it's created in `/tmp`. This ensures that any sensitive output such as passwords are not shared with other users.

## Version-checking

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

## Hooks

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

## Forwards

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


## Terraform

`ops` provides a number of features that make working with `terraform` easier. For details, see [Terraform](docs/terraform.md).

