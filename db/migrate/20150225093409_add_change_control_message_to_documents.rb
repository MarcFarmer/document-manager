class AddChangeControlMessageToDocuments < ActiveRecord::Migration
  def change
    add_column :documents, :change_control, :string
  end
end
