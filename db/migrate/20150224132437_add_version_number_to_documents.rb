class AddVersionNumberToDocuments < ActiveRecord::Migration
  def change
    add_column :documents, :major_version, :string
    add_column :documents, :minor_version, :string
  end
end
