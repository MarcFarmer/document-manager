class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :null_session

  before_action :authenticate_user!
  before_action :get_current_organisation

  public

  def set_current_organisation_id org_id
    session[:current_organisation_id] = org_id
  end

  def get_current_organisation
    if session[:current_organisation_id] == nil
      @current_organisation = nil
    else
      @current_organisation = Organisation.find_by_id session[:current_organisation_id].to_i
    end
  end
end
