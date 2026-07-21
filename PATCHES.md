# Patches

Each patch below follows the same schema: what broke, what the fix does, which files are
involved, and what to watch out for.

## 1. CAS Single Logout (SLO) session cleanup

**Problem:** CAS sends a back-channel SLO `POST` to `account/cas` with a SAML
`<samlp:LogoutRequest>` body containing a `<SessionIndex>` (the CAS service ticket). Redmine's
session store has no column for the service ticket, so it can't find the session: it logs
`Couldn't destroy session service ticket ... because no corresponding session id could be found`
and the session stays alive.

**Fix:**
- A migration adds `sessions.service_ticket`, plus an index.
- `AccountController#cas` is monkey-patched. The original action is aliased to `cas_without_slo`.
  The back-channel POST carries no CSRF token, so CSRF protection is disabled for `:cas`. On POST,
  the patch pulls the `SessionIndex` out of the raw XML body with a regex and deletes the matching
  session row directly. Anything else - GET, or a POST without a usable `SessionIndex` - falls
  through to the original action.
- CAS calls back-channel with POST, so the `account/cas` route is widened to accept POST as well
  as GET.

**Files:** `db/migrate/20250818_enable_cas_slo_sessions.rb`,
`lib/cloudogu_patches/account_controller_slo_alias_patch.rb`, `config/routes.rb`

**Watch out:** the patch logs every step at `info` level (`[CAS SLO] ...`). That's leftover debug
logging - drop it to `debug` level or remove it before it fills up production logs. It also parses
the SAML body with a regex instead of an XML parser. That's fine for the one tag it needs, but
breaks if CAS changes the logout request shape.

## 2. Missing `account/cas` view

**Problem:** The `redmine_cas` plugin's `cas` action doesn't always render or redirect explicitly,
so Rails raised `Missing template account/cas`.

**Fix:** a placeholder view that renders `OK`.

**Files:** `app/views/account/cas.html.erb`

**Watch out:** if `redmine_cas` starts rendering its own template for this action, this placeholder
becomes dead code - harmless, but worth deleting.

## 3. Rails 8 timezone deprecation warning

**Problem:** Rails 8 deprecates the old `to_time` timezone behavior, and
`app/views/my/_sidebar.html.erb` triggers the warning.

**Fix:** `init.rb` sets `ActiveSupport.to_time_preserves_timezone = true` globally.

**Files:** `init.rb`

**Watch out:** this is a global Rails setting, not scoped to the sidebar view. Other code in
Redmine or other plugins that relies on the old `to_time` behavior gets the new behavior too.
