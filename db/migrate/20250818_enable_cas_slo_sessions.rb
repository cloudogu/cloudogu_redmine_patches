# plugins/cloudogu_patches/db/migrate/20250818_enable_cas_slo_sessions.rb

# fixes on SLO:
# [f701c61a-05a5-4e75-b38c-077ffa60fe60] Couldn't destroy session service ticket ST-6-0JfSxCCGCn3wqyPJVo4B9Kyakxg-cas because no corresponding session id could be found.
class EnableCasSloSessions < ActiveRecord::Migration[7.0]
  def up
    return unless table_exists?(:sessions)

    unless column_exists?(:sessions, :service_ticket)
      add_column :sessions, :service_ticket, :string
      add_index  :sessions, :service_ticket
    end
  end

  def down
    # no-op
  end
end
