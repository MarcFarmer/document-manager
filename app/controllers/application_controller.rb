class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :null_session

  before_action :authenticate_user!
  before_action :setup_header

  public

  @@USER_TYPE_QUALITY = 0
  @@USER_TYPE_BASIC = 1
  @@USER_TYPE_OWNER = 2

  def is_owner type
    type == @@USER_TYPE_OWNER ? true : false
  end

  def is_quality type
    type == @@USER_TYPE_QUALITY ? true : false
  end

  def is_basic type
    type == @@USER_TYPE_BASIC ? true : false
  end

  def set_current_organisation_id org_id
    session[:current_organisation_id] = org_id
  end

  def get_current_organisation
    if session[:current_organisation_id] == nil
      nil
    else
      Organisation.find_by_id session[:current_organisation_id].to_i
    end
  end

  def setup_header
    @current_organisation = get_current_organisation

    if @current_organisation == nil
      @current_user_is_owner = false
    else
      ou = OrganisationUser.where(user: current_user, organisation: @current_organisation)[0]
      if is_owner(ou.user_type)
        @current_user_is_owner = true
      end
    end
  end

  def check_current_organisation
    if get_current_organisation == nil
      redirect_to root_path, notice: 'You must select an organisation before viewing documents.'
    end
  end

  def check_current_user_is_owner
    if !is_owner(OrganisationUser.where(user: current_user, organisation: @current_organisation)[0].user_type)
      redirect_to root_path, notice: 'Only owner accounts can manage document types.'
    end
  end
end
