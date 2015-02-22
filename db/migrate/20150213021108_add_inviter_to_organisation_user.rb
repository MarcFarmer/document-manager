class AddInviterToOrganisationUser < ActiveRecord::Migration
  def change
    add_column :organisation_users, :inviter_id, :integer
  end
end
