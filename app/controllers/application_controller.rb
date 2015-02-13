class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :null_session

  before_action :authenticate_user!

  public

  def set_current_organisation_id org_id
    session[:current_organisation_id] = org_id
  end

  def get_current_organisation
    Organisation.find_by_id session[:current_organisation_id].to_i
  end

end
