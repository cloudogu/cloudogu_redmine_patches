# Cloudogu Redmine Patches

Redmine plugin (`zzz_cloudogu_redmine_patches`) is a collection of small patches picked up during the Redmine 5 to 6 upgrade of the Redmine Dogu.
Mostly CAS compatibility fixes plus one Rails deprecation silencer.
Everything here is a workaround for a Redmine or CAS bug, not a feature.

See [PATCHES.md](PATCHES.md) for what each patch does and why.

## Install

The routes and migration only load from `redmine/plugins/cloudogu_patches`.
The directory name matters (see the path comments in the source files).

Drop the plugin there, then run:

```
bundle exec rake redmine:plugins:migrate NAME=cloudogu_patches RAILS_ENV=production
```

Afterwards, restart Redmine.

## Cleanup backlog

- The CAS SLO patch logs at `info` level — see the "Watch out" note under patch 1 in
  [PATCHES.md](PATCHES.md).
- This plugin has no test coverage. A request spec for the SLO POST path would catch regressions
  from a Redmine upgrade.

## Checking whether a patch is still needed

Each patch's source comment carries the UUID of the error that triggered it, e.g.
`[f701c61a-05a5-4e75-b38c-077ffa60fe60]`. After a Redmine or CAS upgrade, grep the logs for that
UUID or the surrounding error message. If the error doesn't occur without the patch, it's fixed
upstream - disable the patch on staging first, then remove it.

## Versioning

Version is a hardcoded string in `init.rb` (currently `0.0.11`), bumped manually per commit.
There's no changelog - `git log init.rb` is the changelog.
