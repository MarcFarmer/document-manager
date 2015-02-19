class CreatePendingUsers < ActiveRecord::Migration
  def change
    create_table :pending_users do |t|
      t.string :email
      t.string :user_type

      t.timestamps null: false
    end
  end
end
