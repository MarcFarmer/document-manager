class CreateApprovals < ActiveRecord::Migration
  def change
    create_table :approvals do |t|
      t.integer :status

      t.belongs_to :document
      t.belongs_to :user

      t.timestamps null: false
    end
  end
end
