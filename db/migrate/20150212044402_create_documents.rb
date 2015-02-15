class CreateDocuments < ActiveRecord::Migration
  def change
    create_table :documents do |t|
      t.string :title

      t.belongs_to :user
      t.belongs_to :organisation
      t.belongs_to :document_type

      t.timestamps null: false
    end
  end
end
