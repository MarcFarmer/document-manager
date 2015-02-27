class CreateAnswers < ActiveRecord::Migration
  def change
    create_table :answers do |t|
      t.belongs_to :question

      t.string :name
      t.boolean :correct
      t.string :type

      t.timestamps null: false
    end
  end
end
