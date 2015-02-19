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
    organisation_user.user_type = 2
    organisation_user.inviter_id = current_user.id

    if @organisation.save && organisation_user.save
      set_current_organisation_id @organisation.id
      redirect_to action: 'index', notice: 'Organisation was successfully created.'
    else
      render action: 'new', alert: 'Organisation could not be created'
    end
  end

  def invite
    if !@current_user_is_owner
      redirect_to :organisations, notice: 'Only owners can invite users.'
    end
    @typesOptions = [['Quality', 0], ['Basic', 1], ['Owner', 2]]
    @users = []
    users = User.all
    users.each do |u|
      if OrganisationUser.find_by_user_id_and_organisation_id(u.id, get_current_organisation.id) == nil
        @users << [u.email, u.id]
      end
    end
  end

  def inviteSubmission
    instantUserArray = params[:organisation_user][:invitedID]

    instantUserArray.each do |blah|
      if blah != ''
        blah2 = OrganisationUser.new
        blah2.user_id = blah.to_i
        blah2.organisation_id = get_current_organisation.id
        blah2.accepted = false
        blah2.user_type = params[:organisation_user][:typesSelection].to_i
        blah2.inviter_id = current_user.id
        blah2.save
      end
    end
    redirect_to :organisations, notice: "Selected users have been Invited"
  end

  def show

  end

  def users
    @organisation_users = []
    @organisation_user_id = get_current_organisation.id
    @organisation_user_type = OrganisationUser.find_by_user_id_and_organisation_id(current_user.id, @organisation_user_id).user_type
    users = User.all
    users.each do |u|
      ou = OrganisationUser.find_by_user_id_and_organisation_id(u.id, get_current_organisation.id)
      if ou != nil
        @organisation_users << {user: u, organisation_user: ou, organisation: ou.organisation}
      end
    end
  end

  def save_current_organisation
    set_current_organisation_id params[:organisation_id]
    redirect_to :organisations      # call index action
  end

  def accept_organisation_invitation
    ou = OrganisationUser.find_by_user_id_and_organisation_id(current_user.id, params[:organisation_id].to_i)
    ou.accepted = true
    ou.save
    redirect_to :organisations, notice: "Invitation to organisation accepted."      # call index action
  end

  def decline_organisation_invitation
    ou = OrganisationUser.find_by_user_id_and_organisation_id(current_user.id, params[:organisation_id].to_i)
    ou.destroy
    redirect_to :organisations, notice: "Invitation to organisation declined."      # call index action
  end

  def remove_user
    OrganisationUser.find_by_user_id_and_organisation_id(params[:user_id].to_i, get_current_organisation.id.to_i).destroy
    redirect_to :organisations, notice: "User removed from organisation."      # call index action
  end

  private

  def organisation_params
    params.require(:organisation).permit(:name, :user_id)
  end
end
