Redmine::Plugin.register :zzz_cloudogu_redmine_patches do
  name        'Cloudogu Redmine Patches'
  author      'Dennis Schwarzer'
  version     '0.0.7'
  description 'Upgrade Helper from Redmine 5 to Redmine 6. Fixes for example duplicate inline SVG icons (keep theme sprites), Active Session Store SLO Bug and view error regarding account/cas and restores legacy plugins compatibility'
end

# Load the hook and patch
require_relative 'lib/cloudogu_patches/hooks'
require_relative 'lib/cloudogu_patches/account_controller_slo_alias_patch'

# Fixes:
# [f8d0cf2d-63c4-480e-9593-2f139c58127b] DEPRECATION WARNING: to_time will always preserve the timezone offset of the receiver in 
# Rails 8.0. To opt in to the new behavior, set `ActiveSupport.to_time_preserves_timezone = true`. 
# (called from _app_views_my__sidebar_html_erb__446723612933520565_86260 at 
# /usr/share/webapps/redmine/app/views/my/_sidebar.html.erb:14)
ActiveSupport.to_time_preserves_timezone = true
