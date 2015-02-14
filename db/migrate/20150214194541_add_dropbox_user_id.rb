class AddDropboxUserId < ActiveRecord::Migration
  def change
    add_column :users, :dropbox_user_id, :integer
    add_index :users, :dropbox_user_id
  end
end
