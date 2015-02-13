class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  before_action :authenticate_user!

  public

  def get_current_organisation
    @current_organisation
  end

  def set_current_organisation org
    @current_organisation = org
  end

end
