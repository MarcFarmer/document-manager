class OrganisationsController < ApplicationController
  def index
    @organisations = Organisation.all     # TODO use
    @current_organisation = get_current_organisation
  end

  def new
    @organisation = Organisation.new
    @current_user_id = current_user.id
  end

  def create
    @organisation = Organisation.new(organisation_params)

    organisation_user = OrganisationUser.new(organisation: @organisation, user: current_user)

    if @organisation.save && organisation_user.save
      redirect_to action: 'index', notice: 'Organisation was successfully created.'
    else
      render action: 'new', alert: 'Organisation could not be created'
    end
  end

  def save_current_organisation
    set_current_organisation_id params[:organisation_id]
    redirect_to :organisations      # call index action
  end

  private

  def organisation_params
    params.require(:organisation).permit(:name, :user_id)
  end
end
