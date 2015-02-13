class OrganisationsController < ApplicationController
  def index
    @organisations = Organisation.all     # TODO use
    @current_organisation = get_current_organisation
  end

  def save_current_organisation
    set_current_organisation_id params[:organisation_id]
    redirect_to :organisations      # call index action
  end

end
