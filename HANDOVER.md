# Handover notes

## Cleanup backlog

- The CAS SLO patch (`account_controller_slo_alias_patch.rb`) logs every step at `info` level.
  Drop it to `debug` or remove it once the fix has proven stable in production.
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
