class AddMtimeToNotes < ActiveRecord::Migration
  def change
    add_column :notes, :mtime, :timestamp
  end
end
