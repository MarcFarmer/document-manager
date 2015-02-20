class CreateReaders < ActiveRecord::Migration
  def change
    create_table :readers do |t|
      t.belongs_to :document, index: true
      t.belongs_to :user, index: true
      t.timestamps null: false
    end
  end
end
