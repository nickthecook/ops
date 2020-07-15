# Dependencies

Dependencies listed in the `dependencies` section of `ops.yml` are satisfied when the `ops up` command is run. Some dependencies will be un-satisfied when you run `ops down`; e.g. services will be stopped, but packages won't be uninstalled.

This feature allows developers that are new to a project to get up and running without knowing anything about the app itself. Your `ops.yml` should allow a developer to `ops up && ops start` to run an application.

The following dependency types are supported:

### `brew`

- specifies that a particular `brew` package is needed
- will only run if you're on a Mac

### `apt`

- specifies that a particular package from `apt` is needed
- will only run if you're on Linux

### `apk`

- specifies that a particular package from `apk` is needed
- will only run if the `apk` command is available (usually only on Alpine linux)

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

### `docker`

E.g.:

```yaml
depdendencies:
  docker:
    deps/mysql
```

- specifies that this repo includes a directory with the given name (e.g. `deps/mysql`) that includes a `docker-compose.yml` file
- `ops` will change to the given directory and use `docker-compose` to start, stop, and check the status of this service as needed

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

### `dir`

E.g.:

```yaml
dependencies:
  dir:
    - container_data
    - logs
```

This dependency will ensure the given directory is created when you run `ops up`. This is handy for directories your app needs, but which contain no checked-in files, since `git` won't save empty directories.

### `sshkey`

E.g.:

```yaml
dependencies:
  sshkey:
    - keys/$environment/user@host
```

This dependency will create an SSH key pair with key size 2048 and key algorithm "rsa" at `keys/$environment/user@host` and `keys/$environment/user@host.pub`. It will also add it to your SSH agent, if `SSH_AUTH_SOCK` is set, with a lifetime of 3600 seconds (one hour).

The passphrase, key size, and ssh-agent lifetime (in seconds) can be configured. `sshkey.passphrase` will expand environment variables. Due to the high probability that you don't want to check in your passphrase in plaintext, you can use a secret as the passphrase, as in the following example.

```yaml
options:
  sshkey:
    passphrase: $ENV_VAR_LOADED_FROM_SECRETS
    key_size: 1024
    key_lifetime: 60
```

The key algorithm will be RSA. This cannot be configured yet.
