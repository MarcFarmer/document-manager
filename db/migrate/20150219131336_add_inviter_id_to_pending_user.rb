class AddInviterIdToPendingUser < ActiveRecord::Migration
  def change
    add_column :pending_users, :inviter_id, :integer
  end
end
