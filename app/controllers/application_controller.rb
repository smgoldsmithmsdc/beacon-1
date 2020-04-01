class ApplicationController < ActionController::Base
  before_action :require_user!

  include Passwordless::ControllerHelpers
  # http_basic_authenticate_with name: 'camden', password: 'camden'
  helper_method :current_user, :copyright

  before_action :set_paper_trail_whodunnit

  private
    def copyright
      ENV['COUNCIL_COPYRIGHT'] || '© 2020 Abc Council'
    end

    def current_user
      @current_user ||= authenticate_by_session(User)
    end

    def require_user!
      return if current_user
      save_passwordless_redirect_location!(User)
      redirect_to auth.sign_in_path, flash: { error: 'Please sign in' }
    end
end
