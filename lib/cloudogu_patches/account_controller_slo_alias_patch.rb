# frozen_string_literal: true

# fixes: Couldn't destroy session service ticket … because no corresponding session id could be found.

module CloudoguPatches
  module AccountControllerSloAliasPatch
    def self.apply!
      Rails.logger.info("[CAS SLO] >>> entering .apply!")
      require_dependency 'account_controller'
      Rails.logger.info("[CAS SLO] >>> after require_dependency(AccountController)")

      # Only alias once per boot/reload
      if AccountController.method_defined?(:cas_without_slo)
        Rails.logger.info("[CAS SLO] >>> already patched, skipping")
        return
      end

      Rails.logger.info("[CAS SLO] >>> applying alias patch to AccountController")

      AccountController.class_eval do
        Rails.logger.info("[CAS SLO] >>> inside AccountController.class_eval")

        # Back-channel SLO POST has no CSRF token
        skip_forgery_protection only: :cas
        Rails.logger.info("[CAS SLO] >>> skip_forgery_protection set for :cas")

        # Keep original action
        alias_method :cas_without_slo, :cas
        Rails.logger.info("[CAS SLO] >>> alias cas_without_slo created")

        # Our wrapper runs FIRST; short-circuits on SLO
        def cas
          Rails.logger.info("[CAS SLO] >>> entered patched cas (method=#{request.method})")

          if request.post?
            raw = params[:logoutRequest].presence || request.raw_post
            Rails.logger.info("[CAS SLO] >>> raw=#{raw.inspect}")

            if raw.present?
              # Accept namespaced or non-namespaced SessionIndex
              st = raw.to_s[/<\s*(?:[\w\.-]+:)?SessionIndex\b[^>]*>([^<]+)/i, 1]
              Rails.logger.info("[CAS SLO] >>> extracted ST=#{st.inspect}")

              if st.present?
                deleted = ActiveRecord::SessionStore::Session.where(service_ticket: st).delete_all
                Rails.logger.info("[CAS SLO] >>> ST=#{st} deleted_rows=#{deleted}")
                return head :ok
              else
                Rails.logger.info("[CAS SLO] >>> logoutRequest present but no <SessionIndex>")
                return head :ok
              end
            end
          end

          Rails.logger.info("[CAS SLO] >>> falling back to original cas")
          cas_without_slo
        end
      end

      loc = AccountController.instance_method(:cas).source_location.inspect
      Rails.logger.info("[CAS SLO] >>> alias patch applied; cas => #{loc}")
    end
  end
end

# Make sure the patch is applied RIGHT NOW (in case to_prepare doesn't run here)
CloudoguPatches::AccountControllerSloAliasPatch.apply!

# And also re-apply on code reloads/boot phases
Rails.application.config.to_prepare do
  Rails.logger.info("[CAS SLO] >>> entering config.to_prepare; calling apply! again")
  CloudoguPatches::AccountControllerSloAliasPatch.apply!
end
