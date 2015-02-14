class AddCursorToUsers < ActiveRecord::Migration
  def change
    add_column :users, :dropbox_cursor, :string
  end
end
