class AddPathIndex < ActiveRecord::Migration
  def change
    add_index :notes, [:path, :user_id]
  end
end
