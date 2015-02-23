class CreateDocuments < ActiveRecord::Migration
  def change
    create_table :documents do |t|
      t.string :title
      t.integer :status     # 0: draft, 1: for review, 2: for approval, 3: approved
      t.string :content

      t.belongs_to :user
      t.belongs_to :organisation
      t.belongs_to :document_type

      t.timestamps null: false
    end
  end
end
