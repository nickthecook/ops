# Ops adds Turing-complete YAML

Have you heard of config-as-code?

It's a technique for treating config as you would code, in that you check it into your repo, alongside your app's source code. This can obviate the need for a separate config service to feed your app its config at runtime. It's a powerful technique that reduces the complexity of your deployed service.

However, the limitations of config have always prevented us from making the most of this technique. Your config is still just simple strings, integers, and maybe some nested objects.

## Introducing Turing-complete YAML (TurML)

TurML is code-as-config.

With TurML, you will no longer be held back by the limitations of static config. Your config will be able to handle the nuances of your different environments so your application doesn't have to.

Observe the duplication between the staging and production environments in this example config:

```yaml
environments:
  staging:
    precompile_assets: yes
    throttle_requests: yes
    enforce_tls: yes
  production:
    precompile_assets: yes # DUPLICATE
    throttle_requests: yes # DUPLICATE
    enforce_tls: yes       # DUPLICATE
  development:
    precompile_assets: no
    throttle_requests: no
    enforce_tls: no
```

Following the best practice of setting your defaults for your dev environment and overriding for production environments can be awkward.

With TurML, however, the duplication disappears. Behold:

```yaml
environments:
  if:
    $environment in:
      ["staging", "production"]:
        precompile_assets: yes
        throttle_requests: yes
        enforce_tls: yes
      ["development"]:
        precompile_assets: no
        throttle_requests: no
        enforce_tls: no
```

Simple.

## Loops

No language is Turing-complete without a loop of some sort. Many languages, however, are overburdened with multiple types of loop: `while`, `for`, `each`. Some of them even have multiple sytaxes for the `for` loop!

To simplify things, TurML uses a _single_ keyword to allow you to implement any conceivable loop: `loop`.

```yaml
environments:
  production:
    hosts:
      - proxy.example.com
      - app.example.com
      - db.example.com
  staging:
    hosts:
      - proxy.staging.example.com
      - app.staging.example.com
      - db.staging.example.com
  urls:
    loop: [host, [production.hosts, staging.hosts]]
      unless: $host =~ /^db./
        value: "https://$host"
      else:
        value: "postgresql://$host:5432"
```

When combined with some basic conditional operators - `unless` and `else` - `loop` makes it trivial to programmatically build configuration values.

You can now remove code that does this from your application, reducing your app's complexity.

## Shell commands

Conditionals and loops are helpful, but to truly wield the power of TurML, you can make use of shell commands within your config. The shell commands will be processed every time you run an `ops` command.

```yaml
environments:
  production:
    admin_password: `openssl rand -base64 32`
```

Now you can generate strong passwords securely, right from your unencrypted config file.

```yaml
environments:
  production:
    hosts:
      - app.example.com
    provision: 
      loop: [host, [production.hosts]
        - "`ssh $host -c \"sudo apt update\"`"
        - "`ssh $host -c \"sudo apt install curl\"`"
```

Now your config is actually provisioning your nodes - all from YAML! So long, Ansible.

## Hello, World!

As some guy once said, the first program you should write in any language is "Hello World". TurML's Hello World is beautifully simple:

```yaml
hello: "`echo 'Hello, World! Wait, why is everyone looking at me like that?'`"
```

## Integration into `ops`

As of the next major release, [ops](https://github.com/nickthecook/ops) will load `config.yml` from your project root by default. Simply use TurML in this config file and `ops` will process it as described here.

No more separate configs for each environment, with a bunch of duplication between the files.

## Future

With a Turing-complete app config, much complexity can be removed from your app. Dynamic processing of config is just the beginning. It's easy to see how this would help with other aspects of config:

- initializing database schemas
- configuring firewall rules
- building docker containers for the app right on the production nodes so they're more "production"

Eventually, we will likely see apps implemented completely within TurML.

Take the complexity out of your code. Avoid turmoil. Use TurML.
