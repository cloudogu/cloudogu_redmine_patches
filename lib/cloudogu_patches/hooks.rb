# frozen_string_literal: true

module CloudoguPatches
  class Hooks < Redmine::Hook::ViewListener
    # Include a plugin stylesheet into <head> on every page
    def view_layouts_base_html_head(_context = {})
      stylesheet_link_tag('cloudogu_patches', plugin: :zzz_cloudogu_redmine_patches)
    end
  end
end
