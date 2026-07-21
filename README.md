# Cloudogu Redmine Patches

Redmine plugin (`zzz_cloudogu_redmine_patches`) is a collection of small patches picked up during the Redmine 5 to 6 upgrade of the Redmine Dogu.
Mostly CAS compatibility fixes plus one Rails deprecation silencer.
Everything here is a workaround for a Redmine or CAS bug, not a feature.

See [PATCHES.md](PATCHES.md) for what each patch does and why.
See [HANDOVER.md](HANDOVER.md) for open issues, versioning infos, and how to check whether a patch is still required after a Redmine upgrade.

## Install

The routes and migration only load from `redmine/plugins/cloudogu_patches`.
The directory name matters (see the path comments in the source files).

Drop the plugin there, then run:

```
bundle exec rake redmine:plugins:migrate NAME=cloudogu_patches RAILS_ENV=production
```

Afterwards, restart Redmine.
