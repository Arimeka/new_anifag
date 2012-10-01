class ApplicationController < ActionController::Base
  protect_from_forgery
  include SessionsHelper
  
  protected
    def authenticate_inviter!
      redirect_to root_path unless current_user.admin?
    end
end
