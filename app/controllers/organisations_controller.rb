class OrganisationsController < ApplicationController
  def index
    my_organisations = OrganisationUser.where(user_id: current_user.id)
    @organisations = []
    @organisation_invitations= []

    my_organisations.each do |ou|
      if ou.accepted
        @organisations << Organisation.find(ou.organisation_id)
      else
        @organisation_invitations << Organisation.find(ou.organisation_id)
      end
    end
  end

  def new
    @organisation = Organisation.new
    @current_user_id = current_user.id
  end

  def create
    @organisation = Organisation.new(organisation_params)

    organisation_user = OrganisationUser.new(organisation: @organisation, user: current_user)   # current user is organisation creator
    organisation_user.accepted = true
    organisation_user.user_type = 0
    organisation_user.inviter_id = current_user.id

    if @organisation.save && organisation_user.save
      set_current_organisation_id @organisation.id
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
