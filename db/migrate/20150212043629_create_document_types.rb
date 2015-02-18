class CreateDocumentTypes < ActiveRecord::Migration
  def change
    create_table :document_types do |t|
      t.string :name
      t.belongs_to :organisation
      t.timestamps null: false
    end
  end
end
