class CreateTrainings < ActiveRecord::Migration
  def change
    create_table :trainings do |t|
      t.string :name

      t.timestamps null: false
    end
  end
end
