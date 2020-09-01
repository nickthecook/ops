# Developing Ops

Some things developers should know are listed here. Feel free to submit a PR to add/remove/correct things.

## Principles

As it says in the README, `ops` aims to be:

- **simple**: easy to use even for people who know nothing about how the tool works; no "namespaces" or DSLs
- **self-contained**: no references to external resources, just run `git clone` and `ops up`
- **environment-aware**: make things easy in `dev` while allowing it to co-exist with `production`

Make sure you follow these principles. Simplicity is very important in this tool, since it's trying to let the user automate tasks in a _self-documenting_, _discoverable_ way. That means 

1. no namespaces
2. no references to files outside the repo directory (except what the user adds themselves)
3. no state stored on disk beyond `ops.yml`

## Tests

There are two kinds of test suite to run against `ops`:

- unit tests (`ops test`)
- end-to-end tests* (`ops e2e`)

Unit tests are what you'd expect. They're written in RSpec.

End-to-end tests (e2e) run `ops` with different `ops.yml` files and check the visible outcomes to make sure `ops` did what it should have. For example, some e2e tests list an `sshkey` dependency in the `ops.yml` file and then check that the key got created, that it has a passphrase, etc.

The term "end-to-end" originates from testing applications with network APIs, but these tests are the same in principle: the code is not being executed by a test framework, it's actually running, and any tests are external to the application, observing its outward effects.

### Running tests when a file is changed

There are also actions to run tests any time a source file is changed:

- unit tests:       `ops test-watch`
- end-to-end tests: `ops test-e2e-watch`

Both suites run relatively quickly. At the time of writing (v0.13.3) the unit tests run in about **2s** on a Macbook Pro with 16GB of RAM, and the e2e tests run in about **5s**. It's easy and helpful to just keep tests running as you work on the code, and "keep the green wall at your back".

### Testing on various platforms

Unit tests and e2e tests can both be run on various flavours of linux using Docker:

- run unit tests on linux platforms: `ops test-platforms`
- run e2e tests on linux platforms: `ops test-platforms-e2e`

Currently supported platforms:

- alpine
- arch
- debian

At the time of writing, running e2e tests on all platforms takes under **30s**, each platform taking around **9s**.

You can run unit tests on all platforms too, but it would probably be of less value if you're already running unit tests directly on your development machine.

## Process

1. Write the code based on the `main` branch (we don't use `master`)
2. Pass the following test suites:

- `ops lint`
- `ops test`
- `ops e2e`
- `ops test-platform-e2e`

3. Submit a PR
