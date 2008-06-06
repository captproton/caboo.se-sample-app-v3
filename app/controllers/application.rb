# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  include AuthenticatedSystem
  include ExceptionNotifiable

  before_filter :set_user_time_zone
  
  class AccessDenied < StandardError; end

  # Pick a unique cookie name to distinguish our session data from others'
  session :session_key => '_restful_auth_rspec_session_id'

  # If you want timezones per-user, uncomment this:
  #before_filter :login_required

  around_filter :set_timezone
  around_filter :catch_errors
  
  protected
    def self.protected_actions
      [ :edit, :update, :destroy ]
    end

  private

    def set_timezone
      Time.zone = logged_in? ? current_user.time_zone : TimeZone.new('Etc/UTC')
        yield
      Time.reset!
    end

    def catch_errors
      begin
        yield

      rescue AccessDenied
        flash[:notice] = "You do not have access to that area."
        redirect_to '/'
      rescue ActiveRecord::RecordNotFound
        flash[:notice] = "Sorry, can't find that record."
        redirect_to '/'
      end
    end


  # See ActionController::RequestForgeryProtection for details
  # If you're using the Cookie Session Store you can leave out the :secret
  protect_from_forgery ## :secret => '62a9f27912d6522beff9f364438209e0'

end
