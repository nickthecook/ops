# Dependencies

Dependencies listed in the `dependencies` section of `ops.yml` are satisfied when the `ops up` command is run. Some dependencies will be un-satisfied when you run `ops down`; e.g. services will be stopped, but packages won't be uninstalled.

This feature allows developers that are new to a project to get up and running without knowing anything about the app itself. Your `ops.yml` should allow a developer to `ops up && ops start` to run an application.

The following dependency types are supported:

### `brew`

- specifies that a particular `brew` package is needed
- will only run if you're on a Mac

### `apt`

- specifies that a particular package from `apt` is needed
- will only run if the `apt` executable is in the `$PATH`
- can specify a version with, e.g., `curl/7.52.1-5+deb9u7`
- run `apt-cache policy curl` to get available versions

### `apk`

- specifies that a particular package from `apk` is needed
- will only run if the `apk` command is in the `$PATH` (usually only on Alpine linux)

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

### `snap`

```yaml
dependencies:
  snap:
    - mosquitto
```

`snap` seems to require sudo on most distros by default, so `ops` will use `sudo` by default. Options supported by the `snap` dependency are:

```yaml
options:
  snap:
    use_sudo: false  # default is true
    install: true  # default is false
```

Unlike `apt`, `brew`, or `apk`, `snap` may be present on any Linux system, and its presence alone probably shouldn't be taken as a sign that `ops` should install every snap listed in `dependencies`. Therefore, `ops` will never install snaps unless the `snap.install` option is `true`.

For example, on Solus Linux, `snap` is necessary to install the `mosquitto` MQTT broker, but on Debian I would `apt install mosquitto-tools` instead. So both of these dependencies would be listed in the `ops.yml`. However, I may still have `snap` present; I just wouldn't want `ops` to install snaps unless I told it to, or it would install both the apt package and the snap.

Managing these options via hard-coded strings in `ops.yml` isn't the best solution, however; this file is checked in, but whether or not to install snaps should be based on environment. In the future, `ops` will support using env vars to set any option, based on a scheme like `apt.use_sudo` == `$APT__USE_SUDO`.

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

#### `custom` dependencies with `up` and `down`

If a `custom` dependency is given as a hash, you can define separate `up` and `down` actions that are run when `ops up` or `ops down` are called, respectively.

```yaml
dependencies:
  custom:
    - init file:
        up: touch file
        down: rm file
```

You can also define only the `down` command, which will execute on `ops down`; nothing will be executed by the dependency on `ops up`.

**Note that** the lines with `up` and `down` are indented past the beginning of the text `init file`. YAML considers `- ` in a list to be part of the indentation, and `up` and `down` must be _children_ of the name of the custom depdenceny, not siblings. Therefore, the following is **incorrect**:

```yaml
dependencies:
  custom:
    - init file:
      up: touch file
      down: rm file
```

as it results in a Hash like:

```ruby
{
  "init file" => nil,
  "up" => "touch file",
  "down" => "touch file"
}
```

### `dir`

E.g.:

```yaml
dependencies:
  dir:
    - container_data
    - logs
```

This dependency will ensure the given directory is created when you run `ops up`. This is handy for directories your app needs, but which contain no checked-in files, since `git` won't save empty directories.

### `pip`

E.g.:

```yaml
dependencies:
  pip:
    - requests
```

This dependency ensures that the given Python package is installed.

#### Options

The command used to run `pip` can be configured. By default, it is `python3 -m pip`.

```yaml
options:
  pip:
    command: pip3
```

### `sshkey`

E.g.:

```yaml
dependencies:
  sshkey:
    - keys/$environment/user@host
```

This dependency will create an SSH key pair with key size 4096 and key algorithm `rsa` at `keys/$environment/user@host` and `keys/$environment/user@host.pub`. It will also add it to your SSH agent, if `SSH_AUTH_SOCK` is set, with a lifetime of 3600 seconds (one hour).

The key comment, which is visible in the output of `ssh-add -l`, will be set to the name of the directory that contains `ops.yml`. For example, if the directory is named `heliograf`, you would see the following output:

```shell
$ ssh-add -l
2048 SHA256:7n9WwisFkDtemOx8O/+D33myKpjOvrjx3PZcNb9y6/Y heliograf (RSA)
2048 SHA256:Z6oEPBIoBrHv/acYiBGBRYLe2sEONV17tDor3h5eNtc certitude (RSA)
```

This output shows that one key from a project called `heliograf` and one key from a project called `certitude` have been loaded.

#### Options

The passphrase, key size, key algorithm, and ssh-agent lifetime (in seconds) can be configured.

```yaml
options:
  sshkey:
    passphrase_var: ENV_VAR_LOADED_FROM_SECRETS
    key_size: 8192
    key_algo: ed25519
    key_lifetime: 60
```

_With the "ed25519" algorithm, `key_size` can still be specified, but will be ignored by `ssh-keygen`, since all keys for that algorithm are 256 bits._

`sshkey.passphrase_var` should be the name of an environment variable, without a leading `$`. This allows you to define the passphrase in your `secrets.ejson` file, and avoid storing it or checking it in in plaintext.

The default values are:

```yaml
key_size: 4096
key_algo: rsa
key_lifetime: 3600 # seconds
passphrase_var: "" # no passphrase var, so no passphrase
```

Adding the key to the SSH agent can be disabled by setting `add_keys: false`:

```yaml
options:
  sshkey:
    add_keys: false
```

The default behaviour is to add SSH keys to the SSH agent. Keys will still be saved to disk when `add_keys` is `false`.
