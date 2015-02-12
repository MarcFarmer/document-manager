class CreateReviews < ActiveRecord::Migration
  def change
    create_table :reviews do |t|
      t.integer :status

      t.belongs_to :document
      t.belongs_to :user

      t.timestamps null: false
    end
  end
end
