class CreateQuestions < ActiveRecord::Migration
  def change
    create_table :questions do |t|
      t.belongs_to :training
      
      t.string :name

      t.timestamps null: false
    end
  end
end
