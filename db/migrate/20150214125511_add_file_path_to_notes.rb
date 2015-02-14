class AddFilePathToNotes < ActiveRecord::Migration
  def change
    add_column :notes, :path, :string
  end
end
