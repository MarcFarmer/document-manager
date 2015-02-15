class CreateOrganisationUsers < ActiveRecord::Migration
  def change
    create_table :organisation_users do |t|
      t.boolean :accepted
      t.integer :user_type

      t.belongs_to :user
      t.belongs_to :organisation

      t.timestamps null: false
    end
  end
end
