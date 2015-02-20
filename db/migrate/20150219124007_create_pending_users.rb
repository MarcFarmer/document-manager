class CreatePendingUsers < ActiveRecord::Migration
  def change
    create_table :pending_users do |t|
      t.string :email
      t.string :user_type

      t.belongs_to :organisation
      t.timestamps null: false
    end
  end
end
