class CreateDocumentRevisions < ActiveRecord::Migration
  def change
    create_table :document_revisions do |t|
      t.integer :major_version
      t.integer :minor_version
      t.string :content
      t.string :change_control

      t.belongs_to :document, index: true 

      t.timestamps null: false
    end
  end
end
