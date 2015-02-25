class AddDoUpdateToDocuments < ActiveRecord::Migration
  def change
    add_column :documents, :do_update, :boolean
  end
end
