## 1.14.0

#### Reduce overhead time of ops by 50%

In the following output, `ops` is 1.13.0 and `bin/ops` is 1.14.0:

```shell
$ time ops env
devops env  0.32s user 0.18s system 47% cpu 1.037 total
$ time bin/ops env
devbin/ops env  0.10s user 0.08s system 42% cpu 0.437 total
$ time ops exec 'echo hi there'
hi there
ops exec 'echo hi there'  0.32s user 0.19s system 49% cpu 1.016 total
$ time bin/ops exec 'echo hi there'
hi there
bin/ops exec 'echo hi there'  0.12s user 0.10s system 46% cpu 0.464 total
$ time ops exec ls
Gemfile				docs				ops.yml				ops_team-1.6.1.gem		pebble
Gemfile.lock			etc				ops_team-1.11.0.pre.rc.gem	ops_team-1.6.2.gem		platforms
LICENSE				keys				ops_team-1.13.0.gem		ops_team-1.7.0.gem		runtime_data
README.md			lib				ops_team-1.6.0.gem		ops_team-2.0.0.gem		spec
bin				loader.rb			ops_team-1.6.0.pre.pre.gem	ops_team.gemspec		tmp
config				ops.png				ops_team-1.6.0rc1.gem		ops_up.out
ops exec ls  0.31s user 0.19s system 49% cpu 1.023 total
$ time bin/ops exec ls
Gemfile				docs				ops.yml				ops_team-1.6.1.gem		pebble
Gemfile.lock			etc				ops_team-1.11.0.pre.rc.gem	ops_team-1.6.2.gem		platforms
LICENSE				keys				ops_team-1.13.0.gem		ops_team-1.7.0.gem		runtime_data
README.md			lib				ops_team-1.6.0.gem		ops_team-2.0.0.gem		spec
bin				loader.rb			ops_team-1.6.0.pre.pre.gem	ops_team.gemspec		tmp
config				ops.png				ops_team-1.6.0rc1.gem		ops_up.out
bin/ops exec ls  0.12s user 0.10s system 43% cpu 0.496 total
```
