class AddVersionNumberToDocuments < ActiveRecord::Migration
  def change
    add_column :documents, :version_number, :string
  end
end
